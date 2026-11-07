# Backlog frontend admin - 24/10/2026

Phạm vi: Flutter Web, chỉ P2 Admin 1 `2026:5398` và Admin 2 `2026:6668` trong file D9NBXODlcmLSQkgHrJF8WC. Đã đọc metadata cả hai trang qua Figma MCP: **6 + 24 = 30 frame**, không tính mỗi frame là một chức năng riêng. Đã đọc design context/screenshot Bảng điều khiển `2026:5862` để kiểm tra bố cục. Các màn khác mới kiểm kê metadata; phải đọc design context/screenshot từng màn trước khi code. Không sửa Figma.

## Hiện trạng repo

`apps/admin/lib/main.dart` gọi AdminApp trong `app.dart`. A01 có shell/sidebar/header; A02 có login xanh/phiên mock/guard/logout; A03.1 có thống kê/biểu đồ; A04.1/A06.1/A07.1 có danh sách sản phẩm/đơn hàng/người dùng; A06.2/A07.2 có chi tiết đơn/người dùng theo ID, cùng nguồn mock với danh sách tương ứng. A08.1/A08.2 có danh sách đánh giá và bảng thống kê mẫu chỉ đọc. A10.2 có danh sách bài viết, A10.3 có UI nhập bài tạm tại Marketing; A10.1 banner tạm hoãn. A11.1 có UI cấu hình chung chỉ đọc. A14.1 có danh sách sản phẩm số, UI A14.2 có chỉnh sửa tạm theo ID chưa lưu. A15.1/A15.2 có hội thoại khách hàng và kịch bản chatbot chỉ đọc. A12.1 có danh sách giỏ bỏ quên chỉ đọc. UI A09.1 có mẫu mã phần trăm chỉ đọc. Các mục khác vẫn là màn tạm. Có 218 test admin gồm 54 golden, chưa backend hoặc sản phẩm dashboard. Giữ Flutter/Dart, fl_chart 1.3.0 và package lenlab_shared qua path.

Package shared có model/repository/mock/theme/assets. Store customer chứa giỏ và bộ đơn của một khách hàng mẫu, không dùng trực tiếp làm nguồn quản trị tất cả khách hàng. Tách source/mock admin theo tính năng, chỉ chia sẻ model/asset/component thích hợp. Hai app hiện không đồng bộ dữ liệu giữa các tiến trình.

## Kiểm kê frame và thứ tự triển khai đề xuất

Các ID không có tiền tố ghi rõ đều thuộc `2026:`. Một task chỉ làm phần đủ rõ, có báo cáo/test/render trước khi sang task kế tiếp.

| Task | Nhóm / frame | Phần có thể làm | Giới hạn / phần chờ |
| --- | --- | --- | --- |
| A01 - đã làm | Khung admin theo Bảng điều khiển `5862` | Shell desktop, sidebar/header, mục đang chọn, điều hướng/back; khu nội dung tạm có tên rõ; viewport hẹp dùng Drawer | Không coi các màn tạm là chức năng đã xong. Tìm toàn cục/thông báo/dark mode/logout chỉ thông báo chưa khả dụng |
| A02 - đã làm | Đăng nhập xanh `10729`; chủ đạo `10788` không dùng | Chủ dự án chọn xanh; UI/validation/busy/error/retry, phiên mock, guard/logout, responsive | Ghi nhớ/quên mật khẩu chưa tích hợp; không có tài khoản production, persistence hoặc phân quyền backend |
| A03 | Bảng điều khiển `5862` | Thẻ số liệu, biểu đồ, sản phẩm mẫu, loading/empty/error/retry | Số liệu là fixture; định nghĩa doanh số, khoảng ngày, hủy/hoàn chưa chốt. Tạo đơn mới chưa triển khai |
| A04 - xong A04.1 | Sản phẩm `6669`, xác nhận xóa `7613` | Đã có danh sách/tìm/lọc/phân trang; dialog xóa chưa làm | Chỉ đọc, chưa thêm/sửa/xóa hoặc đổi hiển thị; chưa áp quy tắc sản phẩm đã có đơn |
| A05 | Thêm sản phẩm `8230` | Form các trường rõ, validation và lưu mock qua source riêng | Cấu trúc SKU/biến thể/ảnh/tồn phải đối chiếu tài liệu; chưa upload file thật |
| A06 - xong A06.1/A06.2 | Đơn hàng `7027`, chi tiết `7320` | Đã có danh sách/tìm/lọc/phân trang và chi tiết đúng ID, guard thiếu dữ liệu | Duyệt/chuyển trạng thái/hủy/hoàn tiền chưa làm; không phục hồi minh chứng thủ công |
| A07 - xong A07.1/A07.2 | Khách hàng `8502`, chi tiết `9129` | Danh sách và chi tiết đúng ID chỉ đọc | Lịch sử/chỉ số chờ liên kết dữ liệu; chưa thêm/khóa/mở/sửa vai trò |
| A08 - xong A08.1/A08.2 | Đánh giá `5597`, thống kê `8805` | Danh sách đánh giá và bảng xếp hạng mẫu sản phẩm, tìm/lọc/phân trang/trạng thái chỉ đọc | Chưa tổng hợp đánh giá thực, chốt thuật toán xếp hạng/kỳ; chưa xuất báo cáo hoặc moderation |
| A09 - xong UI A09.1 | Mã giảm giá phần trăm `5399`, tiền cố định `6470` | UI loại phần trăm chỉ đọc, nguồn mẫu/tải/rỗng/lỗi/retry; tiền cố định chưa triển khai | Chưa nhập/tạo/lưu/áp mã/cấp ưu đãi; điều kiện, đối tượng, hạn mức, múi giờ và nhận/redeem chưa chốt |
| A10 - xong A10.2/UI A10.3 | Cấu hình banner `9439` (A10.1 tạm hoãn), bài viết `9663`, soạn bài `9969` | Danh sách chỉ đọc và UI soạn bài nhập tạm, điều hướng Back giữ danh sách | Chưa lưu nháp/tạo bản ghi, rich text, upload/publish/sửa/xóa hoặc cấu hình banner |
| A11 - xong A11.1 | Cấu hình desktop `6148`, hẹp `6349` | UI hai nhóm giao diện/thông báo, nguồn mock và tải/rỗng/lỗi/thử lại chỉ đọc | Chưa sửa/lưu/upload/đổi theme, gửi email hoặc xin quyền thông báo; web hẹp là kiểm tra thích ứng |
| A12 - xong A12.1 | Giỏ bỏ quên `7960` | Danh sách mẫu chỉ đọc, tìm khách/liên hệ, phân trang và tải/rỗng/lỗi/retry | Chưa chi tiết, sắp xếp/lọc thời gian, ngưỡng bỏ quên, đồng ý tiếp thị, Gửi nhắc hoặc cấp Voucher |
| A13 | Custom `10177`, detail `10483`, chờ khách `10847`, đã chốt `11093` | Chỉ đọc danh sách/chi tiết và các trạng thái minh họa | Chưa gửi báo giá, tạo đơn, giữ tồn hoặc bắt đầu sản xuất. Giữ phạm vi đang hoãn của customer |
| A14 - xong A14.1/UI A14.2 | Sản phẩm số `2037:2`, sửa `2037:413`, lỗi lưu `2057:12`, đã lưu `2057:171` | Danh sách ba sản phẩm P2, số lượng từ nguồn, tải/rỗng/lỗi/retry chỉ đọc | Chỉnh sửa mở form theo ID và nhập tạm; Thêm/Lưu/Thay tệp khóa, chưa ghi/upload/tệp thật/cấp quyền/phát hành |
| A15 - xong A15.1/A15.2 | Hội thoại `2038:9`, kịch bản chatbot `2038:395` | Danh sách/tìm/chọn hội thoại và sáu trường kịch bản chatbot chỉ đọc, tải/rỗng/lỗi/retry | Chỉ hội thoại đầu có lịch sử P2; chưa gửi tin, đánh dấu đã xử lý, tính len, sửa/lưu/kích hoạt chatbot hoặc phát hành kịch bản |

## Điểm cần ghi nhận trước khi code

