# Checklist customer - 23/10/2026

> Scope update 2026-11-04: This document contains historical milestones. For the current FE scope, removals and remaining integration work, use [FE-SCOPE-CLEANUP.md](FE-SCOPE-CLEANUP.md). Blog/digital products/advanced marketing are excluded; do not restore them from this history.

Phạm vi: Flutter iOS/Android customer. Đối chiếu danh mục frame trực tiếp từ Figma MCP trang **P2 - User `2026:2`**, bảng route, các nơi gọi điều hướng và test hiện có. Không sửa Figma. Đây là kiểm kê UI/điều hướng, không phải xác nhận khớp pixel toàn bộ, chạy native hoặc nghiệp vụ production. Admin không thuộc lượt rà soát này.

Nguồn thiết kế: [P2 User](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-2). Quyết định mới nhất của chủ dự án ưu tiên hơn copy/quy trình cũ trong thiết kế. 360/430px, chữ lớn và bàn phím là ca kiểm tra thích ứng, không phải chức năng riêng.

**Rà tương tác mới nhất (24/10/2026):** xem [CUSTOMER-INTERACTION-AUDIT.md](CUSTOMER-INTERACTION-AUDIT.md). Có ma trận từng màn: thao tác hoạt động, lưu mock, nút chỉ thông báo và màn tạm; 279 test customer qua, analyze sạch. Không thay đổi UI/nghiệp vụ trong lượt rà này.

**Bổ sung FE giỏ:** chọn/bỏ chọn từng dòng đã hoạt động; tổng và checkout theo lựa chọn, không chọn gì khóa Thanh toán. COD mock chỉ xóa các dòng đã mua, giữ phần chưa chọn. Voucher và menu giỏ vẫn chưa tích hợp. Quyết định chỉ làm frontend: chưa tạo kho tài khoản/xác thực/backend cho C01.

**Bổ sung FE Mua lại:** đã mở detail sản phẩm hiện tại để khách chọn lại, đơn nhiều sản phẩm có hộp chọn; kiểm tra catalog/ẩn/hết hàng/thiếu dữ liệu, tải/lỗi/retry. Không tự thêm dòng từ đơn cũ. 297 test customer qua, analyze sạch, hai render mới đã xem; chưa chạy native thật.

**Bổ sung C03 và checkbox:** xác nhận xóa địa chỉ không mặc định, đổi mặc định trên card hoặc lưu form; có khóa gửi/lỗi/retry, giữ checkout draft và đơn cũ. Checkbox giỏ/sổ địa chỉ/phương thức dùng chung nền trắng, viền/dấu tích nâu. 306 test customer qua, analyze sạch; chưa thử native thật.

**C04:** sheet biến thể P2 `2034:5` đã có ở nút Thêm vào giỏ trên detail Merino; màu/size/số lượng/tổng/confirm/cancel. Chỉ mock Merino, label Be lưu cùng key Kem hiện có; chưa SKU/tồn theo biến thể thật. Avatar đã bỏ qua, không đề xuất lại.

**C05 - avatar đã mở lại:** gallery → xem trước trong Sửa hồ sơ → Lưu mock, đồng bộ Hồ sơ/Drawer. Hủy không đổi ảnh cũ, lỗi giữ draft; chưa upload/persistence/backend. 321 test customer/33 shared qua, analyze customer sạch; chưa thử picker native thật. Quyết định này thay ghi chú bỏ qua avatar ở C04.

**C06 - ảnh đánh giá:** tối đa 5 JPG/PNG, mỗi ảnh5MB, chọn/preview/bỏ ảnh/gửi cùng đánh giá mock. Lỗi giữ draft, đổi sản phẩm không mang ảnh cũ; list và lọc Có hình ảnh hiển thị ảnh bộ nhớ. Chưa upload/persistence; multi-picker native cần thử thực tế. 328 test customer toàn bộ +1 test recovery riêng, 36shared qua, analyze workspace sạch.

## Các màn đã có và giới hạn

