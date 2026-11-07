# Đối chiếu UI admin với P2 - 24/10/2026

> Scope update 2026-11-04: This document contains historical milestones. For the current FE scope, removals and remaining integration work, use [FE-SCOPE-CLEANUP.md](FE-SCOPE-CLEANUP.md). Blog/digital products/advanced marketing are excluded; do not restore them from this history.

Đã đọc lại context và screenshot của **18 frame admin đã triển khai** qua Figma MCP, đối chiếu ảnh Flutter và chạy bản build Web trên **Edge headless 1280×1024**. Chưa thể gọi UI hiện tại là giống hoàn toàn: có lỗi UI đã sửa, có phần còn thiếu dữ liệu và có khác biệt theo quyết định trước của chủ dự án. Không sửa Figma hoặc mở thao tác ghi.

## Bổ sung A09.2 - mã tiền cố định

Đã đọc thêm context/screenshot `2026:6470`, nâng phạm vi đối chiếu lên 19 frame. Mẫu tiền cố định dùng giá trị 50.000đ toàn hàng, không có cap phần trăm; chuyển mẫu qua nhóm chọn loại, giữ ba nhóm trường và footer P2. Chênh nhỏ còn lại: cặp ngày dùng chiều rộng card chung thay giới hạn riêng 768px trong frame; sidebar giữ bản đồng bộ đã chốt.

Sau A09.2: 229 test gồm 57 golden qua, analyze sạch, build Web/Wasm dry run thành công; 518 asset không thiếu. Edge headless đăng nhập và đi qua 19 màn, gồm chuyển sang tiền cố định rồi quay về phần trăm, không ghi nhận Runtime exception hoặc console error. Xem ảnh màn tiền cố định (`.design/ui-audit/a092/fixed-coupon.png`; local-only; not distributed with this repository) và kết quả trình duyệt (`.design/ui-audit/a092/result.json`; local-only; not distributed with this repository). Các số liệu/ảnh 18 màn bên dưới là đợt audit trước A09.2.

## Lỗi đã sửa trong đợt này

| Vị trí | Lỗi trước sửa | Kết quả |
| --- | --- | --- |
| Dashboard | Thiếu toàn bộ vùng Sản phẩm đang bán | Thêm bốn card theo P2, ảnh/badge/tên/giá/tồn từ fixture riêng; Xem tất cả mở catalog |
| Danh sách khách hàng | Nút xem chi tiết dùng nhầm icon giỏ hàng | Dùng asset mắt của P2, giữ điều hướng đúng ID |
| Chi tiết khách hàng | Switch Material mặc định, viền vuông/xám đậm, trường bị cao | Công tắc trắng/nền xám theo P2; trường nền #F9FAFB/viền #D1D5DB/bo 6, chữ 14; vẫn chỉ đọc |
| Chi tiết khách hàng | Card cá nhân thấp, tìm lịch sử nằm riêng dưới tiêu đề, nút Đóng viền nâu | Căn chiều cao card theo mẫu; tìm/lọc vào header khi đủ rộng; Đóng màu/viền xám |
| Bộ lọc danh sách | Dropdown quá cao/rộng; một số ô nhận kích thước mặc định Flutter | Chỉnh mật độ/padding và độ rộng theo nhóm, giữ nhãn mặc định đọc đủ; chữ lớn/hẹp vẫn xuống dòng |
| Phân trang dùng chung | Vùng bấm mặc định 48px làm footer cao hơn mẫu | Giữ nút 34px và shrinkWrap; không đổi cách tính trang/tổng |
| Bảng sản phẩm | SKU sát giá bán trên trình duyệt thật | Xuống dòng trước đoạn số cuối như P2, semantics vẫn đọc SKU đầy đủ |
| Bảng thống kê đánh giá | Hàng cao, bảng bị kéo dài | Giảm padding dọc ở ô sản phẩm theo mật độ P2 |
| Bài viết nháp | Avatar tác giả vẫn có màu | Áp hiển thị thang xám cho dòng nháp theo P2 |
| Soạn bài | Chữ tiêu đề nhập 18px, lớn hơn mẫu 16px | Chỉnh 16px/line 20; không thay chức năng nhập tạm |
| Giỏ bỏ quên | Thanh tìm/control bị ảnh hưởng chiều cao mặc định | Chỉnh density và vùng bấm theo mẫu, giữ control chưa chốt ở trạng thái khóa |

