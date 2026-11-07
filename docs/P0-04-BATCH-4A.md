# P0-04 - Đợt 4A: Giỏ riêng Guest/A/B

Ngày bàn giao: 05/11/2026. Chỉ 4A; dừng chờ nghiệm thu trước 4B/4C. Không thay ChangeNotifier, CustomerScope, routing framework hoặc UI P2.

## Điều kiện tài liệu

Đã đọc hai bản gốc được chủ dự án cung cấp ở Downloads và sao chép nguyên byte vào `docs/LENLAB_SRS.docx`, `docs/LENLAB_UI_UX.docx`. SRS: mục 6.1, 6.4, 6.5, 6.6 và BR/NFR liên quan; UI/UX: luồng mục 2, UI-03/06/07/10, mục 4.1/4.5/5/7. Đối chiếu chi tiết với báo cáo cũ và quyết định Mobile tại [CART Business Rules](P0-04-CART-BUSINESS-RULES.md), mục 3.1.

Khác biệt về Guest phải đăng nhập để dùng giỏ, Auth luôn về Home, xóa toàn giỏ, Mua lại tự thêm hàng và Laravel/MySQL đã có quyết định Mobile mới hơn thay thế. Không phát hiện mâu thuẫn mới chưa được quyết định ảnh hưởng trực tiếp 4A. Không khôi phục Blog, sản phẩm số, biên lai hoặc đổi stack. D01–D12 và sáu chính sách vẫn giữ nguyên.

## Hành vi đã triển khai

| Tình huống | Kết quả 4A |
| --- | --- |
| Guest mới | Giỏ rỗng, coupon rỗng; thêm/sửa/xóa/chọn dòng được; không submit COD được |
| Account A | Fixture hai dòng, tổng lượng 3 thuộc `customer-demo-a` tường minh. Không tự áp LEN50 |
| B đăng nhập lần đầu hoặc tài khoản mới | Giỏ riêng rỗng, coupon rỗng; không nhận hàng/checkbox của A |
| A → B trực tiếp | Chỉ giỏ B; giỏ A và lựa chọn/coupon A giữ riêng trong RAM |
| A → logout | Guest mới rỗng, không sao chép giỏ/coupon A sang Guest |
| A quay lại | Nhận lại giỏ account A và checkbox/coupon account A; không phục hồi checkout draft của phiên cũ |
| Guest Auth lỗi/hủy | Không thay giỏ/checkbox/coupon Guest |
| Guest Auth thành công | Mở giỏ account; giỏ Guest có hàng được giữ riêng theo account đích để chờ 4B, **chưa merge và không tự áp coupon Guest** |
| COD A pending | Khóa sửa giỏ A, kể cả A đăng nhập lại ở generation mới. Guest/B vẫn thêm/sửa/xóa/chọn giỏ của họ được |
| Detached COD hoàn tất | Giữ xử lý lịch sử đúng owner của đợt 3; không reconcile/xóa dòng giỏ trong 4A |

`CustomerCartData` giữ lines, unselected keys và coupon riêng cho từng container. Account map dùng user ID ổn định; Guest dùng container mới mỗi phiên logout. Không dùng email hoặc tên làm khóa.

`cart` trả view gắn với container và session stamp. Giữ view phiên cũ rồi gọi thao tác list không thể sửa phiên mới hoặc generation mới. Store kiểm tra membership trước khi sửa lượng/chọn/xóa, nên callback giữ CartLine cũ không tác động giỏ account khác. Các thao tác mua bình thường dùng CartLine/Product snapshot hiện có, không chia sẻ dòng do tự chuyển giỏ A sang B. Model vẫn là DTO mutable trong RAM, không phải ranh giới bảo mật Backend.

Checkbox được cách ly theo giỏ. Quy tắc checkbox khi merge chưa chạy ở 4A. Coupon không khởi tạo mặc nhiên ở Guest/A/B, không chuyển theo Auth; account đã chủ động có coupon giữ state riêng. Không thay công thức LEN50 hoặc thêm UI redeem/voucher mới.