| Nhóm / node P2 | Điểm vào hiện tại | Đã có / còn thiếu |
| --- | --- | --- |
| Đăng nhập `3`, đăng ký `59`, lỗi/tải `2032:2/57/113` | `/login`, `/register` | UI, validation, phiên mock. Quên mật khẩu/Google chưa tích hợp; popup thành công `4334` chưa được xác nhận khớp riêng. |
| Menu `338/413` | Drawer Home/catalog | Đã căn hai menu P2: sáu mục chính, login/register, mở hồ sơ/logout và footer riêng. Runtime đọc tên/avatar hồ sơ, version 1.0.0; nội dung cuộn, close/scrim/Back hoạt động. Nền phía sau dùng app thật, chưa blur scrim. |
| Home `664` | `/` | Các section, liên kết sản phẩm/bài viết/giới thiệu. Footer lấy năm hiện tại từ thiết bị; fixture golden cố định 2026 để kiểm tra hình ảnh ổn định. |
| Catalog `499`, trạng thái `2032:183/352/521`, biến thể `2034:5` | `/products` | Tìm/lọc/sắp xếp/phân trang/trạng thái. Sheet `2034:5` đã nối từ Thêm vào giỏ trên detail Merino, nút + catalog vẫn mở detail; dữ liệu SKU còn thiếu. |
| Detail vật lý `869` | `/product` + Product | Layout chung theo Merino, số lượng/thêm giỏ/yêu thích mock. Ảnh bổ sung/hướng dẫn đo chưa có; chưa có danh sách yêu thích riêng. |
| Đánh giá `1037`, bình luận `120` | `/reviews` + product ID, `/write-review` + order ID | Đã có danh sách/lọc/sắp/trạng thái; 4 nhận xét Merino và 1 Dino theo P2. Nguồn shared/store thống nhất summary giữa các màn; ngày/helpful Dino chưa có thì báo thiếu, không tự gán đã mua. Đã gửi đánh giá sau mua vào nguồn chung trong bộ nhớ qua `/write-review` + order ID; chưa backend/hữu ích/ảnh thật. Bình luận đã có `/comments` + ID, 4 dòng Merino/1 phản hồi shop, loading/rỗng/lỗi/retry; chờ chốt vị trí mở từ detail. |
| Giỏ `1325`, guest `1270`, đã thêm `2056:1189` | `/cart` | Cập nhật/xóa/chọn từng dòng, tổng và checkout theo lựa chọn; COD mock giữ dòng chưa mua. Popup guest sáng/gọn, nền trắng che sản phẩm theo yêu cầu sau P2; close/later/Back giữ dữ liệu, CTA login. Chưa chốt gộp giỏ/checkout guest; voucher/menu giỏ chỉ báo chưa hỗ trợ. |
| Giao hàng `1432`, lỗi `2040:11` | `/checkout` | Form/validation/dữ liệu địa chỉ mock, chuyển tổng quan. |
| Tổng quan `1520`, phương thức `1627/4863`, COD `1691` | `/order-review`, `/payment-method`, `/cod-confirmation` | Luồng COD mock đã có, khóa khi gửi, lỗi/retry, tạo đúng đơn và mở đúng chi tiết. Chưa là thanh toán/backend thật. |
| Chuyển khoản `1768/4348/4428/5194`, lỗi/từ chối `2056:1020/1108` | `/bank-transfer` | Chỉ preview minh họa. Không phục hồi gửi ảnh hoặc tự tạo trạng thái xác nhận; các frame chứng từ không còn là mục tiêu triển khai theo quyết định mới. |
| Đơn `1852`, rỗng `2056:740`; detail `2009/2143/2273/4930/5064` | `/orders`, `/order-detail` + ID | Lọc, tải/rỗng/lỗi, detail từ cùng nguồn; hỗ trợ giữ mã đơn. Đơn Đã giao có form đánh giá mock từ danh sách/chi tiết; bỏ nút hủy khỏi chi tiết. Mua lại tra catalog hiện tại, mở detail để chọn lại, có hộp chọn khi nhiều sản phẩm. Chi tiết dùng dữ liệu trạng thái chung, chưa xác nhận riêng từng frame là pixel-perfect. |
| Custom `2761/2583/4578/4673/4768` | `/customs` mở màn tạm | Chưa triển khai, chờ chốt quy trình yêu cầu/báo giá/chấp nhận/sản xuất và dữ liệu liên quan. |
| Catalog số `2898`, detail PDF `3032` | `/digital`, `/product` + Product | Đã có template Mẫu móc PDF riêng, metadata Dino/trạng thái từ nguồn tách biệt, một nhận xét P2 dùng chung. Mua ngay truyền Product tới checkout số còn tạm, không thanh toán/tải thật. Video/e-book vẫn layout chung. |
| Checkout số `3162/3282/4505/5278` | `/digital-checkout` mở preview | Đã hiện ảnh/tên/format/giá Product, guard dữ liệu và back; chờ cổng thanh toán/hợp đồng backend; không thêm upload chứng từ hoặc cấp quyền từ frontend. |
| Thư viện `3352`, lỗi tải `2040:103` | `/library` | UI/lọc/tìm/trạng thái, quyền mẫu từ đơn. Runtime có một khóa học hợp lệ. Chưa tải/mở/phát nội dung hoặc cập nhật tiến độ thật. |
| Hồ sơ `244`, sửa `3961`, đã lưu `2056:1368` | `/profile`, editor được push trực tiếp | UI và lưu mock tên/điện thoại/giới tính/ngày sinh/avatar từ thư viện. Email chỉ đọc; password/cài đặt tài khoản chưa có nghiệp vụ, avatar chưa upload/persistence. |
| Sổ địa chỉ `4234`, sửa `3872`, rỗng `2056:913` | `/addresses`, editor được push trực tiếp | Danh sách/thêm/sửa/validation/lưu mock; xác nhận xóa địa chỉ không mặc định, đổi mặc định trên card/form, lỗi/retry. Không sửa checkout draft hoặc snapshot đơn; chưa persistence/API. |
| Voucher `4081` | `/vouchers` | Card đồng bộ theo điều chỉnh đã duyệt; hai bán nguyệt trắng. Chưa áp dụng/nhận/redeem hoặc suy ra điều kiện từ ngày fixture. |
| FAQ `2669` | `/faq`, `/support` + ID tùy chọn | Tìm/lọc/accordion/trạng thái. Chỉ một câu có đáp án P2; liên hệ chỉ thông báo, chưa gửi hỗ trợ thật. |
| Blog `3618`, bài viết `3694` | `/blog`, `/article` + ID | Mở đúng bài, giữ query khi quay lại; bài bảo quản đầy đủ. Các bài khác thiếu thân bài, video/share/sản phẩm trong bài chỉ minh họa. |
| Giới thiệu `3774` | `/about` | Nội dung, hero/giá trị/mục đích/timeline; CTA sang catalog. Nội dung thương hiệu là fixture thiết kế, cần duyệt trước phát hành. |
| Chính sách `3489` | `/policies` mở màn tạm | Chưa có UI. Nội dung đổi trả/bảo mật/điều khoản cần chốt, không biến copy mẫu thành chính sách vận hành. |
| Chatbot `2500/2404/2034:199` | `/chat` mở màn tạm | Chưa có UI chat/ước tính len; nguồn trả lời, công thức và dịch vụ chưa chốt. Footer Liên hệ cũng đang trỏ `/chat`. |