- Sidebar giữa các frame có cấu trúc khác nhau: Dashboard dùng Tổng quan/Sản phẩm/Đơn hàng/Khách hàng/Marketing/Cấu hình; các frame khác thêm Sản phẩm số/Hội thoại/Yêu thích/Giỏ bỏ quên. A01 đề xuất bám `5862`; không tự coi mọi mục trong mọi frame là một menu đã duyệt hợp nhất. Trước khi mở rộng menu cần đối chiếu màn đích.
- Có hai biến thể đăng nhập trong P2; chủ dự án đã chọn **xanh `10729`**, A02 không dùng mẫu chủ đạo.
- Screenshot Dashboard có ảnh người đi cùng tên Gấu bông len/Khăn choàng. Đây là bất nhất asset trong thiết kế, chưa tự thay ảnh hoặc lấy ảnh customer để chữa mẫu. Cần chốt trước khi hoàn thiện A03.
- Các mục menu như Giao diện/Sản phẩm yêu thích có tên trong metadata nhưng chưa thấy frame cấp cao riêng trong hai trang này. Không tạo giao diện tưởng tượng hoặc đánh dấu đã hoàn thành.
- P2 còn mô tả thanh toán thủ công. Quyết định cổng thanh toán bên thứ ba và bỏ upload minh chứng vẫn được ưu tiên; không triển khai trở lại chỉ vì có frame.
- Chưa có backend/ma trận quyền. Tất cả guard mock chỉ phục vụ UI; backend tương lai phải xác thực vai trò, giới hạn dữ liệu và kiểm tra thao tác ghi.

## Cấu trúc đề xuất khi bắt đầu code

Giữ `main.dart` làm entrypoint, chuyển tổ chức vào `app/` (app/router/scope), `shared/layout/` (shell/sidebar/header), `features/<tính năng>/data/` (source/fixture) và `presentation/` (page/widgets). Chỉ tạo folder khi task cần dùng, chưa tạo hàng loạt file rỗng. Không thêm package/router/chart trước khi xác định nhu cầu và xem dependencies hiện có.

## Tiêu chí bàn giao mỗi task

Đọc context/screenshot đúng node; dùng component/asset P2 phù hợp. Kiểm tra ở viewport web gốc 1280px và thích ứng khi cần, không dùng layout customer native cho admin. Test hành vi theo mức thay đổi; phần đọc dữ liệu có loading/empty/error/retry, thao tác mock có khóa gửi/lỗi/thành công nếu nằm trong phạm vi. Đối chiếu render và báo rõ khác biệt, không khẳng định pixel-perfect hoặc API thật.

## Task kế tiếp

**A09.2 - UI mã giảm giá tiền cố định chỉ đọc** theo P2 `2026:6470`: đọc context/screenshot trước, tái sử dụng nhóm component mã phần trăm ở chỗ phù hợp. Chưa tạo/lưu/áp mã/cấp voucher hoặc tự đặt điều kiện, hạn mức, đối tượng và múi giờ. Các quy tắc chưa chốt tiếp tục hoãn.

## Bàn giao UI A09.1 - mã giảm giá phần trăm chỉ đọc

Đã đọc context/screenshot P2 `2026:5399`, không sửa Figma. Đây là frame Tạo mã giảm giá mới, không phải danh sách mã hay mã đã lưu. `/marketing/coupons/percentage` từ Marketing → Mã giảm giá; sidebar giữ cỡ chữ/icon vừa đồng bộ. Header/Tạo mã giảm giá mới/Lưu nháp, breadcrumb Marketing → Mã giảm giá, tiêu đề Chi tiết mã, ba nhóm thông tin/điều kiện/thời gian và footer cố định Hủy bỏ/Tạo mã theo P2.

Main nền #F6F6F8, giới hạn 896px với padding desktop 64+20, card trắng bo 16/padding 24/gap 24. Trường nền #F8FAFC/viền #E2E8F0/bo 12, chữ xanh #244968; Theo % được chọn, Số tiền cố định chưa chuyển được. Nút Tạo mã #E89F70/chữ #523A30/bo 12, Lưu nháp nền cam 10%/chữ #6B3510; không áp màu pill #D1A373 của chatbot/detail. Hẹp/chữ lớn giảm padding, cặp trường/tab xếp dọc, footer wrap và vùng nội dung cuộn tới trường cuối.

AdminPercentageCoupon bất biến và AdminPercentageCouponSource/MockAdminPercentageCouponSource ở features/coupons/data; App.percentageCouponSource truyền qua access page/shell. Fixture chỉ có 20%, giảm tối đa 50.000đ, đơn tối thiểu 0 và nhãn ngày 12/05/2024 theo P2. code/quantityLimit/expiryDateLabel=null: LENLABSALE50 và 100 chỉ là placeholder ví dụ, dd/mm/yyyy chưa phải ngày hết hạn. Không tạo mã/ID lưu trữ, tự đặt số lượng 100 hoặc coi null là không giới hạn/không hết hạn. Ngày là chuỗi hiển thị, chưa suy ra timezone hoặc trạng thái hiệu lực theo đồng hồ. Không nối voucher customer hoặc ưu đãi Marketing bằng tên.

Toàn bộ trường chỉ xem, không input/toggle/datepicker; loại cố định chưa mở trong task này. Lưu nháp/Tạo mã khóa có tooltip, không có validation hoặc success/lỗi ghi giả. Copy A-Z/0-9 và dấu bắt buộc giữ theo mẫu, chưa biến thành hợp đồng backend khi chưa chốt quy tắc. Hủy bỏ/breadcrumb về /marketing, Back/guard/logout hoạt động. Không lưu nháp, phát hành, tính giảm, cấp voucher, nhận/áp mã, API ghi hoặc persistence.

Có loading/rỗng/lỗi/retry; mock latency/failNext/example=null. Trường thiếu báo Chưa có dữ liệu hoặc placeholder được giải thích là ô chưa điền, 0 khác null; semantics của ô thiếu không đọc ví dụ như giá trị đã lưu. Đổi source che snapshot cũ trong lúc tải, kết quả/lỗi cũ hoặc sau dispose không ghi đè dữ liệu hiện tại. Header/footer ngoài vùng cuộn, trường cuối vẫn cuộn lên trên footer; có chú thích mock/chưa tạo mã.

Đã xem render 1280/800/390px và kiểm tra chữ 120%, null/0/placeholder, source App/retry/kết quả cũ/dispose, cancel/breadcrumb/Back/guard/logout/Drawer và footer. Analyze sạch, 518 asset không thiếu, không thêm package/asset. Ba golden mới cho mã phần trăm; ba golden desktop Bài viết/Soạn bài/Giỏ bỏ quên cập nhật menu Mã giảm giá, các golden khác so sánh không cập nhật. 218 test admin gồm 54 golden đều qua, build Web release và Wasm dry run thành công. Còn sai khác nhỏ font/khoảng cách/độ rộng cột ngày và sidebar giữ khung chung; chưa kiểm tra trình duyệt thủ công/API hoặc ưu đãi thật, không khẳng định pixel-perfect.

## Bàn giao A12.1 - danh sách giỏ hàng bị bỏ quên chỉ đọc

Đã đọc context/screenshot P2 `2026:7960`, không sửa Figma. `/marketing/abandoned-carts` từ Marketing → Giỏ hàng bị bỏ quên; nhóm Marketing dùng sidebar/icon/cỡ chữ chung và bổ sung mục Bài viết & Banners quay về /marketing, không mở banner đang hoãn. Header trắng, mô tả/đổi giao diện/thông báo, thanh tìm/giá trị/thời gian, bảng checkbox/khách/sản phẩm/giá trị/thời gian/hành động và footer phân trang theo frame. Đổi giao diện/thông báo chỉ nêu chưa triển khai như các màn quản trị cũ.

AdminAbandonedCartsSource/MockAdminAbandonedCartsSource/DTO-query-result bất biến tách trong features/abandoned_carts/data; App.abandonedCartsSource truyền qua access page/shell. Bốn fixture theo P2: Nguyễn Văn An/450.000đ/2 giờ, Trần Thị Bích/1.250.000đ/5 giờ, Lê Hoàng Cường/890.000đ/1 ngày, Phạm Minh Dung/320.000đ/2 ngày. Tên/liên hệ/avatar/preview/số lượng là dữ liệu mẫu; không ghép khách hàng, sản phẩm hoặc giỏ customer bằng tên, không tái tính tổng từ preview rút gọn. Nhãn tương đối tĩnh không phải lastActivity hoặc đồng hồ cập nhật, không tự định nghĩa ngưỡng bỏ quên/retention/đồng ý tiếp thị.