Popup giữ nguyên component, nội dung, màu, thao tác close/later/Back/login và nền trắng che giỏ phía sau. Cờ dismiss thuộc Guest cart, nên chỉ hiện một lần trong cùng phiên Guest; logout tạo Guest mới cho phép nhắc lại theo D08. Không có thay đổi bố cục.

## Khóa COD và giới hạn 4B/4C

Khóa chỉnh giỏ được scope theo user ID của request COD hoặc refresh đang chờ, không theo một bool chung cho mọi account. Không mở khả năng submit COD đồng thời của B khi request A vẫn chiếm source/Future hiện tại; tạo COD đồng thời không nằm trong 4A. Guard cũ từ chối lấy Future của phiên khác vẫn giữ.

COD thành công trong đúng phiên hiện tại vẫn chỉ xử lý dòng chọn theo P0-03. Việc cập nhật nội bộ sau thành công/refresh sử dụng đúng container đã qua kiểm tra session, không bị khóa chỉnh giỏ của người dùng chặn nhầm. Đổi phiên thì kết quả không sửa giỏ/draft phiên mới.

Guest cart chờ 4B được giữ trong RAM theo account đã xác thực thành công. Không merge, cộng lượng, áp selection merge, đánh dấu merge thành công hoặc tự tạo đơn. Trong bản trung gian 4A, sau Auth người dùng thấy giỏ account, chưa thấy các dòng Guest được giữ chờ; không báo rằng D03 đã hoàn tất. Getter `pendingGuestCarts` chỉ dành cho kiểm thử, trả bản chụp để chứng minh không mất dữ liệu Guest, không phải hợp đồng API/UI mới.

Đợt 4C phải bổ sung identity/snapshot và dấu reconcile giỏ riêng với reconcile lịch sử: lịch sử A có đơn không có nghĩa giỏ A đã được xử lý. 4A không tự xóa phần đã mua của detached COD hoặc lấy queue lịch sử rỗng làm căn cứ dọn giỏ. Guest merge chờ A pending phải được thực thi sau reconcile ở phối hợp 4B/4C; hiện chỉ giữ dữ liệu và khóa đúng account.

Không persistence: hủy app/Store làm mất account carts, Guest chờ và kết quả mock trong RAM. Store mới chỉ có fixture A khai báo sẵn, không phải khôi phục dữ liệu account đã mua/sửa ở Store cũ.

## Tests và kết quả

Thêm **12 test**:

- `packages/lenlab_shared/test/customer_cart_isolation_test.dart`: 10 test cho Guest/B rỗng và fixture A, Guest sửa giỏ/auth guard, logout/restore A, chuyển trực tiếp A/B cùng product, checkbox/coupon riêng, retained view/callback, Auth lỗi, Guest chờ không merge/không coupon transfer, register, RAM-only và pending COD khóa đúng chủ.
- `apps/customer/test/cart_session_isolation_test.dart`: 2 widget test chuyển A → B → A ngay trên Cart, popup một lần/Guest session và logout không hiện hàng A.

Test fixture cũ dựa vào Guest có sẵn hàng và LEN50 mặc nhiên đã được cập nhật: public Guest kỳ vọng rỗng; tình huống cần hàng Guest tự thêm hàng; test tài khoản dùng A; test giá/discount và golden chủ động thiết lập coupon mẫu. Không giảm assertions validation P0-03 hoặc bỏ các test mua hàng. Tests đợt 2/3 trước đây coi giỏ A/B là chung được đổi kỳ vọng theo chính sách mới, vẫn kiểm tra giữ dữ liệu A và không đổi giỏ B.

Lượt cuối qua Dart MCP: **650 PASS** - Shared **100**, Customer **369**, Admin **181**. Tăng 12 từ 638 của đợt 3. Analyzer cả ba project sạch. P0-01 Admin voucher navigation, P0-02 product identity, P0-03 COD validation và guards/ownership đợt 2/3 tiếp tục đạt.

JSON kết quả: `build/p0-04-batch4a-final.json` tại mỗi project. Không cập nhật golden; kiểm tra byte ảnh baseline trong `test/goldens/` với backup trước 4A. File ảnh diagnostic trong `test/failures/` là output của lượt test lỗi trung gian, không phải baseline được duyệt.

