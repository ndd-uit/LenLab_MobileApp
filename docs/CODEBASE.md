# Cấu trúc và rà soát codebase LENLAB

> Scope update 2026-11-04: This document contains historical milestones. For the current FE scope, removals and remaining integration work, use [FE-SCOPE-CLEANUP.md](FE-SCOPE-CLEANUP.md). Blog/digital products/advanced marketing are excluded; do not restore them from this history.

App khách hàng là Flutter iOS/Android; admin là Flutter Web. Chưa có backend. Tái cấu trúc không thay đổi hợp đồng dữ liệu hay tự bổ sung nghiệp vụ.

Admin A01: `apps/admin/lib/app.dart` cấu hình MaterialApp/named routes, `app/admin_destination.dart` định nghĩa các mục, `shared/layout/` chứa AdminShell/Sidebar/Header/styles. `test/admin_shell_test.dart` kiểm tra điều hướng/trạng thái tạm, `test/admin_visual_test.dart` render desktop/màn hẹp. Chưa tạo feature folder rỗng hoặc dùng LenlabStore của customer làm nguồn toàn hệ thống. Xem [ADMIN-BACKLOG.md](ADMIN-BACKLOG.md).

Admin A02: `features/auth/data/admin_auth_source.dart` là port/adapter demo, `presentation/admin_login_page.dart` và background bám mẫu xanh 10729. `app/admin_session.dart`, `admin_scope.dart`, `admin_access_page.dart` quản lý phiên bộ nhớ và guard UI; không có persistence hoặc backend authorization. Test source/login riêng và golden login; A01 tests tiêm phiên đã đăng nhập để giữ phạm vi shell.

Trạng thái customer hiện tại và các điểm điều hướng còn thiếu: [CUSTOMER-CHECKLIST.md](CUSTOMER-CHECKLIST.md). Các ghi chú bàn giao theo bước bên dưới có thể mô tả thời điểm cũ; dùng checklist và WORKFLOW-SCOPE.md để xác định phạm vi mới nhất.

## Tìm đúng chỗ để sửa

```text
apps/customer/lib/
  main.dart
  app/
    customer_app.dart         MaterialApp và bảng route
    customer_scope.dart       Cung cấp LenlabStore
    navigation.dart           go / home
  features/
    auth/presentation/        Đăng nhập, đăng ký, validation và widgets tài khoản
    home/
      data/home_content.dart  Fixture trang chủ
      presentation/           Trang chủ và widgets từng section
    catalog/presentation/     Logic tải/lọc/phân trang dùng chung
      widgets/                Header, bộ lọc, grid, card, phân trang
                              Sản phẩm số có card ngang/nav riêng theo P2
    products/                 data/PdfDetailSource; presentation detail vật lý/chung và mẫu móc PDF riêng, styles/widgets
    cart/presentation/        Giỏ hàng, styles và widgets; GuestCartPrompt là popup P2 nhắc đăng nhập trên giỏ thực
    checkout/presentation/    Địa chỉ, tổng quan, phương thức, thành công COD, chuyển khoản và widgets
      digital_checkout_preview_page.dart  Preview Product số và trạng thái thiếu dữ liệu; chưa tạo đơn/thanh toán
    orders/presentation/      Danh sách/chi tiết đơn, styles và widgets header/tabs/card/status/products/information/actions
    profile/                 data/ProfileSource/ProfileEditorSource; presentation hồ sơ, form sửa, avatar và lối tắt
    vouchers/                data/VoucherSource, fixture ví voucher riêng; presentation page/card/button
    library/                 data/LibrarySource, model hiển thị và fixture ảnh P2; presentation page/card thư viện
    help/                    data/FaqSource và câu hỏi P2; presentation FAQ, accordion và khối liên hệ minh họa
    blog/                    data/BlogSource/ArticleSource; presentation danh sách, chi tiết, card, video và sản phẩm minh họa
    about/                   data/AboutSource và nội dung P2; presentation hero, giá trị, tầm nhìn/sứ mệnh, timeline và CTA
    reviews/                 data/ReviewOrderSource; presentation xem/lọc và form đánh giá sau mua, summary/card, chọn sao, thông tin sản phẩm và helper mở form
    comments/                data/CommentSource, model/fixture P2 theo product ID; presentation trang và card/phản hồi chỉ đọc
    address_book/            data/AddressBookSource, AddressEditorSource và presentation danh sách/form thêm sửa địa chỉ
  shared/
    data/article_metadata.dart     Metadata bài Thu Đông dùng chung Home/chi tiết, giữ năm biên tập 2026
    widgets/header_widgets.dart    Back chung theo orders, icon giỏ hàng và liên kết LENLAB → home
    navigation/customer_drawer.dart
    navigation/widgets/           Identity, mục menu và footer Drawer P2 khách/member
    layout/pending_page.dart       Màn tạm cho route chưa triển khai

packages/lenlab_shared/lib/
  lenlab_shared.dart           Public exports dùng bởi customer/admin
  src/
    domain/models.dart        Model sản phẩm, địa chỉ, giỏ, đơn hàng...
    data/
      lenlab_repository.dart       Interface và lỗi repository
      mock_lenlab_repository.dart  Seed và hành vi mock
      address_data.dart            Port/adapter địa chỉ và fixture địa giới
      order_review_data.dart       Port preview tiền và phí vận chuyển mock
      cod_order_data.dart          Snapshot checkout và port/adapter gửi COD mock
      bank_transfer_data.dart      Port/adapter preview chuyển khoản minh họa
      order_detail_data.dart       Port/adapter đọc đúng đơn trong store theo ID
      order_list_data.dart         Port/adapter tải và lọc bộ đơn dùng chung với detail
      product_review_data.dart     ReviewSource/model/fixture; store giữ cùng collection cho catalog/detail/danh sách
      post_purchase_review_data.dart  ReviewDraft, port lưu đánh giá và adapter mock; store kiểm tra đơn/sản phẩm/phiên và ghi nguồn chung
    state/lenlab_store.dart    Trạng thái mock trong bộ nhớ
    ui/
      theme.dart              Màu/font theo vai trò P2
      widgets.dart            Asset, nút, badge, notice, empty, feedback dùng chung
      asset_files.dart        Map asset gốc Figma
```