ID không ghi tiền tố là `2026:`. Các frame nền/overlay trang trí không được tính thành chức năng độc lập.

## Phát hiện điều hướng cần xử lý

| Ưu tiên | Phát hiện | Vị trí / cách xử lý đề xuất |
| --- | --- | --- |
| Đã sửa | Icon Tài khoản catalog theo trạng thái phiên hiện tại. | `catalog_header.dart`: signedIn → hồ sơ / guest → login như Home; đã kiểm thử đổi phiên sau khi quay lại catalog. |
| Đã sửa | `/product` đã guard thiếu/sai kiểu arguments. | `customer_app.dart`: chỉ mở detail khi nhận Product hợp lệ; còn lại mở ProductUnavailablePage với thông báo, back và CTA catalog. Không chọn sản phẩm mẫu thay thế. |
| Đã sửa | Xem tất cả nhận xét truyền đúng product ID. | `/reviews` đã có guard; source có Merino/Dino và đánh giá mới gửi mock, các sản phẩm khác rỗng nếu chưa có dòng. |
| Đã sửa | Mua PDF/video/e-book truyền đúng Product. | Detail chung và PDF giữ chính Product khi mở checkout số tạm; có test payload và back. Preview đã hiện thông tin Product, không tạo đơn/entitlement. |
| 2 | Ba route đã được gọi nhưng chưa có nhánh triển khai. | `/customs`, `/chat`, `/policies` còn đi `PendingPage`; `/digital-checkout` đã có preview Product. Đây là chức năng chưa có, không phải route đã hoàn tất. |
| Đã sửa thông báo | Màn tạm có tên/nội dung riêng cho custom/chat/chính sách. | Nêu rõ phần chưa khả dụng, giữ back/về Home; vẫn chưa triển khai nghiệp vụ. Route lạ báo không tìm thấy. |
| Đã sửa | Home/detail `autumn-colors` thống nhất tiêu đề Thu Đông 2026. | Dùng chung AutumnArticleMetadata; giữ năm biên tập cố định và trạng thái chưa có thân bài. Không sửa bài khác. |