Tìm tên/liên hệ trim, không phân biệt hoa thường, giữ thứ tự nguồn, phân trang 4 dòng; đổi tìm về trang 1, retry giữ tìm/trang. Tổng thực là4 thay 12 của copy P2, không tạo trang trống hoặc bịa thêm 8 giỏ. Fixture test riêng 9 dòng kiểm tra trang 2/clamp. P2 ghi Cao đến thấp nhưng thứ tự giá không giảm dần; giữ thứ tự mẫu và khóa control này, Thời gian cũng khóa vì chưa có lựa chọn/cách lọc được chốt. Tooltip và footer giải thích, chưa coi nhãn sắp xếp là quy tắc đã áp dụng.

Checkbox/chọn hàng loạt, Gửi nhắc và Voucher khóa có tooltip. Nút Gửi nhắc trắng/viền #D1A272/chữ #6B3510; Voucher nền #D1A272/chữ #523A30, cao38/bo6 đúng vai trò P2; không áp màu nút pill của chatbot/detail. Chưa gửi email/tin nhắn, tạo/cấp voucher, điều hướng chi tiết, xác nhận thanh toán, API ghi hoặc persistence. Không hiện success gửi giả.

Có loading/rỗng/không khớp-xóa tìm/lỗi-thử lại; source latency/failNext/carts rỗng. Giá null là - khác0đ, số lượng null khác0, liên hệ/sản phẩm/thời gian thiếu báo rõ. Đổi query/source không hiện kết quả cũ trong lúc tải; Future cũ/lỗi muộn và sau dispose không ghi đè UI. Bảng có controller/scrollbar ngang riêng khi hẹp/chữ lớn, header và control xuống hàng, footer phân trang wrap; Drawer/guard/Back/logout hoạt động.

Đã xem render 1280/800/390px, chữ 120%, kiểm tra bàn phím 300px/cuộn tới nút, retry đúng trang/tìm, guard/Back/logout và dữ liệu nguồn App. Analyze sạch, 518 asset không thiếu; không thêm package/asset. Ba golden mới cho danh sách; hai golden desktop Bài viết/Soạn bài cập nhật menu Marketing, các golden khác so sánh không cập nhật. 206 test admin gồm 51 golden đều qua, build Web release và Wasm dry run thành công. Còn sai khác nhỏ font/khoảng cách/chiều cao input/row và sidebar giữ khung chung; chưa kiểm tra trình duyệt thủ công hoặc dữ liệu thật/đồng bộ app-admin, không khẳng định pixel-perfect.

## Bàn giao A15.2 - UI kịch bản chatbot chỉ đọc

Đã đọc context/screenshot P2 `2038:395`, không sửa Figma. `/conversations/chatbot` từ Hội thoại → Kịch bản Chatbot; sidebar dùng chung cỡ chữ/icon vừa đồng bộ, nhóm Hội thoại đang mở và mục con đúng trạng thái. Guard phiên, Back, đăng xuất và Drawer giữ hoạt động; Tin nhắn khách hàng quay lại danh sách hội thoại. Không hợp nhất các mục sidebar chưa triển khai của frame.

Header/mô tả, card trắng bo16/padding24/gap20, sáu trường Chủ đề/Thông tin cần thu thập/Thông báo giới hạn/Khi thiếu thông tin/Khi không thể trả lời/Trạng thái và nút Lưu kịch bản theo P2. Main nền #F3F4F6/padding32; giá trị nền #F7F5F0/bo8, chữ 14px; nút #D1A373/#4D2B1A cao48/rộng220/bo24. Tái sử dụng card/text/nút của nhóm hội thoại; dòng dài xuống hàng, màn hẹp cuộn đến nút.

AdminChatbotScenario bất biến, AdminChatbotSource và MockAdminChatbotSource tách trong features/conversations/data; App.chatbotSource truyền qua access page/shell tới page. Fixture giữ nguyên sáu giá trị P2, gồm chủ đề Ước tính số lượng len và “Đang bật”. Đây chỉ là copy/trạng thái mẫu, không có công thức hoặc engine chatbot/AI, không thu thập thông số, tính len, gửi tin hay chuyển việc cho nhân viên. Nút Lưu khóa có tooltip, các trường chỉ đọc; chưa chỉnh sửa/lưu/publish/kích hoạt/persistence/API. Không tự thêm validation hoặc success/lỗi lưu giả.

Có tải/rỗng/lỗi/retry; source hỗ trợ latency/failNext/scenario=null. Trường null hoặc trắng báo Chưa có dữ liệu, trạng thái null khác false/Đang tắt. Đổi nguồn che nội dung cũ trong khi tải, kết quả/lỗi muộn và sau dispose không đổi UI hiện tại. Test kiểm tra nguồn App, sáu giá trị/không input hoặc toggle, save khóa, null/false/true, retry, kết quả cũ, guard/Back/logout và cuộn/Drawer/chữ 120%.

Đã xem render 1280/800/390px. Analyze sạch, 518 asset không thiếu; không thêm package/asset. Ba golden mới cho chatbot; chỉ golden Hội thoại desktop cập nhật màu nhãn Chatbot khi mở được, các golden khác so sánh không cập nhật. 193 test admin gồm 48 golden đều qua, build Web release và Wasm dry run thành công. Còn sai khác nhỏ font/khoảng cách và sidebar giữ khung chung/brand A01; thêm ghi chú mock/chưa kết nối. Chưa kiểm tra trình duyệt thủ công hoặc chatbot thật, không khẳng định pixel-perfect.

## Bàn giao A15.1 - hội thoại khách hàng chỉ đọc

### Sửa sidebar sau phản hồi UI

Đã đọc lại context/screenshot `2038:11`. Sidebar cũ dùng chữ chính 14px/menu con có chỗ 12px và trộn icon A01 nhỏ với icon Hội thoại. Đã sửa chữ chính 16px/24px, con 14px/20px, Hệ thống 12px; icon từ cùng bộ 2038:9, hiển thị 20px trong ô 24px, xám thường/nâu khi chọn. Menu con dùng chung component/căn lề/vùng bấm; nhóm đang chọn nền #F7EBDE, mục con chữ #663D1F đậm, không tô hai nền chọn cùng lúc. Brand A01 giữ nguyên. Không mở Chatbot hoặc thêm nghiệp vụ. Đã xem render desktop Hội thoại/Sản phẩm và Drawer chữ 120%; golden có sidebar cập nhật, các màn hẹp đóng Drawer giữ nguyên. 181 test gồm 45 golden đều qua, analyze sạch, build Web release/Wasm dry run qua; 518 asset không thiếu. Chưa kiểm tra trình duyệt thủ công sau sửa.

Đã đọc context/screenshot P2 `2038:9`, không sửa Figma. `/conversations` từ mục Hội thoại mới trong sidebar A01; dùng icon P2 có sẵn, giữ guard/Back/logout và route không animation. Khi đang ở Hội thoại có nhãn Tin nhắn khách hàng và Kịch bản Chatbot (chưa mở). Không hợp nhất toàn bộ sidebar khác nhau của frame hoặc thêm badge 5 không có nguồn tương ứng.

Phần chính theo P2: header 24px, nền #F3F4F6/padding 32px, cột danh sách 280px, gap 24px và vùng xem co giãn; card trắng bo 16px. Ba hội thoại Nguyễn Văn A/Trần Thị Bích/Lê Hoàng Cường giữ preview mẫu. Tìm tên/email/mã yêu cầu trim, không phân biệt hoa thường, giữ thứ tự nguồn; fixture chưa có email nên không tự gán. Chọn hội thoại dùng đúng object/ID trong kết quả hiện tại; không hiện nội dung hội thoại bị loại khỏi tìm kiếm, có xóa tìm và trạng thái không khớp. Frame không có phân trang/bộ lọc khác nên chưa tự thêm.

AdminConversationsSource/MockAdminConversationsSource và DTO/message bất biến tách trong features/conversations/data; App truyền cùng nguồn tới page. fetch chỉ đọc có latency/failNext/danh sách rỗng. Chỉ Nguyễn Văn A có hai tin nhắn/trạng thái hỗ trợ theo P2; hai khách khác báo chưa có dữ liệu nội dung/trạng thái, không sao chép lịch sử A sang B. messages=null khác danh sách tin nhắn rỗng. “2 tin mới”, 10:23/10:25, Đã gửi và báo giá/phí vận chuyển là fixture minh họa, không giảm số chưa đọc khi chọn, không xác nhận báo giá hoặc thay nghiệp vụ Custom đang hoãn. Không ghép người dùng/yêu cầu với nguồn khác bằng tên hoặc mã copy.

