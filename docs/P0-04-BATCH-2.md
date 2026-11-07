# P0-04 - Đợt 2: Checkout và route guards

Ngày bàn giao: 04/11/2026. Phạm vi duy nhất là đợt 2 đã được phê duyệt. Chưa chuyển sang ownership/migration đợt 3 hoặc giỏ riêng/merge đợt 4.

## Hành vi đã triển khai

| Điểm vào | Guest | Sau login/register thành công |
| --- | --- | --- |
| Home, Catalog, Detail, Related, review công khai, FAQ không có ngữ cảnh đơn, About | Public; tiếp tục xem sản phẩm và đọc review | Không replay thao tác |
| Cart: thêm, chỉnh số lượng, chọn/bỏ chọn, xóa | Được phép, giữ quy tắc kiểm tra giỏ hiện tại | Chưa merge/tách giỏ trong đợt này |
| Cart → Thanh toán | Mở `/login`, giữ giỏ | Về `/cart`, không vào checkout và không submit |
| `/checkout`, `/order-review`, `/payment-method`, `/bank-transfer`, `/cod-confirmation` | Chặn, hiển thị Auth | Về `/cart` để xem lại dữ liệu, không phục hồi object địa chỉ/receipt từ arguments |
| `/orders`, `/profile`, `/addresses`, `/vouchers` | Chặn, hiển thị Auth | Về route tương ứng |
| `/order-detail`, `/write-review` | Chặn, kể cả URL thiếu arguments | Giữ ID chuỗi; màn/source kiểm tra ID và điều kiện hiện có. Không có ID hợp lệ thì hiển thị fallback hiện có |
| `/support` có ID đơn | Chặn, hiển thị Auth | Về Support với ID chuỗi; `/support` không có ID vẫn là FAQ public |
| ProfileEditor / AddressEditor mở trực tiếp | Chặn trước khi dựng form hoặc gọi source | Về `/profile` hoặc `/addresses`; không giữ form/object địa chỉ cũ làm return intent |

Named route có guard tập trung trong CustomerApp. Các màn private cũng có guard tại chính màn, nên `MaterialPageRoute` hoặc nhúng widget trực tiếp không bỏ qua được. Component giao diện gốc nằm dưới guard; Guest không khởi tạo phần nội dung private, source hoặc controller của form đó. Guard tiếp tục lắng nghe session khi route còn trong stack, nên Back sau logout không khôi phục nội dung private.

Guard giữ Auth đến khi điều hướng hoàn tất. Notify đăng nhập không dựng ngầm checkout phía sau hiệu ứng chuyển trang; có test riêng kiểm tra private builder chưa từng chạy trong quá trình này.

Không thay giao diện/màu/nội dung/cách đóng popup Guest. Handler đăng nhập của popup chỉ được nối return intent về giỏ. Chưa thay quy tắc popup một lần mỗi Guest session (D08).

## Return intent

- Intent là object gắn với route Auth, chỉ trong RAM; có generation Guest, route trong allowlist và ID chuỗi tùy chọn. Không chứa callback tạo đơn, địa chỉ hoặc Order object.
- Login ↔ Register truyền cùng intent qua route arguments. Auth thất bại không điều hướng, không sửa giỏ. Back/hủy loại bỏ route và intent; lần mở Auth độc lập tiếp theo về Home.
- Khi thành công, chỉ dùng intent thuộc generation Guest ngay trước lần xác thực thành công. Intent cũ/route ngoài allowlist về Home. Đích private vẫn đi qua guard/source; việc xác minh owner A/B chưa có trong đợt này.
- Các route trung gian Auth/private bị loại khỏi stack sau khi dùng intent. Checkout không tự mở lại; người dùng bấm Thanh toán lần nữa từ giỏ.

## Store và source guards