## Kết quả theo từng frame

Các liên kết mở đúng node P2 trong file được duyệt. “Bám bố cục” chỉ nói về phần hiển thị đã có, không có nghĩa nghiệp vụ đã hoàn tất hoặc mọi pixel trùng khớp.

| Màn / Figma | Kết luận sau rà soát | Khác biệt còn lại |
| --- | --- | --- |
| [Đăng nhập xanh 10729](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-10729) | Card/font/nút xanh bám mẫu | Năm động thay 2025; validation/phiên mock là phần triển khai |
| [Dashboard 5862](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-5862) | Bổ sung vùng sản phẩm bị thiếu; thẻ và biểu đồ đúng nhóm màu | 84,4% theo 108/128 thay 85%; hình vòng còn khác đầu cung; ảnh người trong P2 không khớp tên hàng |
| [Sản phẩm 6669](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-6669) | Sửa lọc/phân trang/SKU | Font SKU chưa có Cousine riêng; checkbox/thao tác ghi khóa; tổng theo 12 fixture thay 124 |
| [Đơn hàng 7027](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-7027) | Sửa lọc/phân trang, giữ màu nút riêng | Cột minh chứng đã bỏ theo quyết định thanh toán bên thứ ba; tổng 12 thay 45 |
| [Chi tiết đơn 7320](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-7320) | Card/header/hành động đúng bố cục | Ngày/trạng thái ưu tiên nguồn list; lịch sử/xác nhận thanh toán thiếu; không khôi phục ảnh bill |
| [Khách hàng 8502](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-8502) | Sửa icon mắt/lọc/phân trang | Độ rộng/điểm xuống dòng vài cột khác; tổng 10 thay 85, nút ghi khóa |
| [Chi tiết khách 9129](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-9129) | Sửa switch/trường/card/header tìm lịch sử/nút Đóng | Không gán Nguyễn Văn A/chi tiêu/địa chỉ/lịch sử P2 cho Nguyễn Văn Huy; cần liên kết dữ liệu thật |
| [Đánh giá 5597](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-5597) | Card/sao/ảnh/nút theo mẫu; phân trang gọn hơn | Moderation khóa, ảnh minh họa có bất nhất tên từ P2; tổng theo nguồn |
| [Thống kê đánh giá 8805](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-8805) | Sửa mật độ hàng/lọc/phân trang | Tồn ưu tiên catalog, không đảo 45/5 theo P2; số liệu là snapshot, không tính thuật toán xếp hạng |
| [Bài viết 9663](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-9663) | Sửa lọc/phân trang/avatar nháp | Tổng 8 thay 24; sửa/xóa/banner khóa |
| [Soạn bài 9969](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-9969) | Căn chữ ô tiêu đề; card/toolbar bám mẫu | Nội dung chỉ văn bản tạm, bỏ copy hứa chèn ảnh; rich text/upload/lưu/publish khóa |
| [Cấu hình 6148](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-6148) | Bố cục hai section và màu nút bám mẫu | Cấu hình chỉ đọc, header hẹp dùng khung chung |
| [Sản phẩm số 2037:2](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2037-2) | Bảng/nút/khoảng cách phần chính bám mẫu | Ghi chú mock, Thêm khóa; chưa tệp/quyền thật |
| [Sửa sản phẩm số 2037:413](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2037-413) | Hai card/trường/nút phần chính bám mẫu | Không ghi Đã tải lên khi chưa có file; Lưu/Thay tệp khóa |
| [Hội thoại 2038:9](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2038-9) | Danh sách/vùng xem/màu nút bám mẫu | Hai khách chưa có lịch sử; gửi/đánh dấu khóa, không giảm unread khi xem |
| [Chatbot 2038:395](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2038-395) | Sáu trường/card/nút bám mẫu | Copy Đang bật không vận hành chatbot; Lưu khóa |
| [Giỏ bỏ quên 7960](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-7960) | Sửa control/phân trang; bảng và hai màu nút giữ P2 | Tổng 4 thay 12; thứ tự P2 không khớp nhãn giảm dần nên sắp xếp/thời gian khóa |
| [Mã tiền cố định 6470](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-6470) | A09.2: một trường tiền 50.000đ toàn hàng, chọn loại cố định, chung điều kiện/thời gian/footer | Khung sidebar đồng bộ; date pair dùng chung chiều rộng card thay max 768px riêng của frame; chưa nhập/tạo/lưu/áp mã |
| [Mã phần trăm 5399](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-5399) | Card/trường/nhóm chọn/footer/màu nút bám mẫu | Ô ví dụ chưa phải mã lưu; Lưu/Tạo khóa, A09.2 bổ sung xem mẫu tiền cố định qua nhóm chọn loại |