Khung phản hồi hiển thị nhưng không nhập được, Gửi phản hồi và Đánh dấu đã xử lý khóa có tooltip, giữ màu #D1A373/#4D2B1A/48px/bo24 theo P2. Chưa thêm draft, gửi tin, đọc/đã xử lý, WebSocket, email, API, AI hoặc persistence. Có ghi chú chỉ đọc/mock. Loading/rỗng/lỗi/retry; đổi source không lộ dữ liệu cũ, kết quả/lỗi muộn và sau dispose không đổi màn mới. Web hẹp/chữ lớn xếp hai vùng theo cột, cuộn tới hành động và dùng Drawer; không tạo chức năng mobile riêng.

Đã xem render 1280/800/390px và kiểm tra chữ 120%, bàn phím 300px, nguồn thiếu/rỗng/lỗi, tìm/chọn/xóa, guard/Back/logout. Analyze sạch, 518 asset không thiếu; không thêm package hoặc asset. 181 test admin gồm 45 golden đều qua; build Web release và Wasm dry run thành công. Ba golden mới cho hội thoại; golden desktop có sidebar và Drawer A01 cập nhật cho mục Hội thoại mới, các golden hẹp khác so sánh không cập nhật. Còn sai khác nhỏ font/khoảng cách/vùng chạm và sidebar giữ A01; chưa kiểm tra trình duyệt thủ công hoặc nhắn tin thật, không khẳng định pixel-perfect.

## Bàn giao A14.2 - UI chỉnh sửa sản phẩm số, chưa lưu

Đã đọc context/screenshot P2 `2037:413`, không sửa Figma. Nút Chỉnh sửa trong danh sách mở `/digital-products/edit?id=…` theo đúng ID; AdminApp truyền cùng AdminDigitalProductsSource tới list và editor. Giữ bố cục hai cột Nội dung sản phẩm/Tệp và phát hành, màu nút #D1A373/#4D2B1A và khoảng cách P2; màn hẹp/chữ lớn xếp dọc, có menu Drawer. Hủy hoặc chọn lại Sản phẩm số quay về instance danh sách; URL trực tiếp có đường về danh sách.

Tên, mô tả, giá bán và giá gốc nhập cục bộ; rời màn bỏ nội dung, mở lại đọc nguồn ban đầu. Định dạng, hiển thị, thông tin tệp/quyền chỉ đọc. Lưu thay đổi/Thay tệp/Thêm vẫn khóa có tooltip; không tạo trạng thái lưu thành công giả. Chưa validation lưu, persistence, upload, xuất bản hoặc cấp quyền. Quy tắc định dạng giá, giới hạn trường, quan hệ giá gốc/giá bán và hợp đồng tệp còn cần chốt trước khi mở ghi.

DTO cốt lõi được tách ra admin_digital_product.dart, source vẫn export để giữ import cũ. DTO detail chỉ bổ sung mô tả/giá gốc/tên tệp/nhãn P2 cho Dino; video/e-book dùng đúng danh tính, giá và trạng thái từ danh sách, phần thiếu ghi rõ. Không sao chép supplement Dino sang sản phẩm khác. Trạng thái tệp là “Chưa có dữ liệu trạng thái tệp”, thay câu đã tải lên/sẵn sàng của mẫu vì chưa có tệp thực. Copy quyền truy cập chỉ minh họa P2, không thực thi entitlement.

Có loading/lỗi-thử lại, thiếu ID/không tìm thấy/sai ID; kết quả và lỗi cũ khi đổi ID/source hoặc dispose không ghi đè màn mới. Form mới không giữ nội dung của sản phẩm trước. Test kiểm tra cùng source từ App, sửa tạm không đổi nguồn, Cancel/reopen/sidebar, direct URL/guard/logout, bàn phím 300px và chữ 120%.

168 test admin gồm 42 golden qua, analyze sạch, 518 asset không thiếu. Ba golden mới cho editor; ba golden danh sách sản phẩm số cập nhật cho nút Chỉnh sửa hoạt động; các golden khác so sánh không cập nhật. Đã xem render 1280/800/390px; build Web release và Wasm dry run đều qua. Không thêm package/asset mới. Còn sai khác nhỏ font/khoảng cách, sidebar giữ A01 và có ghi chú mock; chưa kiểm tra trình duyệt thủ công, API/quyền backend hoặc đồng bộ customer, không khẳng định pixel-perfect.

## Bàn giao A14.1 - danh sách sản phẩm số chỉ đọc

Đã đọc context/screenshot P2 `2037:2`, không sửa Figma. `/digital-products` truy cập từ Sản phẩm → Sản phẩm số; menu con xuất hiện khi ở các mục Sản phẩm/Sản phẩm số/Đánh giá/Thống kê. Giữ sidebar A01, route tức thời/guard/Back/logout. Phần chính theo P2: tiêu đề/mô tả, nút Thêm, bảng tên/định dạng/giá/trạng thái/Chỉnh sửa và tổng số. Nút #D1A373/#4D2B1A bo 24px, cao 48px; chưa đổi thành màu nút của màn khác.

Frame chỉ có ba dòng và tổng số, không có thanh tìm/lọc/phân trang; không tự thêm các control này dù đề xuất ban đầu có nhắc. Giữ Dino/PDF·8 MB/50.000đ, video khăn/45 phút/120.000đ, e-book Sống xanh/EPUB·12 MB/80.000đ. Ba ID mock riêng; trạng thái hai đã xuất bản/một nháp chỉ là fixture, không có tệp thực hay quyền khách hàng. Không ghép dữ liệu với store customer bằng tên hoặc tự cấp quyền vì Đã xuất bản.

AdminDigitalProductsSource/MockAdminDigitalProductsSource riêng, DTO/format/publication/result bất biến. fetch chỉ đọc có latency/failNext/products rỗng. Tổng và số published/draft tính từ nguồn; null trạng thái tính riêng và báo thiếu, giá null là - thay vì 0đ, mô tả tệp thiếu báo rõ. Không có URL download, upload, file picker, thêm/sửa/xóa, thanh toán hoặc phát hành. Thêm/Chỉnh sửa bị khóa có tooltip; không mở màn sửa giả.

Có loading/rỗng/lỗi-thử lại, bỏ kết quả/lỗi cũ khi đổi source hoặc dispose, không hiện bản ghi cũ trong lúc tải nguồn mới. Tách features/digital_products/data và page/widgets table/styles; bảng có scrollbar ngang riêng khi hẹp/chữ lớn, số tổng xuống dòng. Vùng nội dung bám đầu trang như P2, không bị căn giữa theo chiều cao shell. Không thêm package/asset hoặc header ngoài frame.

156 test admin gồm 39 golden qua, analyze sạch, 518 asset không thiếu. Đã xem render 1280/800/390px và chữ 120%; kiểm tra ba fixture, null metadata/counts, retry/source muộn/dispose, guard/nav/Back/logout/Drawer/cuộn ngang và vị trí đầu trang. Ba golden mới; chỉ ba golden desktop products/reviews/review-statistics cập nhật cho menu con mới, các golden khác so sánh không cập nhật. Build Web release và Wasm dry run đều qua.

Còn sai khác nhỏ font/khoảng cách/độ rộng cột và sidebar A01; trên web hẹp thêm nút menu, bảng cuộn thay vì tạo chức năng mobile riêng, có ghi chú mock. Chưa kiểm tra trình duyệt thủ công hoặc API/quyền/backend/dữ liệu thật/sync app–admin; không khẳng định pixel-perfect.

## Bàn giao A11.1 - cấu hình chung chỉ đọc

Đã đọc context/screenshot P2 desktop `6148` và hẹp `6349` qua MCP, không sửa Figma. `/settings` thay màn tạm bằng header Cấu hình hệ thống, hai section Tùy chỉnh Giao diện/Cấu hình Thông báo và footer Hủy bỏ/Lưu thay đổi. Sidebar giữ A01, mục Cấu hình chung đang chọn; không chọn Giao diện đồng thời như một số chi tiết của frame. Web hẹp dùng Drawer và xếp các trường theo cột, không có app admin native.

AdminSettingsSource/MockAdminSettingsSource riêng, DTO AdminGeneralSettings bất biến, fetch chỉ đọc có latency/failNext/null để thử. Fixture Lenlab Official, Cam Đất (Terracotta)/#E89F70, logo minh họa P2, Email và Trình duyệt đều tắt. Đây là giá trị mẫu, không đọc/ghi cấu hình chạy thật, không thay P2.theme, favicon/tab trình duyệt hoặc tên app. Favicon vẫn là placeholder tải lên theo thiết kế, không giả có file đã lưu.