- `requireCustomer()` kiểm tra identity hiện tại; `requireSession(stamp)` kiểm tra thêm generation và user ID.
- `submitCodOrder()` kiểm tra tài khoản trước khi trả pending Future, đọc catalog hoặc gọi order source. Guest không thể dùng Future COD của A. Phiên B không thể nhận lại Future đang gửi của A.
- COD draft chụp `ownerId` và `sessionGeneration`; Order COD mới mang `ownerId` từ draft. Không dùng email/tên làm khóa chủ đơn. Store từ chối kết quả source thiếu/sai owner trước khi cập nhật đơn/giỏ/receipt.
- Giữ nguyên validator catalog, giá, stock, quantity, totals, snapshot và chống double submit P0-03. Guard từ chối không làm mất giỏ, địa chỉ, note, coupon hoặc lựa chọn dòng. ID COD mock dùng counter RAM, không trùng với đơn hoàn tất ở phiên cũ chưa đưa vào lịch sử chung; thất bại không tiêu thụ ID thành công.
- `refreshCodCheckout()` yêu cầu tài khoản và kiểm tra stamp trước khi áp dữ liệu mới.
- Nguồn đọc order list/detail, checkout address, address book, profile và thao tác lưu/xóa/đổi mặc định địa chỉ, sửa profile, tải ví voucher kiểm tra tài khoản ở tầng source. Các nguồn private có await kiểm tra stamp trước/sau request.
- Đọc điều kiện viết review và submit review được guard; giữ điều kiện đơn đã giao, sản phẩm thuộc đơn và một lần/đơn/sản phẩm hiện có. Việc thay author/owner review theo user ID thuộc đợt 3, chưa tuyên bố D12 hoàn tất.
- Source preview giá/phí nhận địa chỉ do caller đưa vào không tự đọc dữ liệu private; được giữ hợp đồng hiện tại, gọi từ màn checkout đã guard. Không triển khai giao dịch ngân hàng hoặc voucher mới.

## Logout khi COD đang gửi - giới hạn D10

Cho phép logout; không coi logout là hủy request đã gửi. Request tiếp tục xử lý snapshot và owner ban đầu. Nếu user ID hoặc generation đã đổi khi kết quả về:

- Không insert vào collection đơn đang hiển thị, không xóa dòng giỏ và không reset draft/coupon của phiên mới.
- Không mở COD confirmation từ PaymentMethodPage cũ.
- Order vẫn mang owner ban đầu, được trả cho caller request ban đầu và giữ trong `_detachedCodResults` RAM riêng, chưa expose ra UI. Không chuyển đơn cho B.

**D10 chưa hoàn tất toàn bộ:** chưa có lịch sử/account state theo owner để đưa kết quả đó trở lại đúng A, xử lý giỏ A đã mua hoặc đối soát khi A quay lại. Đợt 3 phải tiêu thụ kết quả RAM này theo owner; đợt 4 xử lý đúng giỏ riêng đã mua. Không xóa queue này khi logout hoặc chuyển tài khoản. Nếu app/store bị hủy, RAM không phải persistence.

## Kiểm thử

31 test mới: 25 widget/source tests Customer, 6 Shared tests. Bao phủ protected direct routes, thiếu route arguments, MaterialPageRoute, Guest cart/COD/source calls, login/register về giỏ, actual Login/Register links, lỗi/hủy auth giữ giỏ, không tự submit, return intent cũ, Back/logout, private order ID, ngăn dựng ngầm checkout, owner COD, double submit, logout → B khi đang gửi và ID đơn không trùng.

Kết quả: **598 PASS** - Customer **339**, Shared **78**, Admin **181**. Analyzer sạch cả ba project. P0-01 voucher navigation Admin, P0-02 product identity, P0-03 COD validation và golden tiếp tục đạt. Không cập nhật golden. Các test member checkout/order cũ được bổ sung login fixture tường minh; các test Guest private page kỳ vọng Auth thay thông báo tĩnh.

Đã thử hot restart qua Dart MCP: DTD kết nối được, không có app chạy kết nối nên chưa xác minh trên APK/thiết bị hoặc browser thật. Widget tests kiểm tra Navigator và `handlePopRoute`; không báo là kiểm thử Back trên browser thật. Không thêm target Web cho Customer.

## Còn phụ thuộc đợt 3/4 và Backend

- Profile, addresses, orders, customs, favorites và draft vẫn là collection/fixture chung. Một tài khoản đã đăng nhập vẫn chưa được cách ly khỏi dữ liệu tài khoản khác. Không tuyên bố giải quyết A/B hoặc D06 trong đợt này. Các getter/list mock cũ chưa trở thành API kiểm soát quyền owner.
- Cache/form giữa A/B khi cả hai phiên đều signed-in chưa được reset theo owner; thuộc đợt 3. Không dùng thay đổi này làm bảo đảm quyền truy cập giữa hai tài khoản.
- Giỏ Guest/A/B chưa tách hoặc merge, logout chưa reset Guest cart/draft; thuộc đợt 3/4 theo chính sách đã duyệt. Login lỗi/cancel không thay giỏ.
- Return intent mới kiểm tra route/session và điều kiện nguồn hiện có; quyền đọc đúng order ID của user cần owner-scoped source ở đợt 3 và Backend.
- Backend sau này phải xác thực/authorize mọi private endpoint, tự suy ra owner từ principal, kiểm tra catalog/giá/stock/totals và idempotency COD. Không tin `ownerId`, generation hoặc giá do Flutter gửi. Mock source và Flutter guard không thay kiểm tra có thẩm quyền ở NestJS.

