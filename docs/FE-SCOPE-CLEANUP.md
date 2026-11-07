# FE scope cleanup - 04/11/2026

Yêu cầu cleanup mới nhất thay thế phạm vi FE cũ khi có mâu thuẫn. Không triển khai API/backend/database/Gemini/VNPay trong lượt cleanup.

## Trước khi sửa

- Workspace không có Git repository: `git status`/`git rev-parse` báo not a git repository; không tạo nhánh hoặc tự git init.
- Đã sao lưu nguồn, tests/goldens, tài liệu và cấu hình ứng dụng vào `.design/cleanup-backups/pre-scope-cleanup-20261104-175130.zip`, kiểm tra CRC và SHA-256 từng file (manifest trong ZIP). Không xóa asset gốc không thể phục hồi.
- Baseline qua Dart MCP: customer 329, admin 229, shared 36 tests passed.
- Kiến trúc giữ nguyên: Flutter customer/admin, ChangeNotifier/InheritedNotifier, feature Source và repository mock. Không thay state management; gỡ dependency `fl_chart` sau khi bỏ biểu đồ.

## Audit ảnh hưởng trước thay đổi

| Feature | File/module liên quan | Phụ thuộc | Quyết định | Nguy cơ regression |
| --- | --- | --- | --- | --- |
| Blog, bài viết, mua nhanh Blog | Customer features/blog; HomeArticles/homeArticles/article_metadata; admin features/articles và article navigation | Drawer/footer/Home; admin shell/sidebar; visual tests | REMOVE | Menu, khoảng trống Home, route bài cũ, golden shell |
| Sản phẩm số, PDF/video/e-book | Catalog digital branch; products/pdf_*; admin digital_products | Product.format/digital, seeded catalog/order/review, navigation, tests | REMOVE | Chọn nhầm sản phẩm, count/order fixtures, product layout |
| Library và digital checkout | features/library; digital_checkout_preview_page | Profile entry, Order.canDownload, legacy repository.download | REMOVE | Profile layout, review tests dùng seed digital |
| Biên lai | Order.proof/Attachment, submitProof/confirmPayment, proof states và legacy placeOrder | Bank preview, order state tests | REMOVE chỉ phần proof/download/legacy không còn callsite | Không được xóa CustomRequest.image, review photos hoặc trạng thái thanh toán vật lý |
| Giỏ hàng bỏ quên | Admin features/abandoned_carts | Shell/sidebar/routes/tests | REMOVE | Không được ảnh hưởng cart customer |
| Dashboard nâng cao | DashboardCharts, revenue/pie fields; review_statistics | Dashboard basic metrics/products; shell/sidebar/tests | REMOVE biểu đồ/phân tích nâng cao, KEEP tổng quan cơ bản | Không dọn shared typography/icon chung theo tên file |
| Marketing | Article/banner/abandoned links | Coupon type selector và route | REMOVE công cụ ngoài scope; KEEP voucher trực tiếp | Không được xóa voucher hoặc widget form dùng chung |
| Auth/profile/catalog/cart/address/COD/bank/voucher/orders/reviews | Các feature MVP, lenlab_shared | Shared models/theme/assets | KEEP | Không thay màu/layout phần không liên quan |
| Chatbot/Custom/ảnh mẫu | PendingPage /chat,/customs; CustomRequest/customs; admin conversations | Avatar/review gallery helper không phải proof | KEEP (chưa có nghiệp vụ thật) | Không xóa ảnh mẫu hoặc hứa đã tích hợp Gemini |
| Settings/appearance/customer management/about/FAQ/comments | UI hiện có, một số chưa rõ phạm vi | Shell, support, public content | NEED APPROVAL để xóa; giữ nguyên | Không tự loại chỉ vì không được liệt kê MVP |
| Asset bundle/generated Figma mapping | assets/figma, asset_files.dart | Nhiều frame/components/tests dùng chéo | DEFER xóa asset khi chưa chứng minh độc lập | Xóa theo tên/frame có thể phá icon dùng chung |
| AI nhận diện/C2C/gamification | Quét lib/routes/models | Không tìm thấy implementation chuyên biệt | Không có code cần loại | Không nhầm Gemini/Custom thành image recognition |

## Kết quả

Đã gỡ mã nguồn chuyên biệt của Blog, sản phẩm số/thư viện/checkout số, upload/xác nhận biên lai, giỏ bỏ quên, thống kê đánh giá và biểu đồ dashboard nâng cao. Dashboard giữ metric cards và preview sản phẩm. Không tìm thấy AI nhận diện/C2C/gamification để gỡ.

| Ứng dụng | Route bị loại | Xử lý hiện tại |
| --- | --- | --- |
| Customer | `/blog`, `/article`, `/digital`, `/library`, `/digital-checkout` | Fallback không tìm thấy trang; không mở luồng mua khác |
| Admin | `/marketing`, `/marketing/articles/new`, `/digital-products`, `/digital-products/edit`, `/marketing/abandoned-carts`, `/reviews/statistics` | Không tìm thấy trang; bỏ menu/nhánh điều hướng chuyên biệt |
| Admin voucher | `/marketing/coupons/percentage`, `/marketing/coupons/fixed` | Thay bằng `/vouchers/percentage`, `/vouchers/fixed`; sidebar Mã giảm giá; không giữ alias Marketing |