Tên website/màu/logo/favicon/trạng thái thông báo chỉ xem; Thay đổi màu, upload, Hủy và Lưu chưa khả dụng có tooltip. Toggle là chỉ báo trạng thái có semantics enabled=false/toggled theo nguồn, không xin quyền trình duyệt, gửi email hoặc tạo popup. Header thông báo/đổi giao diện chỉ thông báo chưa triển khai. Không có source ghi, validation, cập nhật dịch vụ hoặc persistence.

Có tải, lỗi/thử lại, nguồn trống và dữ liệu thiếu từng trường; không coi null thông báo là false. Mã màu chỉ render swatch khi đúng #RRGGBB, thiếu/sai báo rõ thay vì văng lỗi hoặc đổi theme. Khi đổi source không hiện giá trị cũ trong lúc tải, kết quả/lỗi cũ và sau dispose không thay màn hiện tại. Footer nằm ngoài vùng cuộn, trường cuối vẫn cuộn lên xem được.

Tách features/settings/data và page/widgets settings_header_footer/sections/styles. AdminDashedBorder dùng chung với composer sau khi trích phần vẽ nét đứt; golden composer và các màn cũ so sánh không cập nhật. Không thêm package hoặc sửa asset. 145 test admin gồm 36 golden qua; ba golden mới cho settings. Analyze sạch, 518 asset không thiếu. Đã xem render 1280/800/390px, chữ 120%, kiểm tra null/hex sai/on-off/retry/source cũ/guard/Back/logout/footer và Drawer. Build Web release và Wasm dry run đều qua.

Còn sai khác nhỏ font/khoảng cách/vùng chạm, header hẹp giữ khung web chung thay header riêng của mẫu 6349, sidebar A01 và ghi chú mock; không khẳng định pixel-perfect. Chưa kiểm tra tương tác trình duyệt thủ công, API/quyền quản trị, cấu hình thực hoặc đồng bộ app–admin.

## Bàn giao A10.3 - UI soạn bài, chưa lưu

Đã đọc context/screenshot P2 `9969`, không sửa Figma. Thêm mới ở /marketing mở `/marketing/articles/new`; đây là UI nhập tạm, chưa tạo bài viết hoặc bản nháp. Header breadcrumb/tên màn, tiêu đề, vùng nội dung/toolbar, tác giả/danh mục, ảnh bìa và hành động theo frame. Sidebar giữ A01 và chọn Marketing. Breadcrumb Bài viết hoặc chọn Marketing về đúng instance danh sách khi mở từ list, giữ tìm/lọc/trang; URL trực tiếp có đường về /marketing. Guard phiên và đăng xuất vẫn áp dụng.

Tiêu đề/nội dung văn bản thuần nhập được, giữ khi đổi danh mục trong cùng màn; tác giả đọc tên phiên mock và không chỉnh sửa. Tin tức mặc định theo P2; các lựa chọn còn lại dùng nhãn đã có ở danh sách. Đây chỉ là giá trị nhập cục bộ, không mở rộng enum lưu trữ hoặc tự ánh xạ Tin tức sang danh mục khác. Controllers dispose khi rời màn, quay lại form mới là trống; có ghi rõ nội dung chưa lưu và sẽ bỏ khi rời trang. Không thêm localStorage hoặc persistence giả.

Đăng bài/Lưu nháp/upload và toolbar định dạng/chèn liên kết/ảnh bị khóa có tooltip. Chưa chốt trường bắt buộc/giới hạn độ dài, định dạng rich text, cơ chế lưu nháp hoặc gán tác giả phía backend, ánh xạ Tin tức, quy tắc file/kích thước/dung lượng; chưa tự thêm validation hoặc gọi source ghi. Giữ copy SVG/PNG/JPG, 800x400px làm minh họa P2, chưa coi là hợp đồng upload hoàn chỉnh. Không có ảnh được nhận, giao dịch mạng, xuất bản, đổi trạng thái hoặc ảnh hưởng danh sách 8 bản ghi. Không dựng loading/success/lỗi lưu giả cho chức năng chưa có.

Tách admin_article_navigation.dart và page/header/editor/sidebar/styles; dùng asset 9969 có sẵn, TextField nhiều dòng có vùng cuộn, không thêm thư viện editor. Toolbar giữ biểu tượng/màu/bố cục nhưng chưa tương tác; bỏ câu placeholder hứa hỗ trợ chèn ảnh/định dạng vì chưa triển khai. Các rule còn thiếu tiếp tục hoãn.

134 test admin gồm 33 golden qua, analyze sạch; 518 asset không thiếu. Đã xem render 1280/800/390px và chữ 120%, kiểm tra nhập 40 dòng/bàn phím 300px/cuộn tới hành động, Back giữ danh sách, direct URL/guard/logout và nhập lại form trống. Ba golden mới cho composer; ba golden bài viết cập nhật cho nút Thêm mới đã hoạt động; các golden khác so sánh không cập nhật. Build Web release và Wasm dry run đều qua.

Còn sai khác nhỏ vùng chạm/khoảng cách/chiều cao card, sidebar giữ A01; hai cột xếp dọc khi hẹp/chữ lớn, footer giải thích trạng thái tạm là bổ sung cần thiết. Chưa kiểm tra trình duyệt thủ công hoặc backend/phân quyền/đồng bộ dữ liệu; không khẳng định pixel-perfect hoặc hoàn thành chức năng soạn/lưu/xuất bản đầy đủ.

## Bàn giao A10.2 - danh sách bài viết

Chủ dự án chọn chuyển sang bài viết sau khi xác nhận frame `9439` là Cấu hình Banner, không có danh sách banner. A10.1 tạm hoãn, không tạo UI danh sách ngoài thiết kế hoặc mở upload/Lưu. Đã đọc context/screenshot P2 `9663` qua MCP cho A10.2, không sửa Figma.

Mục Marketing `/marketing` thay màn tạm bằng header Quản lý Marketing & Nội dung, tab Bài viết & Blog/Banner quảng cáo, thanh tìm/lọc/Thêm mới, bảng checkbox/ảnh bìa/tiêu đề-trạng thái/danh mục/tác giả/ngày đăng/hành động và phân trang. Sidebar giữ A01; Banner quảng cáo bị khóa có tooltip nêu tạm hoãn. Thêm mới/Sửa/Xóa/chọn hàng loạt chưa triển khai; không có trang đọc nội dung bài, editor, upload, liên kết ngoài hoặc publish.

AdminArticlesSource/MockAdminArticlesSource riêng ở features/articles/data, DTO/query/result bất biến; không thay nội dung customer hoặc dùng tài khoản phiên làm tác giả giả. Giữ bốn dòng P2: xu hướng handmade 2024, hướng dẫn nến thơm, bản nháp vòng tay len và siêu sale 11.11. Thêm bốn dòng ghi rõ minh họa, tổng 8/2 trang tính từ nguồn thay 24 cố định. 4 dòng/trang. Public/Draft và ngày 2023 là fixture P2, không phản ánh trạng thái phát hành thật; title 2024/ngày 2023 được giữ nguyên mẫu. Copy giảm 50% không tạo chương trình khuyến mãi. Tác giả/ngày thiếu báo -, không giả ngày đăng hoặc coi nháp đã xuất bản.

Tìm tiêu đề trim/không phân biệt hoa thường; danh mục Xu hướng/Tutorial/Tổng hợp/Khuyến mãi kết hợp Public/Draft trước phân trang, giữ thứ tự nguồn. Đổi điều kiện về trang 1, debounce 250ms, không hiện kết quả cũ dưới truy vấn mới. Loading, nguồn trống, không khớp/xóa bộ lọc, lỗi/thử lại giữ trang/điều kiện; bỏ kết quả/lỗi cũ và lỗi sau dispose. Source có failNext và danh sách rỗng để thử.

Đã xem render 1280/800/390px và chữ 120%; bảng có scrollbar riêng khi hẹp, tabs/header/filter/footer xuống dòng. Dùng lại AdminListPagination, palette/surface và asset P2 có sẵn. 125 test admin gồm 30 golden đều qua; ba golden mới, các golden cũ so sánh không cập nhật. Analyze sạch, build Web release/Wasm dry run qua, 518 asset không thiếu.