Màn hình ghép các widget; widget riêng một tính năng nằm trong `presentation/widgets/` của tính năng đó. Component được dùng qua nhiều tính năng nằm trong `shared/`. Feature gọi scope/navigation, không import `customer_app.dart` để tránh vòng phụ thuộc qua bảng route. Không tạo alias/wrapper chỉ để giữ đường dẫn cũ; sửa import ở nơi gọi.

## Quy tắc màu nút đã chốt lại

Người dùng đã xác nhận **theo đúng màu từng nút trong Figma P2**, thay yêu cầu nâu đồng nhất trước đó. Không áp một màu nâu cho toàn bộ app.

| Vị trí | Token/màu P2 |
| --- | --- |
| Nút + card sản phẩm vật lý | `P2.productCardButton` - #383029 |
| Thêm giỏ, Mua ngay và size được chọn ở detail chung | `P2.productDetailButton` - #F09942 |
| Thanh toán giỏ hàng, Xem lại đơn hàng ở địa chỉ | `P2.checkoutButton` - #E9A663 |
| Đăng nhập/đăng ký | `P2.authButton` - #D9A52E; loading đăng nhập #DBA324 |
| Chip danh mục chưa chọn | #523419 hoặc #383029 theo nhóm trong P2; đã chọn nền hồng |
| Nút card sản phẩm số | `P2.digitalProductButton` - #EE8C2B |

Header/detail dùng cùng hình icon giỏ theo yêu cầu người dùng. Detail vẫn chung bố cục Merino; dữ liệu, biến thể, định dạng và hành động phụ thuộc sản phẩm.

Theo yêu cầu đồng bộ sau task danh sách đơn, mọi nút back của customer dùng `HeaderBackButton`: SVG `21454.svg` từ P2 orders `2026:1852`, 11.775×20px, nâu `P2.brown`, vùng chạm 44×44px. Header thường căn lề trái 14px; chiều cao từng header/thanh bước giữ theo màn. Detail sản phẩm dùng biến thể `round` giữ nền tròn và vị trí overlay. Fallback giữ theo luồng: về home hoặc bước checkout tương ứng khi không có lịch sử; màn tạm chỉ hiện back khi có trang trước. Không thay menu ở home/catalog thành back.