Danh sách file đầy đủ ở phần sau. Bản sao trước thay đổi: `.design/p0-04-batch-2/before.zip`. Không sửa Admin, dependency, Backend, database, Figma hoặc catalog P0-02. Dừng sau đợt 2, chờ nghiệm thu.

## File đã chỉnh sửa

- `apps/customer/lib/app/auth_return_intent.dart`
- `apps/customer/lib/app/customer_app.dart`
- `apps/customer/lib/app/customer_session_gate.dart`
- `apps/customer/lib/features/address_book/data/address_book_actions.dart`
- `apps/customer/lib/features/address_book/data/address_book_source.dart`
- `apps/customer/lib/features/address_book/data/address_editor_source.dart`
- `apps/customer/lib/features/address_book/presentation/address_book_page.dart`
- `apps/customer/lib/features/address_book/presentation/address_editor_page.dart`
- `apps/customer/lib/features/auth/presentation/auth_page.dart`
- `apps/customer/lib/features/cart/presentation/widgets/cart_checkout_button.dart`
- `apps/customer/lib/features/cart/presentation/widgets/guest_cart_prompt.dart`
- `apps/customer/lib/features/checkout/presentation/address_page.dart`
- `apps/customer/lib/features/checkout/presentation/bank_transfer_page.dart`
- `apps/customer/lib/features/checkout/presentation/cod_success_page.dart`
- `apps/customer/lib/features/checkout/presentation/order_review_page.dart`
- `apps/customer/lib/features/checkout/presentation/payment_method_page.dart`
- `apps/customer/lib/features/help/presentation/faq_page.dart`
- `apps/customer/lib/features/orders/presentation/order_detail_page.dart`
- `apps/customer/lib/features/orders/presentation/order_list_page.dart`
- `apps/customer/lib/features/profile/data/profile_editor_source.dart`
- `apps/customer/lib/features/profile/data/profile_source.dart`
- `apps/customer/lib/features/profile/presentation/profile_editor_page.dart`
- `apps/customer/lib/features/profile/presentation/profile_page.dart`
- `apps/customer/lib/features/reviews/data/review_order_source.dart`
- `apps/customer/lib/features/reviews/presentation/post_purchase_review_page.dart`
- `apps/customer/lib/features/vouchers/data/voucher_source.dart`
- `apps/customer/lib/features/vouchers/presentation/voucher_page.dart`
- `apps/customer/test/address_book_test.dart`
- `apps/customer/test/address_test.dart`
- `apps/customer/test/bank_transfer_test.dart`
- `apps/customer/test/button_consistency_test.dart`
- `apps/customer/test/buy_again_test.dart`
- `apps/customer/test/cod_checkout_test.dart`
- `apps/customer/test/customer_route_guards_test.dart`
- `apps/customer/test/faq_test.dart`
- `apps/customer/test/order_detail_test.dart`
- `apps/customer/test/order_list_test.dart`
- `apps/customer/test/order_review_test.dart`
- `apps/customer/test/payment_method_test.dart`
- `apps/customer/test/post_purchase_review_test.dart`
- `apps/customer/test/profile_editor_test.dart`
- `apps/customer/test/profile_test.dart`
- `apps/customer/test/visual_test.dart`
- `apps/customer/test/voucher_test.dart`
- `packages/lenlab_shared/lib/src/data/address_data.dart`
- `packages/lenlab_shared/lib/src/data/cod_order_data.dart`
- `packages/lenlab_shared/lib/src/data/order_detail_data.dart`
- `packages/lenlab_shared/lib/src/data/order_list_data.dart`
- `packages/lenlab_shared/lib/src/domain/models.dart`
- `packages/lenlab_shared/lib/src/state/lenlab_store.dart`
- `packages/lenlab_shared/test/cart_selection_test.dart`
- `packages/lenlab_shared/test/cod_order_test.dart`
- `packages/lenlab_shared/test/cod_validation_test.dart`
- `packages/lenlab_shared/test/customer_guards_test.dart`
- `packages/lenlab_shared/test/order_detail_test.dart`
- `packages/lenlab_shared/test/order_list_test.dart`
- `packages/lenlab_shared/test/repository_test.dart`
- `apps/customer/README.md`
- `docs/P0-04-BATCH-2.md`