Còn khác biệt nhỏ độ rộng cột/font/khoảng cách, cách xuống dòng và avatar tác giả nháp chưa giảm màu như P2; sidebar A01/tổng số và thao tác ghi bị khóa như phạm vi. Chưa kiểm tra tương tác trình duyệt thủ công, API/quyền backend, đồng bộ app–admin hoặc nội dung bài thực; không khẳng định pixel-perfect.

## Bàn giao A08.2

Đã đọc context/screenshot P2 `8805` qua MCP, không sửa Figma. Đây là bảng xếp hạng sản phẩm theo đánh giá, không có biểu đồ/tổng số đánh giá ở frame. Route `/reviews/statistics`, truy cập từ Đánh giá → Thống kê đánh giá. Header, tìm kiếm, danh mục/Toàn thời gian, bảng xếp hạng/sản phẩm/SKU/danh mục/sao-lượt/tồn và phân trang theo P2. Sidebar giữ A01 và mục con hiện có, không gộp sidebar Khách hàng/Hội thoại của frame. Back về danh sách đánh giá; guard đăng nhập vẫn áp dụng.

AdminReviewStatisticsSource/MockAdminReviewStatisticsSource riêng, DTO/query/result chỉ đọc. Năm bộ sao/lượt/thứ hạng/caption lấy nguyên mẫu P2; chưa phải kết quả tổng hợp từ 8 đánh giá A08.1 (khác sản phẩm và chưa có liên kết ID/SKU). Không tính lại hạng theo số sao/lượt, không tự đặt tiêu chí hòa hạng hoặc moderation. Tìm tên/SKU trim/không phân biệt hoa thường, lọc danh mục trước phân trang; giữ thứ tự và thứ hạng toàn cục của bản mẫu. Tổng thực là 5, không giả 50 sản phẩm hoặc các trang trống. Phân trang 5 dòng, nguồn test riêng có thêm bản ghi để kiểm tra trang 2/giới hạn.

Mỗi dòng tham chiếu AdminProduct từ fixture catalog bằng SKU, không sao chép tồn/danh mục riêng: MK-MEO-001 = 45 sẵn sàng và TB-THO-002 = 5 sắp hết theo catalog, khác 5/45 bị đảo trong P2 thống kê. Túi thắt nơ dùng danh mục Thời trang & Phụ kiện theo catalog thay nhãn Thời trang len riêng của frame. Màu tồn theo stockTone được khai báo, chưa suy ra ngưỡng. Caption Best seller tháng 10 chỉ là copy mẫu, không khẳng định doanh số tháng.

Có loading/empty/error/retry, debounce 250ms, reset trang khi tìm/lọc, chống kết quả/lỗi cũ và dispose; retry giữ điều kiện/trang. Toàn thời gian chỉ là nhãn cố định với giải thích chưa có dữ liệu thời gian để lọc, Xuất báo cáo bị khóa, chưa export hoặc đổi giao diện. Chưa thêm/sửa/xóa, gọi backend hoặc sync customer.

Đã xem render 1280/800/390px và chữ 120%; bảng cuộn ngang có scrollbar riêng, header/filter/footer xuống dòng. Dùng Inter có sẵn cho SKU để render rõ thay Cousine chưa có asset. Ba golden mới; chỉ golden đánh giá 1280 cập nhật cho mục con Thống kê, các màn cũ còn lại so sánh không cập nhật. 112 test gồm 27 golden đều qua; analyze sạch, build Web release/Wasm dry run qua, 518 asset không thiếu.

Còn khác biệt font SKU/độ rộng cột/khoảng cách, sidebar A01, tổng/phân trang và các trường canonical catalog nêu trên; không khẳng định pixel-perfect. Chưa tương tác thủ công trên trình duyệt, chưa thuật toán/kỳ thống kê, hợp đồng API/quyền/backend hoặc dữ liệu thực.

## Bàn giao A08.1

Đã đọc context/screenshot P2 `5597` qua MCP, không sửa Figma. `/reviews` có header tìm tên khách/sản phẩm, menu lọc 1–5 sao và nhóm Tất cả/Chờ duyệt/5 Sao/Có hình ảnh. Ba thẻ đầu giữ tên, sản phẩm, sao, nội dung, ảnh và nhãn trạng thái P2. Nút Duyệt/Ẩn bị khóa có tooltip; chưa xóa/phản hồi, upload ảnh hoặc thay trạng thái. Sidebar giữ A01, khi chọn Sản phẩm hoặc Đánh giá hiển thị mục con Đánh giá; không tự hợp nhất toàn bộ sidebar prototype.

AdminReviewsSource/MockAdminReviewsSource riêng ở features/reviews/data, không đọc đánh giá/store customer hoặc gán quan hệ đơn/người dùng giả. 3 fixture P2 + 5 dòng ghi rõ minh họa; 3 dòng/trang, tổng 8/3 trang từ dữ liệu. Chờ duyệt (2) tính từ toàn nguồn mock, không đổi theo truy vấn; trong tải/lỗi báo - thay số cũ. Nhãn 2 giờ/1 ngày/3 giờ là copy mẫu, chưa phải timestamp thực. Trạng thái duyệt chỉ là fixture, chưa chốt cơ chế kiểm duyệt cho customer.

Tìm tên khách/sản phẩm trim, không phân biệt hoa thường; nhóm và số sao kết hợp trước phân trang. Nhóm Tất cả bỏ điều kiện nhóm, vẫn giữ số sao/tìm kiếm đang hiển thị; Xóa bộ lọc xóa hết. Đổi điều kiện về trang 1, debounce 250ms, không hiện kết quả cũ; retry giữ truy vấn/trang. Có tải/rỗng nguồn/không khớp/lỗi-thử lại, bỏ kết quả/lỗi muộn và dispose; chuyển trang cuộn đầu danh sách.

100 test admin gồm 24 golden qua, analyze sạch, 518 asset không thiếu. Đã xem render 1280/800/390px, chữ 120% và kiểm tra cuộn tới phân trang, guard/Back, menu Escape và khóa thao tác ghi. Chỉ golden sản phẩm 1280 cập nhật cho mục con mới; các màn cũ khác so sánh không cập nhật. Ba golden mới cho đánh giá. Build Web release và Wasm dry run đều qua.

Ảnh thumbnail P2 là đồ gốm/chim, không khớp tên khăn/cừu/mũ; giữ asset đúng slot và chờ chốt, không tự thay ảnh customer. Phân trang dùng component chung có tóm tắt số lượng nên khác footer nguyên mẫu; sidebar giữ A01, còn khác biệt nhỏ font/khoảng cách và cách xuống dòng khi hẹp. Chưa thử trình duyệt thủ công, API/quyền backend hoặc sync app–admin; không khẳng định pixel-perfect.

## Bàn giao A07.2

Đã đọc context/screenshot P2 `9129`, không sửa Figma. Nút mắt mở `/customers/detail?id=USR-001`; AdminApp giữ cùng AdminCustomersSource cho list/detail. Tên/email/SĐT/vai trò/trạng thái lấy đúng ID. Back/Đóng giữ truy vấn/trang khi mở từ list; URL trực tiếp có đường về danh sách. Có guard phiên, loading/error/retry, thiếu mã, không tìm thấy, chặn trả nhầm bản ghi và bỏ kết quả/lỗi muộn.

Nguyễn Văn A trong frame không trùng người nào trong danh sách. Ngày tham gia/chi tiêu/hạng/địa chỉ/lịch sử hiện báo chưa có dữ liệu liên kết; không gán thông tin mẫu cho mọi ID, giả 0/15 đơn hoặc ghép đơn bằng tên/SĐT. Tìm/lọc lịch sử bị khóa. Switch/lý do/ghi chú/Lưu chỉ đọc; chưa sửa hồ sơ, khóa/mở hoặc đổi quyền. Tách DTO và dùng chung AdminDetailCard với chi tiết đơn.

87 test admin gồm 21 golden qua, analyze sạch, build Web release/Wasm dry run qua; 518 asset không thiếu. Đã xem render 1280/800/390px và chữ 120%. Ba golden danh sách cập nhật cho nút mắt; các golden màn khác so sánh không cập nhật. Nội dung/chiều cao khác prototype do dữ liệu thiếu; còn khác biệt nhỏ font/khoảng cách, sidebar giữ A01. Chưa kiểm tra trình duyệt thủ công/API/quyền backend/đồng bộ app–admin; không khẳng định pixel-perfect.

## Bàn giao A07.1

