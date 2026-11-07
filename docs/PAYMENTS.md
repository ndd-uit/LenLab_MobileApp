# Định hướng thanh toán LENLAB

Quyết định mới nhất của chủ dự án: **cổng thanh toán bên thứ ba là luồng chính; tạm dừng gửi ảnh minh chứng**. Chưa chọn nhà cung cấp hoặc có hợp đồng API backend. Tài liệu này ghi nhận hướng tích hợp, chưa phải chức năng thanh toán đã triển khai.

## Vai trò các bên

1. Frontend gửi yêu cầu bắt đầu thanh toán tới backend với định danh checkout/đơn đã được thống nhất.
2. Backend kiểm tra sản phẩm, giá, phí và tạo phiên với nhà cung cấp; trả thông tin cần thiết để app mở phiên thanh toán.
3. Khách thanh toán trong luồng của nhà cung cấp. App quay về từ luồng này và lấy trạng thái từ backend.
4. Backend xác thực kết quả với nhà cung cấp theo cơ chế họ hỗ trợ rồi cập nhật đơn. Frontend hiển thị trạng thái do backend trả về.

Không dùng ảnh minh chứng, việc mở QR, callback điều hướng trên app hoặc tham số trong return URL để tự đánh dấu đã thanh toán. Khóa bí mật và bước xác thực giao dịch thuộc backend.

## Trạng thái code hiện tại

- COD vẫn là luồng frontend mock đã bàn giao, không phải đơn đã gửi thật đến shop.
- `/bank-transfer` giữ bố cục P2 để đối chiếu UI. QR và tài khoản là minh họa; không phải phiên thanh toán của cổng.
- Đã xóa hẳn khối thêm ảnh, hướng dẫn gửi minh chứng và nút gửi khỏi màn chuyển khoản theo yêu cầu mới nhất. Widget minh chứng đã xóa, không thêm file_picker hoặc tạo đơn từ ảnh.
- `BankTransferSource` chỉ là nguồn preview mẫu, không phải adapter cổng thanh toán. `submitProof`/`confirmPayment` cũ trong mock repository chỉ phục vụ kiểm thử trạng thái thủ công, không phải hợp đồng cho tích hợp cổng.
- Chưa có PaymentGateway adapter, webhook, deep link thanh toán, giao dịch sandbox hoặc giao dịch thật. Không thêm interface chưa sử dụng khi hợp đồng tích hợp còn chưa chốt.

## Cần chốt trước khi nối cổng

- Nhà cung cấp, môi trường sandbox và tài liệu tích hợp chính thức.
- Backend/API tạo phiên, đọc trạng thái, mã lỗi và cơ chế chống tạo phiên/đơn trùng.
- Thời điểm tạo đơn, thời điểm xử lý giỏ và cách khách tiếp tục một phiên đang chờ. Chưa tự áp dụng quy tắc tạo đơn lúc gửi ảnh cho cổng thanh toán.
- Các trạng thái, hủy/hết hạn/thử lại, return URL/deep link và cách đồng bộ kết quả do backend xác thực.
- Giao diện P2 tương ứng với checkout qua cổng. Không tự đổi thiết kế chuyển khoản thủ công thành giao diện nhà cung cấp hoặc sửa Figma.

Trong khi chưa có các thông tin này, có thể tiếp tục các màn FE độc lập như chi tiết đơn hàng P2; phần thanh toán thật chưa được coi là hoàn thành.