Theo điều chỉnh tiếp theo của người dùng, icon quay lại/yêu thích trên header detail cũng dùng nâu `P2.brown` (#6B4B3E) như giỏ hàng; nền nút hồng được giữ nguyên. Áp dụng qua component chung cho mọi detail.

Nút + được căn phải và cùng hàng trong từng cặp card. Chiều cao tên, vùng giá cũ và phương án xuống dòng giá được tính chung theo hàng; không cắt chữ hoặc thu nhỏ chữ khi bật text scaling.

## Đã xóa hoặc gộp

| Thành phần cũ | Xử lý và lý do |
| --- | --- |
| `lib/shop.dart` | Xóa: nhánh catalog cũ trùng logic và wrapper ProductPage không còn cần |
| `lib/merino_page.dart` | Xóa alias: mọi detail gọi ProductDetailPage trực tiếp |
| `lib/app.dart` gộp nhiều trách nhiệm | Tách app, scope, navigation, auth và drawer; bỏ AppPage không còn nơi gọi |
| Các file lib đặt phẳng | Chuyển về feature; cập nhật import và test |
| P2Card, P2Field, ChoiceStrip, QuantityControl, PriceRow, AttachmentPicker và helper confirm | Xóa vì không còn nơi gọi trong customer/admin; Notice và validator đang dùng được giữ/tách đúng nơi |
| `file_picker` | Bỏ dependency chưa dùng cùng 7 dependency kéo theo; khi có task tải minh chứng mới bổ sung lại theo nhu cầu thực |
| `scripts/configure.mjs` | Xóa script khởi tạo một lần có thể ghi đè pubspec; không dùng để chạy dự án hiện tại |

Đã gộp **logic** catalog; giao diện vật lý vẫn lưới, sản phẩm số vẫn card ngang theo node `2026:2898`. Không dùng việc tái sử dụng component để ép hai thiết kế thành một.

## Giữ lại có chủ đích

- 499 asset của ba trang P2 và font/OFL: gồm cả màn chưa triển khai; không thể kết luận thừa chỉ vì màn hiện tại chưa gọi.
- `cupertino_icons`: giữ font nền tảng iOS; build Web kiểm tra lại không còn cảnh báo thiếu font này.
- Model, repository port, mock/store và test nghiệp vụ: phục vụ luồng đang chạy và các task sau, không phải backend thật.
- Android/iOS scaffold, admin Web, lockfile, LICENSE: cần cho build/tái lập và pháp lý. Không tự đặt giấy phép thay chủ dự án.
- Script tải asset/font và kiểm tra asset: phục vụ đối chiếu thiết kế. URL Figma tạm không dùng khi app chạy.
- Build/cache đang được ignore: không xóa dữ liệu/cấu hình môi trường chỉ để giảm số file thấy trong IDE.

## Kiểm tra

Trong `apps/customer`: `flutter analyze`, `flutter test` (105 test sau task chi tiết đơn). Có kiểm tra màu P2, căn nút card, địa chỉ/ghi chú/tổng tiền, loading/error/retry, gửi COD/chặn Back/gửi trùng, clipboard, chuyển khoản/guard, chi tiết đúng đơn/trạng thái và ảnh render.

Checkout: `/checkout` → `/order-review` → `/payment-method`. `CheckoutHeader` dùng chung với bước tiến trình tương ứng; phương thức thanh toán giữ bố cục header riêng của node 1627 và tăng chiều cao khi chữ lớn. Nút Sửa trả về form rồi pop về tổng quan, không đẩy thêm một màn tổng quan nữa. `deliveryAddress`/`checkoutNote` giữ draft trong store; preview không gọi placeOrder, không xóa giỏ. Phí 30.000đ là fixture của MockOrderReviewSource, chưa là quy tắc giao vận thật.

Phương thức thanh toán tái sử dụng `OrderReviewSource`; các widget thẻ phương thức/thông tin/bottom bar tách riêng. COD được chọn mặc định theo P2; thẻ ngân hàng là liên kết mở `/bank-transfer`, quay lại màn chọn khôi phục COD. `checkoutPaymentMethod` truyền lựa chọn qua store cho bước sau.

`BankTransferPage` giữ header, QR và bank details của node 1768; khối thêm ảnh và nút gửi đã bỏ theo yêu cầu mới. `BankTransferSource`/`MockBankTransferSource` lấy tổng từ `OrderReviewSource`, mô phỏng lỗi bằng operation `bankTransfer`; tài khoản/tên ngân hàng là dữ liệu mẫu P2. `bankTransferReference` là mã draft minh họa trong bộ nhớ, không phải mã đơn đã tạo hoặc được server đặt chỗ; giữ khi tải lại/đổi giỏ/quay lại, reset sau COD thành công. Không gọi placeOrder/submitProof, không xóa giỏ hay đổi payment state. QR luôn là asset minh họa cố định, không mã hóa tổng hoặc reference đang hiển thị.

Hai nút sao chép dùng Clipboard, có phản hồi thành công/lỗi; vùng chạm 44px giữ nền tròn 40px. Lưu mã QR hiện mở dialog xem minh họa và thông báo chưa lưu vào máy. Theo quyết định mới, **cổng bên thứ ba là luồng chính**: khối chọn ảnh, hướng dẫn và nút gửi minh chứng đã xóa hẳn; bỏ `bank_transfer_proof_placeholder.dart` và khoảng trống của khối này. Không tạo đơn từ ảnh, không giữ file_picker hoặc quyền native mới. Nguồn preview không được coi là adapter cổng thanh toán. Hướng tích hợp và các điểm cần chốt nằm tại [PAYMENTS.md](PAYMENTS.md).

Nút COD gọi `LenlabStore.submitCodOrder` qua `CodOrderSource`; `MockCodOrderSource` mô phỏng độ trễ/lỗi bằng operation `checkout`. Store gộp các lời gọi đồng thời vào cùng Future, chụp giá/số lượng/biến thể/địa chỉ/ghi chú và dùng shipping/discount từ preview; tạm khóa API sửa giỏ trong lúc gửi. Lỗi giữ draft, thành công thêm một đơn pending/payment cod rồi xóa giỏ/voucher/ghi chú. Không đánh dấu thanh toán confirmed. `placeOrder` cũ vẫn còn cho seed test/luồng số; UI COD dùng port mới, không nối adapter HTTP khi chưa có API.

`/cod-confirmation` nhận chính Order vừa tạo, xóa các route checkout cũ khỏi stack và hiển thị P2 node 1691 qua `CodSuccessPage`, `CodOrderReceipt`, `CodSuccessIllustration`. Truy cập thiếu Order có guard, không tự tạo đơn. Xem chi tiết mở `/order-detail` với mã đơn; hỗ trợ còn route tạm; Tiếp tục mua sắm về home. Cousine Bold/OFL bổ sung cho mã đơn. Nhãn ngày giao 24–26 Tháng 10 là fixture từ nguồn mock, UI có fallback Chờ shop xác nhận; chưa có lịch giao thật. Chống trùng hiện chỉ trong tiến trình; backend cần idempotency/persistence khi tích hợp.

`OrderDetailPage` lấy String ID qua route, đọc bằng `OrderDetailSource`/`MockOrderDetailSource` từ danh sách store hiện tại, operation lỗi mock `orderDetail`. Không tự rơi về đơn seed đầu tiên khi thiếu/sai mã. Widget header/status/products/information/actions tách riêng vì typography và bố cục node 2009 khác tổng quan checkout. Nội dung bám Order đã tạo: trạng thái, dòng sản phẩm/giá/số lượng/biến thể, địa chỉ, payment label, tiền hàng/phí/giảm giá/tổng và ghi chú nếu có. `createdAt` là metadata tùy chọn; seed mẫu đầu có ngày P2, COD mới nhận thời điểm mock tạo đơn. Thiếu timestamp hoặc estimate thì hiển thị fallback, không tự bịa lịch sử hay tính ngày giao.

Nút hỗ trợ mang ID sang route tạm. Nút Hủy mở thông báo bản dùng thử chưa hỗ trợ và có đường sang hỗ trợ; chưa có policy/API nên không tự đổi state/refund. Không khôi phục UI minh chứng hoặc đánh dấu thanh toán từ frontend. Danh sách `/orders` vẫn thuộc task tiếp theo.

Trong `packages/lenlab_shared`: `flutter analyze`, `flutter test` (12 test repository/checkout/detail). Trong `apps/admin`: `flutter analyze`, `flutter build web`. Kiểm tra asset từ root: `node scripts/verify-assets.mjs`.

Golden là ảnh hồi quy Flutter, không phải chứng nhận pixel-perfect. Còn cần kiểm tra Android/iOS thật; SVG filter của bóng nút giỏ chưa được Flutter SVG hỗ trợ đầy đủ. Mock catalog số có 2 sản phẩm công khai nên số thẻ khác 4 bản mẫu Figma; không tự bật sản phẩm ẩn hay bịa thêm dữ liệu để lấp đủ thẻ.

## Admin A03.1

apps/admin/lib/features/dashboard/data/dashboard_source.dart chứa port đọc thống kê và fixture riêng, không dùng store customer. presentation/dashboard_content.dart quản lý tải/rỗng/lỗi/retry; widgets/dashboard_metrics.dart dùng DashboardCard chung, widgets/dashboard_charts.dart vẽ LineChart/PieChart bằng fl_chart. AdminShell chỉ thay body Tổng quan; các route khác giữ màn tạm. Chưa API, định nghĩa kỳ/doanh số thực hoặc danh sách sản phẩm dashboard.

## Admin A04.1

features/products/data/admin_products_source.dart chứa model/query/result/port chỉ đọc và 12 fixture. presentation/admin_products_content.dart điều phối debounce, chống kết quả cũ, loading/empty/error/retry; widgets/ tách header, filters, table, pagination và styles. AdminShell dùng header riêng và nền P2 6669 cho /products; giữ sidebar chung và route tức thời. Chưa tạo API ghi hoặc phụ thuộc mới.

## Admin A06.1

features/orders/data/admin_orders_source.dart chứa DTO/query/result chỉ đọc và 12 fixture admin riêng. presentation/admin_orders_content.dart điều phối tìm/lọc/phân trang/debounce/chống kết quả cũ và loading/empty/error/retry; widgets/ gồm header, filters, table và styles. shared/widgets/admin_list_pagination.dart và admin_list_styles.dart dùng chung products/orders; wrapper ProductsPagination giữ API cũ. /orders có header/nền riêng P2, sidebar giữ A01, Chi tiết còn thông báo đúng ID cho A06.2. Chưa backend/ghi dữ liệu/minh chứng thanh toán.

## Admin A06.2

AdminApp giữ một AdminOrdersSource truyền qua AdminAccessPage/AdminShell tới list và detail. app/admin_order_navigation.dart tạo URL có ID và phân biệt Back từ list/URL trực tiếp. data/admin_order_summary.dart tách DTO cũ (re-export qua source), admin_order_detail.dart có line/detail và supplement đúng ID. Source.detail đọc cùng bộ summary, không có API ghi. presentation/admin_order_detail_page.dart quản lý tải/guard/retry; widgets/order_detail_cards.dart, order_detail_products.dart và order_status_badge.dart tách phần hiển thị. Badge dùng chung list/detail. Không có payment proof hoặc thao tác ghi.

## Admin A14.1

features/digital_products/data/admin_digital_products_source.dart chứa DTO/enum/result, port fetch chỉ đọc và ba fixture P2, không có file URL/entitlement. Result tính số published/draft/unknown, giá và metadata nullable. presentation/admin_digital_products_page.dart giữ Future theo source, tải/rỗng/lỗi/retry và guard kết quả muộn; SizedBox.expand giữ scroll view bám đầu vùng shell. widgets/digital_products_table.dart có scrollbar ngang riêng, digital_product_styles.dart giữ nút P2 #D1A373/24px/48px. AdminDestination.digitalProducts map /digital-products, shell render page riêng và sidebar thêm mục con Sản phẩm số khi xem nhóm sản phẩm. Chưa CRUD/upload/cấp quyền/publish/sync customer; không thêm tìm/lọc/phân trang ngoài frame.

## Admin A14.2

DTO/enum cốt lõi tách ra data/admin_digital_product.dart và được source export lại; admin_digital_product_detail.dart chứa supplement nullable, không có URL hoặc trạng thái upload thật. AdminDigitalProductsSource bổ sung detail(id), App giữ một source cho danh sách/editor. Mock trả đúng object sản phẩm từ nguồn; chỉ Dino có supplement P2, không có port ghi.

app/admin_digital_product_navigation.dart mở route /digital-products/edit?id=… và quay lại đúng danh sách theo origin hoặc fallback. Access page và shell nhận diện editor, giữ guard và mục Sản phẩm số. presentation/admin_digital_product_edit_page.dart xử lý tải/lỗi/retry/thiếu-sai ID, Future mới không hiển thị dữ liệu cũ. widgets/digital_product_edit_form.dart dùng key theo detail để reset controller khi đổi dữ liệu; controller dispose khi rời màn. Chỉ nhập tạm tên/mô tả/giá, Hủy bỏ nội dung; Lưu/Thay tệp vẫn khóa. Chưa validation lưu, upload, persistence hoặc entitlement.

## Admin A15.1

features/conversations/data/admin_conversations_source.dart chứa DTO hội thoại/tin nhắn bất biến, source fetch chỉ đọc và ba fixture P2. messages=null là chưa có lịch sử, [] là đã biết chưa có tin; chỉ fixture đầu có nội dung mẫu. App nhận conversationsSource và truyền qua access page/shell tới AdminConversationsPage; route /conversations, sidebar thêm Hội thoại bằng icon P2 đã có.

presentation/admin_conversations_page.dart quản lý Future, controller tìm kiếm, ID chọn; Future mới che dữ liệu cũ, retry cùng source. Tìm trên tên/email/mã yêu cầu đã biết, chọn trong tập kết quả hiện tại. widgets/conversations_list.dart và selected_conversation.dart tách danh sách/vùng xem; conversation_styles.dart giữ palette/card/nút của frame. Controller dispose khi rời màn. Khung trả lời/nút gửi/đánh dấu xử lý khóa, không có port ghi hoặc dịch vụ nhắn tin/AI. Không ghép dữ liệu khách hàng/Custom bằng tên.

## Sidebar admin dùng chung

shared/layout/admin_sidebar.dart tổ chức nhóm/menu/quyền chọn route; admin_sidebar_item.dart chứa AdminSidebarIcon và AdminSidebarSubitem. Chữ chính 16px, con 14px; các icon từ cùng sidebar P2 2038:9, ColorFiltered tint theo trạng thái và căn trong slot 24px. Không sửa SVG hay thêm asset/package. Menu con dùng cùng TextButton style, giữ key điều hướng cũ và semantics, Chatbot chưa khả dụng có onPressed=null. Desktop và Drawer dùng cùng component; sidebar/footer giữ 256px và cuộn menu khi thiếu chiều cao.

## Admin A15.2

features/conversations/data/admin_chatbot_source.dart chứa AdminChatbotScenario bất biến, port fetch chỉ đọc và fixture P2 sáu trường; null record/trường/trạng thái được phân biệt, enabled chỉ là trạng thái hiển thị mẫu. AdminApp.chatbotSource truyền qua access page/shell, route /conversations/chatbot. Sidebar mở nhóm Hội thoại cho cả tin nhắn/chatbot, key admin-nav-chatbot mở page và chọn đúng mục.

presentation/admin_chatbot_page.dart quản lý Future tải/rỗng/lỗi/retry, che snapshot cũ khi đổi nguồn; widgets/chatbot_scenario.dart render sáu giá trị không input/toggle. Dùng lại conversation_styles.dart cho text/card/nút bị khóa. Không có controller nhập, port ghi, công thức tính len, API/AI hoặc kết nối customer. Sau A15.2 nhãn Chatbot trong sidebar đã mở UI chỉ đọc, thay trạng thái chưa khả dụng của bước sửa sidebar trước.

## Admin A12.1

features/abandoned_carts/data/admin_abandoned_carts_source.dart chứa DTO/query/result, port fetch chỉ đọc và 4 fixture P2. Tìm tên/liên hệ trước phân trang 4 dòng, giữ thứ tự nguồn/tổng thực; không tính thời gian bỏ quên hoặc liên kết customer. Nullable số lượng/giá/metadata phân biệt với0. App.abandonedCartsSource truyền tới page qua access page/shell; route /marketing/abandoned-carts, sidebar nhóm Marketing.

presentation/admin_abandoned_carts_page.dart giữ Future theo query/source, controller tìm kiếm và trang retry; chỉ render snapshot done, bỏ nội dung cũ trong khi tải. widgets/ tách header/filters/table/styles; table có ScrollController ngang và dispose, AdminListPagination dùng chung. Header ngoài vùng cuộn, footer/control wrap khi hẹp. Sắp xếp/lọc thời gian/chọn hàng loạt/Gửi nhắc/Voucher khóa, chưa API ghi/retention/marketing consent/persistence. Thông tin sản phẩm chỉ là preview, không dựng chi tiết giả hoặc tính lại giá từ tên.

## Admin UI A09.1

features/coupons/data/admin_percentage_coupon_source.dart chứa DTO mẫu hiển thị bất biến/port fetch/mock; không có ID mã đã lưu, port ghi hoặc tính ưu đãi. code/quota/expiry nullable, ngày là nhãn mẫu chưa có timezone. App.percentageCouponSource truyền qua access page/shell; route /marketing/coupons/percentage và menu con Marketing.

presentation/coupon_example_page.dart giữ Future, tải/rỗng/lỗi/retry và che snapshot cũ cho cả hai page phần trăm/tiền cố định; widgets/coupon_sections.dart dùng chung nhóm trường và nhóm chọn điều hướng, cùng header/footer/field/styles. CouponReadonlyField phân biệt giá trị/null/placeholder bằng semantics, không dùng TextField hoặc date picker. CouponHeader/Footer ở ngoài vùng cuộn, footer Tạo/Lưu khóa; Cancel và breadcrumb replace route về /marketing. Không persistence, cấp/nhận/redeem, liên kết voucher customer hoặc engine khuyến mãi.

## Đối chiếu admin P2

docs/ADMIN-UI-AUDIT.md ghi kết quả 18 frame, các lỗi đã sửa và khác biệt còn lại. DashboardSnapshot bổ sung products bất biến và DashboardProductPreview; dashboard_products.dart render bốn card P2, ảnh gốc giữ nguyên dù tên/ảnh bất nhất; Xem tất cả chỉ mở catalog, card không ghép sản phẩm bằng tên. Bộ lọc/phân trang chỉnh density riêng admin, không đổi theme shared hoặc customer.

scripts/audit-admin-browser.mjs dùng HTTP local và Edge headless/profile riêng để đăng nhập bằng fixture đọc từ source rồi click qua 18 màn; ảnh/log trong .design/ui-audit (gitignore). Script không chỉnh tài khoản hoặc gọi dịch vụ ngoài; có thể chạy lại sau flutter build web bằng node scripts/audit-admin-browser.mjs after. Không cần package npm bổ sung.

## Admin A11.1

features/settings/data/admin_settings_source.dart chứa AdminGeneralSettings nullable theo trường và port fetch chỉ đọc/mock có failNext/null. presentation/admin_settings_page.dart giữ future theo source, tải/rỗng/lỗi/retry và tránh dữ liệu future cũ; header/footer riêng, vùng nội dung cuộn giữa. widgets/settings_sections.dart render giao diện/thông báo, mã màu #RRGGBB có guard, toggle chỉ báo trạng thái nullable, mọi thao tác ghi bị khóa. settings_styles.dart dùng palette admin và asset node 6148. AdminShell chọn /settings qua guard sẵn có. shared/widgets/admin_dashed_border.dart dùng chung settings/composer; không đổi render composer hoặc thêm package. Không có setter/backend/theme mutation/quyền thông báo.

## Admin UI A10.3

app/admin_article_navigation.dart đánh dấu origin để Back từ composer pop về list giữ tìm/lọc/trang; direct URL về /marketing. AdminAccessPage nhận /marketing/articles/new, shell vẫn chọn Marketing và render AdminArticleComposerPage. Page giữ TextEditingController tiêu đề/nội dung và lựa chọn danh mục cục bộ, dispose khi rời màn; không gọi source ghi hoặc tạo nháp. widgets/article_composer_header/editor/sidebar/styles.dart tách bố cục P2 9969. TextField văn bản thuần, toolbar/upload/Đăng/Lưu bị khóa. ArticlesFilters mở route qua Thêm mới. Không đổi DTO/source bài viết; Tin tức chỉ là lựa chọn nhập tạm chờ chốt taxonomy.

## Admin A10.2

features/articles/data/admin_articles_source.dart chứa enum/DTO/query/result/port chỉ đọc, 8 fixture riêng và failNext. presentation/admin_articles_content.dart điều phối tìm/lọc/phân trang, debounce/chống kết quả muộn và các trạng thái dữ liệu. widgets/ gồm article_styles, articles_tabs/header/filters/table. Bảng có scrollbar ngang riêng, tác giả/ngày nullable; không chứa body bài viết. Dùng chung AdminListPagination và list styles. AdminShell map destination marketing (/marketing) vào header/content mới qua guard sẵn có; sidebar A01 giữ nguyên. Thêm/Sửa/Xóa và tab Banner bị khóa, chưa API ghi/editor/upload/publish/sync customer. A10.1 cấu hình banner chưa code theo lựa chọn của chủ dự án.

## Admin A08.2

features/reviews/data/admin_review_statistics_source.dart chứa DTO/query/result/source chỉ đọc và năm snapshot P2. Mỗi snapshot tham chiếu AdminProduct từ adminProductFixtures bằng SKU; không ghép đánh giá theo tên hoặc tạo thuật toán xếp hạng. presentation/admin_review_statistics_content.dart xử lý tìm/lọc/phân trang/debounce/kết quả muộn và trạng thái dữ liệu. widgets/review_statistics_header.dart, review_statistics_filters.dart, review_statistics_table.dart dùng asset 8805, bảng có scrollbar ngang riêng. Dùng AdminListPagination chung. AdminDestination.reviewStatistics map /reviews/statistics qua guard/shell, sidebar có mục con khi đang xem reviews/statistics. Chưa API/export/lọc kỳ/moderation/sync customer.

## Admin A08.1

features/reviews/data/admin_reviews_source.dart chứa DTO/query/result/port chỉ đọc và 8 fixture riêng. presentation/admin_reviews_page.dart điều phối tìm/lọc/phân trang, debounce/guard kết quả cũ, tải/rỗng/lỗi/retry và cuộn đầu khi chuyển trang. widgets/reviews_header.dart và review_card.dart dùng asset node 5597, không thêm thư viện. Pagination dùng AdminListPagination chung. AdminDestination.reviews map /reviews qua guard/shell; sidebar có mục con dưới Sản phẩm khi chọn products/reviews. Nút Duyệt/Ẩn bị khóa; không có API ghi, ownership hoặc sync store customer.

## Admin A07.2

features/customers/data/admin_customer.dart tách DTO/vai trò/trạng thái; admin_customer_detail.dart chứa metadata nullable. admin_customers_source.dart export DTO cũ, cung cấp detail(id) từ cùng danh sách. AdminApp.customersSource truyền qua guard/shell tới list/detail; không đọc store customer hoặc ghép đơn bằng tên/SĐT.

app/admin_customer_navigation.dart giữ origin để pop về list còn nguyên truy vấn/trang; URL trực tiếp fallback /customers. presentation/admin_customer_detail_page.dart điều phối guard/loading/error/retry/kết quả muộn; widgets/customer_detail_cards.dart hiển thị cá nhân/tài khoản/lịch sử chỉ đọc. shared/widgets/admin_detail_card.dart dùng chung chi tiết đơn/người dùng. Các trường chưa có liên kết báo thiếu; lịch sử chưa triển khai dữ liệu, thao tác ghi bị khóa.

## Admin A07.1

features/customers/data/admin_customers_source.dart chứa DTO/query/result/port chỉ đọc và 10 fixture, vai trò khách hàng/nhân viên và trạng thái mẫu. presentation/admin_customers_content.dart điều phối debounce, tìm/lọc/phân trang/loading/empty/error/retry; widgets/ tách header/filters/table/styles. Tái sử dụng AdminListPagination và admin_list_styles. /customers chọn sidebar chung và header riêng P2 8502. Chưa API ghi, chi tiết, thay quyền hoặc đồng bộ profile customer.

## Customer - chọn dòng giỏ (FE)

LenlabStore giữ tập key dòng bỏ chọn; mặc định dòng hiện có/mới thêm được chọn. `isCartLineSelected`/`toggleCartLine` và `checkoutLines`/`checkoutSubtotal`/`checkoutDiscount` phục vụ UI mua hàng; `cart`/`subtotal`/`discount` vẫn biểu diễn toàn giỏ cho các consumer cũ. Key gồm product ID và variant, nên hai biến thể chọn độc lập. Xóa dòng dọn lựa chọn; thay số lượng không tự chọn lại dòng đã bỏ chọn.

CartItemCard có semantics checked và vùng chạm cũ; CartSummary dùng tổng được chọn, CartCheckoutButton khóa khi lựa chọn rỗng. AddressPage/OrderReviewPage/PaymentMethodPage/BankTransferPage đọc chung checkoutLines/tổng được chọn, phân biệt giỏ rỗng với chưa chọn dòng. Future quote key chứa các dòng được chọn, tránh dùng quote toàn giỏ. submitCodOrder chụp CodOrderDraft từ các dòng này; khi thành công chỉ loại key đã mua, thất bại giữ nguyên giỏ/lựa chọn, đang gửi khóa sửa qua store. Coupon fixture vẫn theo công thức cũ và được dọn sau thành công như trước. API backend/gateway/guest checkout không đổi; legacy placeOrder không được customer UI gọi.

## Customer - FE Mua lại

features/orders/data/buy_again_source.dart đọc port products theo ID đơn cũ, trả lựa chọn catalog hiện tại hoặc lý do không khả dụng; không fallback theo tên, tự tạo Product hay API ghi. Các dòng cũ cùng product ID gộp thành một điểm mở detail vì khách chọn lại variant/quantity. Source giữ giá/stock/published hiện tại; không tự giảm số lượng đơn cũ theo tồn.

presentation/buy_again_dialog.dart quản lý tải/lỗi/retry/chọn/đóng. Một lựa chọn hợp lệ tự trả Product; nhiều lựa chọn dùng dialog cuộn theo theme P2, unavailable bị vô hiệu. Sau đóng, caller còn mounted và đơn còn Đã giao mới mở /product với chính Product hiện tại. Kết quả sau khi đóng dialog không tự điều hướng. OrderListCard có state khóa nút Mua lại trong lúc lookup; style nút và footer card giữ nguyên. Không thêm giỏ cho đến khi khách tự thao tác detail; không tái tạo đơn hoặc payment.

## Customer - C03 sổ địa chỉ và selection mark

features/address_book/data/address_book_actions.dart có port remove/setDefault và MockAddressBookActions, tách khỏi source load. Chỉ mock.operation và store.addresses, kiểm tra signedIn sau độ trễ/địa chỉ cũ còn tồn tại, cấm xóa mặc định. Đổi cờ dùng bản Address bất biến mới, không sửa đối tượng snapshot checkout/đơn. address_editor_source.dart lưu cờ mặc định từ form, chuẩn hóa các cờ khác khi người dùng chọn mặc định; không tự đặt địa chỉ đầu tiên hoặc tắt địa chỉ đang mặc định.

AddressBookPage nhận actions để kiểm thử/tích hợp adapter sau; xác nhận trước xóa, khóa khi gửi, lỗi có retry và tải lại khi record cũ. Thành công dùng danh sách trả về để cập nhật UI. Editor giữ makeDefault local đến khi Save, có validation giữ ít nhất địa chỉ đang mặc định nếu chưa chọn thay thế. Không tự đổi deliveryAddress và không auto-fill checkout mới trong C03.

shared/widgets/selection_mark.dart là visual CustomerSelectionMark: nền trắng, viền/dấu tích P2.brown, dùng asset tick P2 giỏ không nền. CartItemCard/AddressBookCard/PaymentMethodOption dùng chung; parent quản lý vùng bấm/checkbox/radio semantics. Không đổi Switch, theme admin hoặc asset gốc.

## Customer - C04 sheet biến thể Merino

features/products/presentation/widgets/merino_variant_sheet.dart chứa MerinoSelection (color/size/quantity) và sheet P2 2034:5. Chỉ cho Merino vì chưa dữ liệu lựa chọn/SKU sản phẩm khác. ProductDetailPage.chooseVariant mở modal với selection hiện tại; existingQuantity đọc giỏ cùng product ID/variant, confirm kiểm tra stock và trạng thái gửi COD/published trước khi ghi mock. Hủy không commit; confirm thêm giỏ và trả selection để cập nhật detail. Be/Be tự nhiên hiển thị theo P2 nhưng lưu key Kem như luồng cũ.

Sheet cuộn trong 94% chiều cao, SafeArea và wrap khi hẹp/chữ lớn; không dùng screenshot làm asset. Nút và text dùng font BeVietnamPro rõ ràng. Không sửa model catalog hoặc tự tạo SKU/tồn/giá từng biến thể. Tests ở variant_sheet_test.dart, render merino-variant-390/360-text120.png.

## Customer - C05 avatar trong bộ nhớ

image_picker 1.2.4 chỉ nằm ở apps/customer; packages/shared không phụ thuộc plugin. avatar_picker_source.dart định nghĩa AvatarPickerSource pick/recover, GalleryAvatarPicker đọc gallery requestFullMetadata=false, decode bằng codec trước dùng và trả bytes; codec/frame được dispose. main.dart gọi startRecovery một lần Android; editor consume ảnh phục hồi để xem trước, không auto-save. Native recovery không chặn startup nếu lỗi, editor có thông báo chọn lại.

ProfileEditorPage.avatarPicker injectable; avatarBytes draft độc lập với store, hai điểm chọn cùng callback, khóa picker/lưu khi đang chọn. Cancel/Back không lưu; mounted/signedIn/actor kiểm tra trước cập nhật. MockProfileEditorSource.save nhận optional avatarBytes; null giữ ảnh cũ, bytes mới được copy/unmodifiable và decode, commit sau operation saveProfile cùng các trường đã rõ. Không có thao tác xóa ảnh mới, upload/crop/camera hoặc persistence.

CustomerProfile/ProfileDraft/ProfileSummary bổ sung avatarBytes, giữ String avatar legacy cho asset P2. ProfileAvatar ưu tiên Image.memory, cover trong ClipOval, cache decode theo kích thước màn; file lỗi có placeholder. ProfilePage và DrawerIdentity dùng cùng bytes. Không đưa nội dung file vào log, không dùng đường dẫn file tạm làm asset. iOS Info.plist khai báo NSPhotoLibraryUsageDescription, không thêm quyền camera/microphone/storage rộng cho gallery.

Test: avatar_test.dart có lỗi/quyền/cancel/retry/draft/late result/recovery và đồng bộ ảnh; hai golden avatar-preview. Thư viện tham khảo: [image_picker](https://pub.dev/packages/image_picker). Khả năng quyền/HEIC/process death cần kiểm thử thiết bị thật, iOS trên macOS/Xcode.

## Customer - C06 ảnh đánh giá sau mua

Shared data/review_photo.dart có ReviewPhoto(bytes copy/unmodifiable), maxReviewPhotos=5, maxReviewPhotoBytes=5*1024*1024 và kiểm tra signature JPG/PNG/giới hạn. Store.submitProductReview nhận photos, snapshot List trước await; ReviewDraft/ProductReview.localPhotos bất biến, giữ photos asset cũ tương thích. imageCount/withImages dựa hasImages gồm hai nguồn. Port ghi đánh giá mock vẫn không upload/backend.

features/reviews/data/review_photo_picker.dart đọc gallery bằng image_picker.pickMultiImage(limit:remaining,requestFullMetadata:false); file.length kiểm tra trước readAsBytes. Form nhận photoPicker injectable, validate batch/codec trước add, xóa từng ảnh; token/orderId/productId/actor bảo vệ callback muộn, clear khi chuyển sản phẩm/đơn. Lỗi giữ draft, busy khóa gửi/chọn. widgets/review_photo_input.dart render previews/count/remove; review_card.dart dùng Image.memory cho ảnh mới, asset node cho fixture cũ.

shared/data/local_image_validation.dart dùng codec kiểm tra và dispose resources, dùng chung avatar/review. shared/data/gallery_selection_context.dart chỉ lưu purpose avatar/review vào file cache app, không lưu ảnh/đơn/PII; finally dọn marker. Native avatar recovery kiểm tra purpose trước consume, ảnh review không auto-restore vì chưa có draft order/product persistent để chứng minh liên kết. Không gán ảnh review vào profile sau process death.

Test review_photos_test.dart/review_photo_test.dart và chống cross-recovery trong avatar_test.dart; thêm 2 golden review-photos, đổi2 golden write-review. Không thêm dependency ngoài image_picker đã có từ C05. Cần thử gallery permission/limit trên thiết bị thật.

## Admin UI A09.2

features/coupons/data/admin_fixed_coupon_source.dart có DTO AdminFixedCoupon/port/mock riêng; các trường chung bất biến ở admin_coupon_fields.dart. App.fixedCouponSource truyền qua access page/shell, route /marketing/coupons/fixed dùng AdminFixedCouponPage. Fixture amount=50000/minimumOrder=0/startDateLabel=12/05/2024; code/quantityLimit/expiryDateLabel chưa có. Không ID mã lưu, API ghi hoặc engine khuyến mãi. Nhóm chọn loại chỉ điều hướng replace giữa hai mẫu, không sửa dữ liệu; sidebar giữ một mục Mã giảm giá. Field số tiền toàn hàng, không trường cap phần trăm.