Đọc context/screenshot P2 `8502` qua MCP, không sửa Figma. Mục Khách hàng /customers hiển thị Quản lý người dùng với mô tả theo frame: gồm cả Khách hàng/Nhân viên. Header, tìm kiếm/bộ lọc, bảng avatar/tên/email/điện thoại/vai trò/mua hàng/trạng thái và footer phân trang theo P2. Sidebar vẫn A01 dùng chung, route chuyển tức thời. Thêm người dùng bị khóa; checkbox/chọn hàng loạt và cột Hành động chưa khả dụng (dấu -), chưa xem chi tiết, khóa/mở hoặc đổi quyền.

AdminCustomersSource/MockAdminCustomersSource riêng, DTO/query/result và danh sách bất biến; không dùng profile/customer store làm danh sách toàn hệ thống. 4 dòng đầu giữ P2: Nguyễn Văn Huy, Trần Thị Linh (Nhân viên), Lê Tuấn Anh (Bị khóa), Phạm Thị Mai; avatar/initials đúng slot. Thêm 6 dòng ghi rõ minh họa để thử phân trang, tổng 10/3 trang tính từ dữ liệu thay 85 cố định. 4 dòng/trang. Số đơn là fixture/null; thiếu thì -, không coi là 0 hoặc tự tổng hợp từ bộ đơn mock khác. Vai trò/trạng thái chỉ là dữ liệu hiển thị, không cấp quyền hoặc thay trạng thái tài khoản thật.

Tìm tên/email không phân biệt hoa thường, trim; SĐT tìm được có/không khoảng trắng và dấu phân cách. Vai trò và trạng thái Hoạt động/Bị khóa kết hợp trước phân trang, giữ thứ tự nguồn. Đổi tìm/lọc về trang 1; debounce 250ms, bỏ kết quả/lỗi cũ và lỗi sau dispose, retry giữ trang/điều kiện. Có tải, nguồn trống, không khớp bộ lọc, xóa điều kiện, lỗi/thử lại. Bộ lọc phụ hiện tóm tắt và xóa điều kiện, không tự thêm tiêu chí kinh doanh.

75 test gồm 18 golden qua, analyze sạch, build Web release/Wasm dry run qua; 518 asset đăng ký không thiếu. Đã xem render 1280px và 800/390px chữ 120%; bảng cuộn ngang riêng, header/filter/footer tự xuống dòng. Kiểm tra tìm/lọc/phân trang, retry, null số đơn, kết quả cũ, dispose, Enter/Escape và guard phiên; so sánh golden các màn cũ không cập nhật. Còn sai khác nhỏ font điện thoại/độ rộng cột/khoảng cách; sidebar cố ý giữ A01, hành động ghi bị khóa. Chưa kiểm tra trình duyệt thủ công/backend/ma trận quyền/dữ liệu thực hoặc đồng bộ app–admin. Không khẳng định pixel-perfect.

## Bàn giao A06.2

Đọc context/screenshot `7320`, không sửa Figma. Nút Chi tiết mở `/orders/detail?id=<ID>` có guard đăng nhập. AdminApp giữ một AdminOrdersSource truyền tới danh sách và detail, summary trong detail là chính bản ghi nguồn danh sách. Route chọn menu Đơn hàng; Back từ list pop về đúng instance giữ tìm/lọc/trang, URL mở trực tiếp có nút về danh sách. Chuyển route tức thời như trước. Tách summary/detail/line DTO, source không có API ghi.

Header ID/ngày/badge, thẻ khách hàng/thanh toán, sản phẩm/tổng tiền và lịch sử theo P2. Duyệt/Hủy/Sửa bị khóa; chưa có minh chứng, upload ảnh, xác nhận thanh toán hoặc thay trạng thái. Không tự áp quyền/ngưỡng tồn/phí vận chuyển thực tế. Thẻ lịch sử là trạng thái thiếu dữ liệu; không dựng timeline hoặc giờ đặt giả.

P2 detail ORD-202502 có ngày 20/10/2023 14:30 và Chờ duyệt, khác list 19/10/2023/Đang giao. UI lấy list làm nguồn nhất quán, không tự ghi đè summary. Chưa có payment state đáng tin nên báo Chưa có dữ liệu xác nhận, không dùng Đã xác nhận của prototype. Chỉ ORD-202502 có supplement email/địa chỉ/2 dòng sản phẩm theo frame; 470.000 + 30.000 - 0 = 500.000 khớp tổng list. Ghi chú giữ bản nguồn, không tự mở rộng câu bị rút gọn. Ngưỡng 30.000 là fixture của đơn này, không áp cho đơn khác.

Các ID khác vẫn xem được summary của đúng đơn, thiếu email/địa chỉ/dòng hàng/phí/giảm giá thì báo thiếu, không rơi về sản phẩm/địa chỉ của ORD-202502. Tổng luôn từ summary. Có loading/error/retry, thiếu mã, không tìm thấy và chặn nguồn trả nhầm ID; thay ID bỏ kết quả cũ, dispose bỏ lỗi muộn. Bảng sản phẩm cuộn ngang khi hẹp, các cột chính xếp dọc khi chữ lớn. Có phát hiện chi tiết số tiền không khớp tổng, không tự sửa giá trị.

Asset ảnh Len Milk Cotton/Kim móc trong frame đang là ảnh đồ gốm/người, chưa khớp tên. Giữ file P2 đúng slot, không tự thay ảnh customer; cần chốt asset đúng trước khi hoàn thiện nội dung. Sidebar giữ A01; không bổ sung các menu chưa làm hoặc gán Khách hàng thân thiết khi nguồn không có nhãn. Còn sai khác nhỏ độ rộng cột/font/khoảng cách; không khẳng định pixel-perfect.

63 test gồm 15 golden qua, analyze sạch, build Web release/Wasm dry run qua; 518 asset không thiếu file. Đã xem render 1280/800/390 và chữ 120%; test tính nhất quán list–detail, amount, đúng/sai/thiếu ID, retry, kết quả cũ/dispose, Back/guard và khóa thao tác ghi. Golden cũ được so sánh không cập nhật. Chưa chạy tương tác trình duyệt thủ công/backend/đồng bộ app–admin.

## Bàn giao A06.1

Đọc context/screenshot P2 `7027`, không sửa Figma. /orders có header tiêu đề/mô tả/nút tạo, thanh tìm/lọc, bảng và phân trang; nền #F3F4F6, nút #E09F56. Sidebar giữ khung A01, chưa mở rộng các menu chưa làm. Cột minh chứng/ảnh và duyệt thanh toán thủ công không khôi phục theo quyết định chuyển sang cổng bên thứ ba. Nút Tạo đơn bị khóa; Chi tiết mở thông báo tạm nêu đúng mã đang chọn, chưa coi là màn chi tiết hoàn chỉnh.

AdminOrdersSource/MockAdminOrdersSource tách khỏi store customer, DTO/query/result bất biến. 5 dòng đầu giữ mã/tên/điện thoại/ngày/tổng/phương thức/trạng thái/ghi chú P2; thêm 7 dòng ghi rõ minh họa. Tổng 12/3 trang tính từ dữ liệu thay 45 trong mẫu, 5 dòng/trang. Ngày 2023 dù ID chứa 2025 giữ nguyên mẫu; ngày thiếu báo Chưa có ngày đặt. Không tự gán lịch sử, payment confirmed, đơn gateway hoặc trạng thái thực. Bộ lọc Thanh toán là phương thức COD/CK, chưa là đã/chưa thanh toán.