Bảng route hiện có 27 nhánh rõ ràng (gồm `/support` dùng lại FAQ). Form sửa hồ sơ/địa chỉ mở bằng MaterialPageRoute trực tiếp nên không bị tính nhầm là route thiếu. Chưa có URL/deep link native hay phân quyền backend. Các guard phiên mock ở Hồ sơ/Địa chỉ/Voucher/Thư viện không thay thế cơ chế bảo mật; danh sách/chi tiết đơn vẫn là bộ mẫu dùng chung.

## Thứ tự task đề xuất

**Ưu tiên mới đã chốt:** viết đánh giá từ danh sách và chi tiết đơn **Đã giao**, cần đăng nhập/mua đúng sản phẩm. Chi tiết đã có nút theo trạng thái và bỏ nút Hủy đơn hàng; form có 1–5 sao bắt buộc, nhận xét/ảnh tùy chọn, lưu mock một lần cho mỗi sản phẩm trong đơn; chưa sửa. Ảnh theo giới hạn C06, chưa upload. Không thêm nút viết đánh giá vào detail sản phẩm. Việc nối trang bình luận chỉ đọc được tạm để lại, không đồng nhất hai luồng.

1. Đã xong: icon tài khoản catalog và guard arguments `/product`; 7 test mới kiểm tra phiên thay đổi, payload null/String/Map, back/CTA và Product vật lý/số hợp lệ. Không đổi giỏ/đơn hoặc giao diện detail hợp lệ.
2. Đã xong danh sách nhận xét chỉ đọc và đồng bộ summary giữa catalog/detail/danh sách từ nguồn shared/store. Đã có form sau mua/lưu mock, chưa hữu ích/ảnh. Bình luận `120` đã có UI chỉ đọc, chờ nối điểm mở sau khi xác nhận vị trí.
3. Đã căn Drawer guest/signedIn theo `338/413`. Điều khoản vẫn màn tạm; các mục đơn/thư viện qua Hồ sơ, route custom/chat còn giữ nhưng không tự thêm ngoài sáu mục P2.
4. Đã có detail mẫu móc PDF `3032`; popup guest `1270` đã triển khai. Không tự chốt luồng thanh toán/phiên guest. Đã sửa truyền Product khi mua video/e-book vào checkout số tạm; trang Bình luận chỉ đọc tiếp tục tạm để lại, không thay form đánh giá sau mua.

Tiếp tục hoãn cổng thanh toán, custom, hủy/hoàn tiền, redeem voucher, download/quyền số, công thức len và chính sách thực tế đến khi có quyết định/hợp đồng tương ứng. Không phục hồi UI minh chứng.

## Kiểm tra lượt này

Đã đồng bộ copyright và ảnh chuẩn ở Bước 25. Theo yêu cầu sau đó, footer runtime lấy `DateTime.now().year`; test tương tác kiểm tra năm hiện tại, riêng golden truyền năm 2026 để tránh đổi ảnh chuẩn khi sang năm. Không đổi năm mẫu ở bài viết hoặc timeline. Các kiểm tra toàn bộ Bước 25 được ghi trong PART-1.md (`docs/PART-1.md`; local-only; not distributed with this repository).

Chưa tap thủ công mọi nút trên thiết bị Android/iOS; kiểm kê route dựa trên code và bộ widget test. Checklist không khẳng định đã hoàn tất tất cả P2 hoặc đã xác minh giao dịch thật.
