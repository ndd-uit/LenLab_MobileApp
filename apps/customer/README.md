# LENLAB Customer

Flutter/Dart cho app iOS/Android. Điểm khởi chạy: `lib/main.dart`. Chưa có backend thật.

P0-04 dừng ở đợt 4A: giỏ/checkbox/coupon Guest/A/B tách riêng trong RAM. Guest và B mới rỗng, hàng fixture thuộc A; coupon không tự áp. Logout giữ giỏ account và tạo Guest mới rỗng. Quyết định hiện hành: không tự động merge giỏ Guest/account, không triển khai 4B/4C. Dữ liệu Guest pending của implementation cũ vẫn chỉ được giữ riêng, không phải cam kết sẽ merge. Giỏ của detached COD chưa reconcile; không tuyên bố 4C hoàn tất. Xem [báo cáo 4A](../../docs/P0-04-BATCH-4A.md).

Mốc lịch sử đợt 3: profile/avatar, địa chỉ, đơn hàng, favorites và Custom đã tách theo user ID trong RAM. Draft và form riêng được vô hiệu hóa khi đổi phiên; COD hoàn tất ở phiên cũ trở lại lịch sử đúng chủ đơn một lần. Giỏ đã được tách tiếp ở 4A như trên; xử lý giỏ detached COD vẫn chưa hoàn thành. Xem [báo cáo đợt 3](../../docs/P0-04-BATCH-3.md).

Đợt 2 đã triển khai: Guest được sửa giỏ; Thanh toán yêu cầu Auth rồi về giỏ để xem lại. Checkout/private routes và COD Store có guard; xem [báo cáo đợt 2](../../docs/P0-04-BATCH-2.md).

Đăng nhập mock dùng `nguyenvan.a@example.com` / `0901234567` (A) hoặc `nguyenvan.b@example.com` / `0901234568` (B). Mật khẩu bất kỳ không rỗng, chỉ dùng giá trị thử nghiệm; mock không lưu mật khẩu. Email/số điện thoại mới phải qua Đăng ký để tạo ID riêng trong RAM. Fixture cũ thuộc A tường minh; B và người đăng ký mới không nhận hồ sơ, địa chỉ hoặc đơn của A. Nền tảng identity/session: [báo cáo đợt 1](../../docs/P0-04-BATCH-1.md).

Phạm vi mới: sản phẩm vật lý; đã bỏ Blog, sản phẩm số, thư viện số và checkout số. Giữ Chatbot/Custom ở trạng thái hiện có. COD/chuyển khoản vẫn mock; VNPay thuộc MVP nhưng chưa tích hợp. Báo cáo và giới hạn: [FE-SCOPE-CLEANUP.md](../../docs/FE-SCOPE-CLEANUP.md).

Voucher: public campaign/usage riêng, candidate/evaluation/quote kỹ thuật, exit command R1 và provider shipping R2 đã có. Chưa nối UI bỏ voucher, fixture/provider demo mặc định hoặc Payment/COD quote hoàn chỉnh. COD voucher mới vẫn bị safety gate chặn; LEN50 và phí legacy chỉ là fixture. Không có payment API hoặc quota/stock transaction có thẩm quyền tại Flutter. Xem [R2](../../docs/P1-01-R2.md).

- `lib/app/`: route và scope.
- `lib/features/`: auth, home, catalog, products, cart, checkout.
- `lib/shared/`: component dùng qua nhiều tính năng.
- Mỗi feature ghép màn trong `presentation/` từ các component ở `presentation/widgets/`.
- Màu nút theo từng vai trò P2, không đổi theme toàn cục để ép một màu.

Chạy từ thư mục này: `flutter pub get`, `flutter run -d <device-id>`. Kiểm tra: `flutter analyze` và `flutter test`.

Giỏ đã chọn/bỏ chọn từng dòng: tổng tiền và checkout theo phần được chọn; không chọn gì khóa Thanh toán. COD mock chỉ mua/xóa các dòng đã chọn, giữ phần còn lại; chưa thanh toán/backend thật. Lựa chọn lưu trong bộ nhớ, không persistence.

Nút Mua lại trong đơn Đã giao tra catalog và mở detail hiện tại để chọn lại số lượng/phân loại; đơn nhiều sản phẩm có hộp chọn. Không tự thêm dòng cũ vào giỏ, tạo đơn hoặc thanh toán. Có kiểm tra thiếu/hết hàng/ẩn và retry khi tải lỗi.

Sổ địa chỉ đã có xác nhận xóa dòng không mặc định, đổi mặc định trên card hoặc lưu form, khóa gửi/lỗi/retry; giữ draft checkout và đơn cũ. Giỏ/sổ địa chỉ/phương thức dùng chung checkbox nền trắng/viền và dấu tích nâu. Mọi thay đổi địa chỉ chỉ mock trong bộ nhớ.

Merino có sheet chọn biến thể P2: từ detail bấm Thêm vào giỏ → chọn màu/size/số lượng → xác nhận; Hủy/Back không đổi giỏ. Chỉ mock cấp sản phẩm, chưa tồn SKU thật.

Avatar đã mở lại theo yêu cầu: Sửa hồ sơ → Đổi ảnh đại diện → chọn từ thư viện → xem trước → Lưu. Ảnh đồng bộ ở Hồ sơ/Drawer trong bộ nhớ; Back/Hủy không commit. Có lỗi quyền/ảnh hỏng/lưu thử lại, Android lost-data phục hồi preview. Dùng image_picker 1.2.4, iOS có NSPhotoLibraryUsageDescription. Không camera/crop/upload/backend/persistence; app restart có thể về ảnh mẫu/placeholder. Sau thêm plugin cần dừng và chạy lại app, hot reload không nạp plugin native. Cần thử quyền/HEIC trên thiết bị thật; iOS cần macOS/Xcode.

C05 kiểm chứng: 321 test customer/33 shared qua, analyze customer sạch. Lượt APK debug đã dừng khi wrapper còn tải Gradle9.3.1-all chậm, chưa tới compile app; chưa xác nhận build Android hoặc chạy picker thật. Chạy lại `flutter build apk --debug` sau khi Gradle tải xong.

Ảnh đánh giá: Đơn Đã giao → Đánh giá → Thêm ảnh, tối đa5 JPG/PNG, mỗi ảnh5MB. Có preview/bỏ ảnh; Gửi đánh giá mới lưu cùng review mock. Lỗi giữ ảnh để thử lại, đổi sản phẩm không mang ảnh cũ. Danh sách/lọc Có hình ảnh hiển thị ảnh bộ nhớ; chưa upload/persistence. Trường hợp app bị hệ thống khởi động lại lúc chọn ảnh đánh giá cần chọn lại; không khôi phục nhầm sang avatar. C06:328 test toàn customer+1 test recovery riêng,36shared qua; analyze workspace sạch. Multi-picker native cần thử thực tế.

Xem [hướng dẫn dự án](../../README.md) và [bản đồ codebase](../../docs/CODEBASE.md).

P0-04: avatar recovery native sau restart không có owner RAM xác minh được nên không tự áp vào tài khoản đăng nhập đầu tiên. Chọn ảnh mới trong phiên vẫn hoạt động; kết quả picker phiên cũ bị bỏ qua.