Tìm mã (có/không #) hoặc tên, trim/không phân biệt hoa thường; lọc trạng thái và phương thức trước phân trang, giữ thứ tự nguồn. Đổi truy vấn về trang 1, debounce 250ms, loại kết quả/lỗi cũ và bỏ qua sau dispose. Có loading, nguồn trống, không khớp tìm/lọc, xóa điều kiện, lỗi/thử lại giữ trang/bộ lọc. Mã đơn ngắt theo dấu gạch cuối, tooltip/semantics giữ ID đầy đủ. Chưa lọc ngày/sắp xếp, thêm quy tắc phân loại trạng thái hoặc hợp đồng API.

Tách AdminListPagination và palette/surface/định dạng tiền ở shared/widgets để cả products/orders dùng, giữ asset mũi tên và màu riêng mỗi frame. 52 test gồm 12 golden qua, analyze sạch, build Web release/Wasm dry run qua; 518 asset đăng ký không thiếu. Đã xem render 1280px và 800/390px chữ 120%; bảng cuộn ngang riêng khi hẹp, header/bộ lọc/footer xuống dòng. Kiểm tra tìm/lọc/phân trang/retry, kết quả cũ, disposal, Enter/Escape, ID thông báo chi tiết và guard/menu/Back. Golden cũ được so sánh không cập nhật sau refactor pagination. Còn khác biệt nhỏ font SKU/mã đơn, badge/khoảng cách và độ rộng cột do bỏ minh chứng; sidebar cố ý giữ A01. Chưa kiểm tra trình duyệt thủ công hoặc backend/đồng bộ app–admin, không khẳng định pixel-perfect.

## Bàn giao A04.1

Đọc design context/screenshot P2 `6669` qua MCP, không sửa Figma. Màn /products có header tiêu đề/mô tả và nút theo P2, nền #F3F4F6, thanh tìm kiếm/bộ lọc, bảng và footer phân trang. Sidebar giữ khung A01 dùng chung; chưa hợp nhất thêm mục Hội thoại/Sản phẩm số/Đánh giá của frame này. Header sản phẩm khác header Dashboard theo chính frame; route vẫn chuyển tức thời.

Source riêng features/products/data có query/result bất biến, tìm tên/SKU (trim, không phân biệt hoa thường), danh mục và hiển thị/ẩn kết hợp trước khi chia trang. Đổi tìm/lọc về trang 1; 5 dòng/trang; trang trước/sau và trang số, giới hạn nút khi nhiều trang. Retry giữ trang/bộ lọc. Debounce 250ms, bỏ qua thành công/lỗi cũ khi đổi truy vấn hoặc dispose; không hiện dữ liệu truy vấn cũ dưới bộ lọc mới. Có loading, lỗi/thử lại, trống nguồn và không khớp bộ lọc/xóa bộ lọc. Thành công hiển thị kết quả, không giả lưu dữ liệu.

Giữ 5 dòng P2 đầu với SKU/giá/tồn/danh mục/trạng thái và icon/CHỜ ẢNH đúng mẫu; thêm 7 dòng ghi rõ minh họa để thử phân trang. Tổng là 12/3 trang, không giả 124 sản phẩm hoặc 10 trang như footer P2 đang không khớp. Màu tồn được khai báo trong fixture, chưa suy ra ngưỡng sắp hết hàng. Trạng thái chỉ đọc, checkbox chưa chọn hàng loạt, cột hành động là dấu -; nút Thêm mới/Xóa mục đã chọn bị khóa và tooltip nêu rõ. Không có API ghi, không đổi tồn/giá/hiển thị hoặc store customer. Bộ lọc phụ mở bản tóm tắt và xóa điều kiện, không bịa thêm tiêu chí.

40 test gồm 9 golden qua; analyze sạch; build Web release/Wasm dry run qua; 518 asset đăng ký không thiếu file. Đã xem render 1280px và 800/390px chữ 120%. Bảng cuộn ngang với scrollbar riêng khi hẹp; header/bộ lọc/phân trang xuống dòng. Đã kiểm tra bàn phím Enter/Escape, kết quả cũ, lỗi/retry, rỗng, phân trang lớn và khóa thao tác ghi. Còn sai khác khoảng cách/độ rộng cột/font SKU so với prototype, sidebar cố ý giữ A01, chưa xác nhận pixel-perfect hoặc tương tác trình duyệt thủ công. Dữ liệu chỉ trong tiến trình mock, chưa đồng bộ app–admin.

## Bàn giao A03.1

Sửa sau bàn giao: route admin chuyển tức thời bằng PageRouteBuilder với thời lượng đi/về bằng 0, bỏ hiệu ứng chuyển cả shell khi chọn sidebar. Giữ route settings, lịch sử Back và guard/login. Thêm test vị trí header/sidebar ngay trong các frame đầu khi chuyển mục và Back; tổng hiện tại 27 test gồm 6 golden. Chưa thay sang shell dùng chung một instance hoặc cache dữ liệu dashboard.

Đọc context/screenshot Dashboard `5862`; bốn thẻ thống kê, biểu đồ đường doanh thu theo ngày và donut tỷ lệ đơn. Tái sử dụng asset icon P2 có sẵn, dùng fl_chart vẽ từ dữ liệu thay ảnh biểu đồ tĩnh. Source/fixture riêng ở features/dashboard/data, không đọc store customer. Có loading, empty, error/retry; không coi kỳ thiếu dữ liệu là doanh thu bằng 0. Có tooltip và nút Xem số liệu doanh thu để đọc bằng bàn phím; số đơn bằng 0 không chia cho 0 hoặc vẽ tỷ lệ giả.

Fixture giữ 45.2M ₫/128/34/3 và 108 thành công/20 hủy-hoàn. Tỷ lệ tính từ 108/128 = 84,4%, khác chữ 85% minh họa trong P2; chưa định nghĩa cách phân loại đơn thực. Sáu điểm Thứ 2–7 là mẫu gần hình, không phải sổ doanh thu cả tháng. Nhãn tăng trưởng cũng là fixture, chưa có kỳ trước để so sánh. Tháng này chỉ thông báo giới hạn, chưa tự thêm kỳ lọc. Tạo đơn mới chỉ thông báo, không tạo dữ liệu.

26 test qua gồm 6 golden; analyze sạch, build Web release/Wasm dry run qua. Đã xem render desktop 1280px và 800/390px chữ 120%; chữ lớn và web hẹp xếp cột, không biến admin thành app native. Còn sai khác nhỏ vùng chạm/khoảng cách/font và hình biểu đồ do thư viện vẽ; không khẳng định pixel-perfect. Chưa thử thủ công trên trình duyệt thật, chưa dữ liệu/API/quyền backend hoặc đồng bộ app–admin. Giữ phần sản phẩm và tạo đơn ở task riêng.

## Bàn giao A01

Sidebar trắng 256px, nền chính #F9F6F3, logo/nhóm Tổng quan và hai mục con, các mục sản phẩm/đơn/khách/marketing/cấu hình theo frame 5862; không tự gộp menu các frame khác. Header có tìm kiếm dạng nút minh họa, chuông và đổi giao diện. Thông tin Admin User/email/avatar, badge 3 và chấm thông báo là fixture P2, không phải phiên xác thực hoặc thông báo thật. Logout không giả kết thúc phiên chưa tồn tại. Các nút chưa làm mở dialog rõ trạng thái, không nhận dữ liệu tìm kiếm rồi bỏ qua.

Đã kiểm tra 13 asset dùng ở shell đều tồn tại/không rỗng và map đúng node, giữ kích thước SVG tương ứng; không dùng các ảnh sản phẩm Dashboard đang sai nội dung. Khi web hẹp dưới 960px sidebar vào Drawer, vẫn là web admin; menu cuộn, footer riêng, Back đóng Drawer. Cấu trúc hiện tại gồm app/admin_destination.dart và shared/layout/admin_shell/sidebar/header/styles, giữ app.dart public entry.

7 test admin qua (5 hành vi + 2 golden), analyze admin sạch; build Web release thành công, Wasm dry run qua. Đã xem render 1280×1024 và 800×1024 chữ 120%; test bổ sung 390px. Shell bám P2, có sai khác nhỏ về vùng chạm/khoảng cách/font weight; nội dung chính cố ý là màn tạm thay dashboard. Chưa kiểm tra tương tác thủ công trên trình duyệt thật, URL/reload/back-forward web đầy đủ hoặc đăng nhập/backend. Không khẳng định pixel-perfect. Navigator named routes được kiểm tra push/pop và initialRoute trong widget test.

## Bàn giao A02

Mẫu xanh 10729 đã được chọn và triển khai; ba asset logo/email/lock dùng đúng file có sẵn, map node riêng. Guard ở mọi route, login về mục đã yêu cầu, /login về tổng quan; logout xóa phiên và lịch sử Navigator. Không lưu password; reload mất phiên. Demo local/giới hạn ở README admin. Quên mật khẩu và ghi nhớ chỉ thông báo, không giả thành công.

18 test admin qua, analyze workspace sạch, build web release/Wasm dry run qua. Đã xem golden 1280×723 và 390px chữ 120%, keyboard và 800/1280 chữ lớn có test. Chưa kiểm tra tương tác trình duyệt thủ công hoặc backend thực. Ghi chú A01 phía trên là lịch sử: logout nay đã hoạt động với phiên mock và footer đọc tên/email từ phiên.