Runtime: đã phát hiện/kết nối DTD của VS Code, gọi listConnectedApps và thử hot restart. Không có app đang kết nối; chưa xác minh APK/thiết bị hoặc browser thật. Widget/Navigator/golden tests không thay thế kiểm thử native và Back browser.

## Backend và bàn giao

Backend cần tự xác thực/authorize cart theo principal; variant/cart line ID và version; merge atomic/idempotent; snapshot request; stock/giá/totals; xử lý kết quả chưa rõ khi timeout và transaction reconcile giỏ. Không tin session generation, coupon/giá hoặc owner client gửi. 4A không thay policy giữ/trừ/hoàn tồn, không có API/database/NestJS/Supabase, không sửa Admin source/dependency/Figma.

Bản sao trước thay đổi: `.design/p0-04-batch-4a/before.zip`. Dừng sau bàn giao này để nghiệm thu 4A, chưa triển khai 4B/4C.

## Danh sách file

Danh sách Dart bên dưới gồm production và các test/fixture bị ảnh hưởng. Tài liệu: `docs/P0-04-CART-BUSINESS-RULES.md`, `docs/WORKFLOW-SCOPE.md`, `docs/P0-04-BATCH-4A.md`, `apps/customer/README.md`; hai bản gốc bổ sung: `docs/LENLAB_SRS.docx`, `docs/LENLAB_UI_UX.docx`.

- `apps/customer/lib/features/cart/presentation/cart_page.dart`
- `apps/customer/test/about_test.dart`
- `apps/customer/test/address_book_test.dart`
- `apps/customer/test/address_editor_test.dart`
- `apps/customer/test/address_test.dart`
- `apps/customer/test/avatar_test.dart`
- `apps/customer/test/bank_transfer_test.dart`
- `apps/customer/test/cart_selection_test.dart`
- `apps/customer/test/cart_session_isolation_test.dart`
- `apps/customer/test/cart_test.dart`
- `apps/customer/test/cod_checkout_test.dart`
- `apps/customer/test/cod_validation_test.dart`
- `apps/customer/test/customer_navigation_test.dart`
- `apps/customer/test/customer_route_guards_test.dart`
- `apps/customer/test/drawer_test.dart`
- `apps/customer/test/faq_test.dart`
- `apps/customer/test/guest_cart_test.dart`
- `apps/customer/test/order_detail_test.dart`
- `apps/customer/test/order_list_test.dart`
- `apps/customer/test/order_review_test.dart`
- `apps/customer/test/payment_method_test.dart`
- `apps/customer/test/post_purchase_review_test.dart`
- `apps/customer/test/product_identity_test.dart`
- `apps/customer/test/profile_editor_test.dart`
- `apps/customer/test/profile_test.dart`
- `apps/customer/test/rating_consistency_test.dart`
- `apps/customer/test/review_photos_test.dart`
- `apps/customer/test/reviews_test.dart`
- `apps/customer/test/scope_cleanup_test.dart`
- `apps/customer/test/visual_test.dart`
- `apps/customer/test/voucher_test.dart`
- `packages/lenlab_shared/lib/src/state/customer_account_data.dart`
- `packages/lenlab_shared/lib/src/state/customer_cart_data.dart`
- `packages/lenlab_shared/lib/src/state/lenlab_store.dart`
- `packages/lenlab_shared/test/account_cod_isolation_test.dart`
- `packages/lenlab_shared/test/bank_transfer_test.dart`
- `packages/lenlab_shared/test/cart_selection_test.dart`
- `packages/lenlab_shared/test/cod_order_test.dart`
- `packages/lenlab_shared/test/cod_validation_test.dart`
- `packages/lenlab_shared/test/customer_cart_isolation_test.dart`
- `packages/lenlab_shared/test/customer_guards_test.dart`
- `packages/lenlab_shared/test/customer_ownership_test.dart`
- `packages/lenlab_shared/test/order_detail_test.dart`
- `packages/lenlab_shared/test/order_list_test.dart`
- `packages/lenlab_shared/test/post_purchase_review_test.dart`
- `packages/lenlab_shared/test/product_review_data_test.dart`
- `packages/lenlab_shared/test/repository_test.dart`
- `packages/lenlab_shared/test/review_photo_test.dart`