`Product.format/digital`, `Order.digital/canDownload`, model ảnh biên lai và API mock gửi/xác nhận biên lai/tải nội dung đã bỏ. Dữ liệu mock còn sản phẩm vật lý và bốn đơn mẫu vật lý. `PaymentState.pending`, `pendingConfirmation`, `confirmed`, `failed`, `cod` chỉ là trạng thái FE mock; chưa phải contract NestJS đã duyệt. Không đổi `QuoteState` hoặc ảnh Custom. Avatar/ảnh đánh giá vẫn giữ.

Danh sách file thay đổi/xóa và SHA-256: FE-SCOPE-CLEANUP-FILES.md (`docs/FE-SCOPE-CLEANUP-FILES.md`; local-only; not distributed with this repository). Backup trước cleanup vẫn giữ nguyên trong `.design/cleanup-backups/`.

## Kiểm tra hồi quy

Kết quả cuối qua Dart MCP: **customer 289, admin 164, shared 32 tests passed (485 tổng cộng)**; analyzer cả ba project không báo lỗi. Bộ test có navigation, loading/empty/error, mock checkout/cart/address/review và golden. 11 test mới xác minh deep link của các chức năng bị loại không mở được luồng cũ. Test biên lai/thư viện/sản phẩm số/Blog chuyên biệt bị loại tương ứng, không bỏ test MVP để làm bộ test xanh.

Chỉ cập nhật **28 ảnh** có thay đổi đúng phạm vi: Drawer, Profile, Home đầy đủ, danh sách đơn vật lý; sidebar admin, breadcrumb voucher và dashboard bỏ biểu đồ. Đã xem ảnh kết quả và kiểm tra bounding box pixel: các trang admin sản phẩm/đơn/khách/đánh giá/cấu hình/hội thoại/chatbot chỉ đổi vùng sidebar (x < 256), nội dung trang không đổi. Home full chỉ đổi từ phần Blog/footer trở xuống; bốn thẻ đơn vật lý giữ nguyên, loại thẻ đơn số cuối. Ảnh màn MVP khác tiếp tục so sánh baseline cũ và đạt. Đây là kiểm tra hồi quy, không khẳng định pixel-perfect với Figma.

Runtime: chạy admin Web local, hot reload qua DTD thành công; Playwright đăng nhập fixture, mở tổng quan → voucher `/vouchers/percentage` → sản phẩm `/products`, không có console error trong phiên kiểm tra. Chưa smoke test toàn bộ browser flow; widget tests cung cấp phần kiểm tra rộng hơn. Flutter web-server chạy ở cổng 8087, Edge debug ở 8088; Windows chặn cổng thử nghiệm 58761 nên đổi cổng, không sửa cấu hình mạng.

Cảnh báo SVG `<filter/>` đã có trước cleanup; các log lỗi picker trong test là tình huống lỗi chủ động. Không phát hiện regression trong bộ kiểm tra đã chạy. Chưa kiểm tra native trên thiết bị thật.

## Chuẩn bị tích hợp sau cleanup

- Giữ mock mode độc lập; không gọi REST, ngân hàng, Supabase hoặc Gemini trong lượt này.
- Customer: thay `LenlabRepository` và các feature Source bằng adapter API sau khi thống nhất DTO. Repository hiện tại chưa bao phủ mọi thao tác; nhiều thay đổi giỏ/địa chỉ/profile/đơn nằm trong `LenlabStore`, cần tách port tương ứng khi tích hợp, không thể chỉ đổi một class repository là có backend.
- Backend cần cung cấp: auth/session/RBAC, catalog + variant/SKU/tồn, giỏ, địa chỉ, quote checkout + voucher, tạo/đọc đơn, trạng thái thanh toán, VNPay callback/webhook và idempotency. FE không xác nhận thanh toán bằng redirect hay ảnh.
- Chuyển khoản vẫn chỉ xem dữ liệu mẫu/QR minh họa. VNPay chưa có UI/provider integration hoàn chỉnh; không bị loại khỏi MVP nhưng chưa được triển khai trong cleanup. Cần DTO khởi tạo giao dịch, URL chuyển hướng, truy vấn trạng thái và điều hướng trở lại app.
- Admin: giữ các Source auth/products/orders/customers/reviews/coupons/settings/conversations/chatbot. Phần voucher và nhiều màn quản trị vẫn chỉ đọc theo implementation cũ; cleanup không bổ sung CRUD.
- Chatbot/Custom giữ điểm vào và dữ liệu hiện có. Gửi yêu cầu Custom/ảnh mẫu và chat Gemini thật cần contract riêng, không tự bỏ hoặc tự triển khai.

## Chưa xử lý / cần duyệt

- Chưa xóa settings, appearance, quản lý khách hàng, about/FAQ/comments/reviews vì không có quyết định loại rõ ràng.
- Chưa xóa asset Figma và generated asset map: có tham chiếu dùng chéo; cần audit riêng trước khi thu nhỏ bundle.
- Các backlog/audit/thiết kế backend cũ là lịch sử, không phải lệnh khôi phục Blog/digital/Marketing. Phạm vi mới trong tài liệu này được ưu tiên.
- Chưa kiểm tra APK/iOS trên thiết bị thật trong lượt cleanup; kiểm thử desktop widget/golden không thay thế kiểm thử native.