Sidebar dùng chung vẫn theo quyết định đồng bộ chữ chính 16px/menu con 14px/icon 20px, giữ brand A01. Vì sidebar trong các frame P2 khác nhau, bản chạy không chép lại một sidebar riêng cho từng trang. Không tự thêm các mục chưa có màn được duyệt/triển khai.

### Bổ sung - chữ và khoảng cách mục con sidebar

Sau phản hồi về cỡ chữ/line-height giữa các nhóm, đã kiểm tra component dùng chung và node P2 `2038:11`. Các mục con vốn cùng cỡ 14px, line-height 20px; mục đang chọn đậm 600 thay vì 400 nên nhìn lớn hơn. Đã khai báo rõ font Inter, letter-spacing 0, strut cùng baseline và visual density chuẩn; mỗi hàng tối thiểu 32px (padding dọc 6px), cách hàng 4px theo P2. Giữ màu nâu/đậm cho mục đang chọn, cho phép hàng tăng theo cỡ chữ hệ thống. Các nhóm dùng chung một style.

Kiểm chứng sau sửa: 218 test admin qua, gồm 54 golden; analyze sạch, build Web thành công. Đã xem lại render thống kê đánh giá và cập nhật golden sidebar có thay đổi chủ đích.

## Bằng chứng chạy thật và giới hạn

Script [audit-admin-browser.mjs](../scripts/audit-admin-browser.mjs) mở Edge headless bằng profile local riêng, đăng nhập bằng fixture đọc từ source hiện tại rồi click điều hướng; không sửa tài khoản demo. Snapshot và kết quả ở .design/ui-audit/after (`.design/ui-audit/after/result.json`; local-only; not distributed with this repository). Vòng kiểm tra này gồm 18 màn trên Edge, không thay thế kiểm tra tương tác đầy đủ hoặc xác thực nghiệp vụ.

So sánh trước/sau từ trình duyệt:

- Khách hàng: trước (`.design/ui-audit/before-complete/customers.png`; local-only; not distributed with this repository), sau (`.design/ui-audit/after/customers.png`; local-only; not distributed with this repository).
- Sản phẩm: trước (`.design/ui-audit/before-complete/products.png`; local-only; not distributed with this repository), sau (`.design/ui-audit/after/products.png`; local-only; not distributed with this repository).
- Dashboard: trước (`.design/ui-audit/before-complete/dashboard.png`; local-only; not distributed with this repository), sau (`.design/ui-audit/after/dashboard.png`; local-only; not distributed with this repository). Ảnh viewport 1024px chưa hiện hết chân card; nội dung vẫn cuộn được.
- Chi tiết khách hàng sau sửa (`.design/ui-audit/after/customer-detail.png`; local-only; not distributed with this repository).

Đã xem các bản render desktop và kiểm tra thích ứng 390/800px/chữ 120% bằng widget/golden. Golden được cập nhật cho thay đổi có chủ đích trong đợt này; việc test qua tự nó không chứng minh đúng Figma. Thay đổi chỉ trong admin, không chỉnh giao diện customer native.

Kết quả cuối: 218 test admin gồm 54 golden đều qua; analyze sạch; Web release/Wasm dry run thành công; 518 asset không thiếu. Edge headless đã đăng nhập và đi qua 18 màn sau bản sửa SKU cuối, không ghi nhận Runtime exception hoặc console error. Các ảnh/log ở .design là artifact local bị gitignore, có thể tạo lại bằng script.

Ưu tiên còn lại: chốt ảnh dashboard bị bất nhất trong Figma, nối dữ liệu lịch sử/chi tiêu/địa chỉ khách hàng khi có nguồn hợp lệ, rồi rà nốt các chênh lệch nhỏ font SKU/đầu cung biểu đồ/độ rộng cột. Không tự thay dữ liệu để làm ảnh giống mẫu.
