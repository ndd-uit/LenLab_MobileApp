# Rà soát tương tác customer - 24/10/2026

> Scope update 2026-11-04: This document contains historical milestones. For the current FE scope, removals and remaining integration work, use [FE-SCOPE-CLEANUP.md](FE-SCOPE-CLEANUP.md). Blog/digital products/advanced marketing are excluded; do not restore them from this history.

Customer đã có nhiều thao tác thay đổi dữ liệu mock trong phiên, không phải toàn bộ là UI chỉ đọc. Tuy nhiên chưa hoàn thiện tương tác: nhiều nút chỉ mở thông báo, ba màn còn tạm và thanh toán số/chuyển khoản mới là preview.

Lượt này đọc bảng route, callback nút/form, nguồn dữ liệu/store và chạy toàn bộ test customer. Chỉ cập nhật tài liệu, không sửa UI/nghiệp vụ/Figma. Chưa tap mọi nút trên Android/iOS thật; kết luận dựa trên code và widget test, không phải xác nhận native/production hay đối chiếu pixel.

## Cập nhật sau audit - FE chọn dòng giỏ

Theo quyết định mới: chỉ triển khai frontend, phần tài khoản/xác thực/database và dịch vụ backend để sau. Không làm kho tài khoản mock riêng của C01.

Đã làm phần chọn dòng giỏ của C02: mặc định chọn tất cả như P2; bấm chọn/bỏ chọn từng variant; tổng/giảm giá fixture theo phần được chọn; bỏ chọn hết khóa Thanh toán và có hướng dẫn. Checkout địa chỉ/tổng quan/phương thức/preview chuyển khoản dùng cùng danh sách được chọn. COD mock chỉ tạo đơn/xóa các dòng đã mua, giữ dòng chưa chọn; gửi lỗi giữ giỏ và lựa chọn, đang gửi khóa đổi lựa chọn. Không thay gateway, guest checkout, voucher/redeem hoặc quy tắc giảm giá hiện có. Mua lại chưa làm trong task này.

Đã xem render hai trạng thái mới; màu nút/thẻ/checkbox đã chọn giữ P2, checkbox chưa chọn là vòng rỗng cùng vị trí. Các phát hiện/mốc 279 test bên dưới là kết quả audit trước thay đổi này.

Kiểm chứng sau thay đổi: **288 test customer và 33 test shared qua**, analyze cả hai sạch. Thêm 7 test tương tác customer, 4 test store và 2 golden mới cho trạng thái chọn một phần/bỏ chọn hết; ảnh chuẩn cũ không cập nhật. Chưa chạy thủ công trên Android/iPhone thật. Các file test mới: [customer](../apps/customer/test/cart_selection_test.dart), [shared](../packages/lenlab_shared/test/cart_selection_test.dart).

## Cập nhật tiếp - FE Mua lại

Chủ dự án chốt **mở chi tiết sản phẩm hiện tại để chọn lại**, không thêm thẳng dòng từ đơn cũ. Đơn Đã giao một sản phẩm mở detail sau khi tra catalog; nhiều sản phẩm có hộp chọn. Tra theo ID, không ghép bằng tên, dùng giá/catalog hiện tại, không giữ số lượng/biến thể cũ vì chưa có dữ liệu xác minh biến thể còn bán. Nhiều biến thể cũ của cùng sản phẩm chỉ tạo một lựa chọn detail.

Có loading/lỗi/Thử lại, trường hợp đơn thiếu dòng, sản phẩm không tìm thấy/ẩn/hết hàng hoặc ID trùng. Đóng/Back khi tải không điều hướng muộn; chưa thay đổi giỏ/đơn cho đến khi khách tự bấm Thêm vào giỏ trên detail. Chỉ dùng port đọc products hiện có, không backend/tạo đơn/thanh toán/tự trừ tồn.

**297 test customer qua, analyze sạch**; thêm 7 test hành vi/nguồn dữ liệu và 2 golden mới cho hộp chọn 390px, 360px chữ 120%. Golden cũ giữ nguyên. Đã xem hai bản render; chưa chạy thiết bị native thật. Xem [buy_again_test.dart](../apps/customer/test/buy_again_test.dart).

## Cập nhật C03 và đồng bộ checkbox

Đã đọc lại P2 sổ địa chỉ `2026:4234` và editor `2026:3872`. FE Xóa có xác nhận Giữ lại/Xóa, đang gửi khóa thao tác/Back, lỗi có Thử lại/Tải lại sổ địa chỉ. Theo P2 chỉ hiện Xóa với địa chỉ không mặc định; muốn xóa mặc định phải đặt địa chỉ khác trước. Nếu xóa địa chỉ không mặc định cuối cùng thì hiển thị sổ rỗng, không tự tạo địa chỉ thay thế.

Đã đổi mặc định qua dấu tròn ở card, hoặc bật công tắc trong form rồi Lưu. Trong form, bật/tắt chỉ là draft đến khi lưu; Hủy không đổi dữ liệu. Không tắt trực tiếp địa chỉ đang mặc định mà chưa chọn địa chỉ thay thế. Cờ mặc định cập nhật trong sổ, không tự đổi deliveryAddress đang nhập hoặc snapshot đơn. Xóa địa chỉ đang dùng ở checkout cũng không xóa draft đó; không thêm tự điền mặc định vào checkout trong task này.

Theo yêu cầu mới, CustomerSelectionMark dùng chung cho giỏ/sổ địa chỉ/phương thức thanh toán: nền trắng, viền nâu và cùng dấu tích nâu. Giữ vùng bấm và semantics chọn nhiều/chọn một ở từng màn, Switch vẫn là công tắc. Đây là điều chỉnh theo yêu cầu người dùng, khác màu radio riêng của P2. Không đổi admin hoặc theme chung.

**306 test customer qua, analyze sạch.** Thêm 7 test C03 và 2 golden xác nhận xóa; cập nhật các golden có checkbox thay đổi chủ đích. Đã xem render dialog 390px/360px chữ 120%, sổ địa chỉ và phương thức thanh toán; chưa thử thiết bị Android/iPhone thật. Xem [address_actions_test.dart](../apps/customer/test/address_actions_test.dart). Chỉ mock trong bộ nhớ, không backend/persistence.

## C04 - sheet biến thể Merino theo P2

Đã triển khai sheet `2034:5` khi bấm Thêm vào giỏ trên detail Merino. Tên/giá từ Product, màu Be/Nâu/Xám, kích thước 180/200 cm, số lượng, tổng tiền, xác nhận và Hủy lựa chọn. Sheet lấy lựa chọn hiện tại từ detail; Hủy/Back/scrim không sửa giỏ hoặc selection detail. Sau xác nhận cập nhật lựa chọn ở detail và thêm/gộp đúng dòng giỏ. Kiểm tra tổng quantity cùng variant với tồn mock hiện có; vượt tồn báo lỗi, không tự giảm quantity. Đây chưa là hệ thống SKU/tồn theo biến thể từ backend.

Giữ key màu `Kem` và size `180cm/200cm` hiện có; Be/Be tự nhiên chỉ là label P2 cho Kem, không tạo key mới làm tách dòng giỏ. Chỉ Merino có dữ liệu lựa chọn rõ, sản phẩm khác giữ luồng cũ. Sheet nền #F7F2E8/bo 24/padding 24, nút chính #DBA324 và Hủy outline theo frame; chữ lớn/hẹp cuộn và wrap. Không có asset ảnh/icon riêng trong vùng sheet; ảnh phía sau dùng Product/detail hiện tại, không thay các quyết định header/rating chung.

Avatar đã được chủ dự án yêu cầu bỏ qua, không còn là task kế tiếp. Không triển khai upload/backend trong C04. Kiểm chứng cuối: **313 test customer qua, analyze sạch**; đã xem hai render sheet 390px/360px chữ120%, không cập nhật ảnh chuẩn cũ; chưa thử thiết bị thật.

## C05 - avatar: đã mở lại theo yêu cầu mới

Quyết định mới thay việc bỏ qua avatar: icon camera/nút Đổi ảnh đại diện trong Sửa hồ sơ mở thư viện ảnh native bằng image_picker 1.2.4. Chọn ảnh xong xem trước hình tròn; dữ liệu còn là draft, chỉ Lưu hồ sơ mới ghi mock. Hủy picker giữ ảnh đang xem, Back editor bỏ thay đổi; lưu lỗi giữ draft để thử lại. Không có chụp ảnh/crop/upload/lưu file hoặc backend. Ảnh lưu trong bộ nhớ, khởi động lại không đảm bảo giữ hồ sơ/ảnh đã lưu mock.

Kiểm tra ảnh rỗng/không decode được trước preview/lưu; lỗi quyền hoặc đọc file hiển thị riêng và cho chọn lại. Đang chọn khóa gọi picker/lưu trùng; kết quả sau khi đóng editor hoặc đổi phiên bị bỏ qua. Nguồn save kiểm tra phiên sau await, lưu trường hồ sơ và bytes ảnh sau khi thao tác mock thành công. Không sửa email/địa chỉ/đơn.

AvatarPickerSource tách native picker để kiểm thử; GalleryAvatarPicker chỉ dùng gallery/requestFullMetadata=false. iOS có NSPhotoLibraryUsageDescription; Android không thêm quyền truy cập storage rộng. main khởi động retrieveLostData một lần trên Android; khi mở editor ảnh khôi phục chỉ được xem trước, không tự lưu. Không khôi phục toàn bộ phiên/form sau process restart. Ảnh trong bản golden là fixture explicit, runtime không tự gán ảnh mẫu P2 cho người dùng.

ProfileAvatar hiển thị Image.memory trước asset legacy; ProfileSummary/ProfileDraft/CustomerProfile có avatarBytes, cùng ảnh được đọc ở Hồ sơ/Sửa hồ sơ/Drawer. 321 test customer và 33 test shared qua, analyze customer sạch; thêm 6 test avatar và hai golden 390px/360px chữ 120%, giữ golden cũ. Đã xem render; chưa kiểm thử picker/HEIC/quyền trên thiết bị Android/iPhone thật.

**Giới hạn build C05:** đã thử `flutter build apk --debug --no-pub`; Gradle wrapper còn tải bản 9.3.1-all rất chậm (chưa tới bước compile app), đã chủ động dừng lượt build. Chưa xác nhận APK hoặc picker native. Cần chạy lại build khi Gradle đã tải xong; không đổi phiên bản wrapper để né bước tải và không đánh dấu build thành công.

## C06 - ảnh đính kèm đánh giá sau mua

Chủ dự án chốt **tối đa 5 ảnh JPG/PNG, mỗi ảnh tối đa 5 MB** (5 × 1024 × 1024 byte). Thêm ảnh/bỏ từng ảnh/xem trước ngay trong form sau mua; ảnh không bắt buộc. Gallery đọc qua image_picker hiện có, không camera/crop/backend. Kiểm tra số lượng, dung lượng, chữ ký JPG/PNG và khả năng decode thực tế. Một lượt chọn không hợp lệ bị từ chối toàn lượt, giữ các ảnh cũ, có lỗi để chọn lại; Hủy picker không đổi draft.

Ảnh chỉ nằm ở draft của đúng orderId/productId/phiên, đổi sản phẩm hoặc chọn đánh giá sản phẩm khác xóa draft ảnh cũ. Đang đọc ảnh khóa picker/chuyển sản phẩm/gửi; đang gửi khóa ảnh. Kết quả trả muộn sau Back/đổi order/phiên bị bỏ qua. Lưu lỗi giữ ảnh và nhận xét; lưu thành công chụp List/bytes bất biến vào ReviewDraft/ProductReview.localPhotos. Các asset photos P2 cũ vẫn giữ riêng. ReviewCollection.hasImages/imageCount/filter nhận cả ảnh asset và ảnh bộ nhớ; ReviewCard hiển thị ảnh mới theo cùng nhóm ảnh hiện có. Không ghi lượt hữu ích hoặc mở sửa đánh giá.

Không upload/persistence hoặc tự gắn ảnh sau process restart. Marker `avatar`/`review` trong cache riêng chỉ phân biệt mục đích native picker, không chứa dữ liệu người dùng/đơn/ảnh; Android recovery chỉ phục hồi preview nếu marker avatar, không gán ảnh đánh giá vào avatar khi ứng dụng bị khởi động lại. Ảnh đánh giá bị gián đoạn cần chọn lại sau khi mở đúng form. iOS mô tả thư viện ảnh đã bao gồm avatar và ảnh đánh giá.

Kiểm chứng: toàn bộ 328 test customer qua, cộng 1 test mới chống khôi phục nhầm ảnh qua; 36 test shared qua, analyze workspace sạch. Có 5 test tương tác ảnh đánh giá/3 test shared và 1 test recovery; thêm 2 golden đính kèm 390/360px chữ120%, cập nhật 2 golden form cũ có trường ảnh mới. Đã xem render; chưa kiểm thử multi-picker/giới hạn/permission native trên thiết bị thật, không chạy lại build Gradle ở task này. Người dùng đã xác nhận luồng avatar ở lượt trước.

## Ma trận từng màn

“Lưu mock” nghĩa là có thay đổi dữ liệu trong bộ nhớ tiến trình, chưa backend/persistence. “Thông báo” nghĩa là bấm được nhưng chức năng chính chưa thực hiện. Một màn có thể vừa hoạt động vừa còn các nút thông báo.

| Màn / điểm vào | Hoạt động hoặc lưu mock | Còn thiếu / chỉ thông báo |
| --- | --- | --- |
| Login `/login` | Nhập, validation, ẩn/hiện mật khẩu, tải/lỗi/thử lại, đổi phiên mock/về Home | Google/Quên mật khẩu chỉ thông báo; danh tính chưa gắn với hồ sơ riêng |
| Register `/register` | Nhập tên/identity/mật khẩu/xác nhận, validation; submit đổi tên và phiên mock | Gọi cùng signIn với login, không có tạo tài khoản riêng; email/điện thoại hồ sơ vẫn fixture |
| Home `/` | Mở menu/catalog/detail/bài viết/giới thiệu/giỏ; tài khoản theo phiên | Tìm kiếm đưa sang catalog. Size/social chỉ thông báo; Liên hệ/Chính sách tới màn tạm |
| Drawer | Đóng/Back/chọn mục/login/register/profile/logout, đọc profile mock | Điều khoản và kênh mạng xã hội chưa có nội dung/đích thật |
| Catalog vật lý `/products` | Tìm tên, lọc danh mục/sheet, sắp giá, phân trang, xóa lọc/retry, mở Product | Nút + mở detail; Merino có sheet khi bấm Thêm vào giỏ trên detail, chưa thêm nhanh từ catalog. Không tìm SKU, lọc chỉ danh mục |
| Detail vật lý `/product` | Số lượng theo tồn, màu/size Merino, thêm/gộp giỏ mock, yêu thích, reviews/related/cart; guard payload sai | Ảnh bổ sung/Hướng dẫn đo chỉ thông báo; chưa danh sách yêu thích hoặc hệ SKU biến thể đầy đủ |
| Giỏ member `/cart` | Tăng/giảm/xóa, chọn/bỏ chọn dòng, tổng theo lựa chọn, khóa khi không chọn gì, checkout đúng dòng đã chọn | Voucher/menu ba chấm chỉ thông báo. LEN50 vẫn fixture, chưa áp/redeem mã thật |
| Giỏ guest `/cart` | Popup sáng, Để sau/đóng/Back giữ giỏ, CTA login; sau đóng thao tác giỏ được | Nền trắng che sản phẩm theo yêu cầu mới. Chưa chốt gộp giỏ/guest checkout; sau Để sau vẫn có thể tới checkout |
| Giao hàng `/checkout` | Form/validation, tỉnh–huyện–xã phụ thuộc, chọn địa chỉ đã lưu, lưu mock tùy chọn, sửa về tổng quan | Địa giới/dịch vụ địa chỉ vẫn mock |
| Tổng quan `/order-review` | Dòng/tổng từ nguồn mock, nhập và giữ ghi chú, sửa địa chỉ, sang phương thức, tải/lỗi/retry | Phí/giảm giá chưa phải quy tắc production |
| Phương thức `/payment-method` | COD khóa gửi/lỗi/retry/tạo đúng đơn mock và dọn giỏ; mở preview chuyển khoản | Chưa gateway/thu tiền; chuyển khoản chưa tạo đơn hoặc xác nhận thanh toán |
| COD thành công `/cod-confirmation` | Hiển thị đúng đơn vừa tạo và mở đúng detail | Chỉ kết quả đặt đơn mock, không phải thanh toán đã đối soát |
| Chuyển khoản `/bank-transfer` | Tải/retry, xem tổng, copy dữ liệu minh họa, Back | Chỉ preview, không giao dịch thật; không khôi phục gửi ảnh/xác nhận thủ công |
| Đơn `/orders` | Tab trạng thái, refresh/retry, đúng ID, đánh giá đơn Đã giao; Mua lại tra catalog hiện tại và mở detail để chọn lại | Bộ đơn mẫu chung, chưa tài khoản thực; guest mở route trực tiếp vẫn xem fixture. Không thêm thẳng dòng cũ vào giỏ |
| Chi tiết đơn `/order-detail` | Cùng nguồn theo ID, trạng thái/thông tin, đánh giá khi Đã giao, hỗ trợ kèm mã đơn | Hỗ trợ chỉ mở FAQ, chưa gửi ticket. Hủy đơn đã bỏ theo yêu cầu, không tính là thiếu tương tác |
| Viết đánh giá `/write-review` | Phiên mock/đơn Đã giao; đúng sản phẩm, sao bắt buộc/nhận xét/ảnh tùy chọn; chọn/bỏ/preview ảnh, gửi/retry/lưu mock, rating/list/filter đồng bộ | Một lần mỗi sản phẩm/đơn, chưa sửa. Ảnh tối đa5 JPG/PNG mỗi ảnh5MB, chưa upload/persistence; ownership thật cần backend |
| Đánh giá `/reviews` | Lọc/sắp xếp/ảnh, retry/xóa lọc, đọc đúng product ID | Hữu ích chỉ thông báo, chưa ghi lượt; viết đánh giá đi từ đơn, không từ detail sản phẩm |
| Bình luận `/comments` | Đọc đúng ID, tải/rỗng/lỗi/retry | Ô Thêm bình luận chỉ là vùng bấm thông báo, không phải input; gửi/trả lời/ảnh/hữu ích chưa có; chưa nối điểm mở từ detail |
| Catalog số `/digital` | Tìm/lọc danh mục/miễn phí, mở Product; phân trang khi nguồn trên sáu dòng | Không có sắp giá như catalog vật lý; fixture nhỏ nên chưa hiện phân trang mặc định |
| Detail PDF/video/e-book | PDF metadata/retry/reviews; Mua ngay truyền đúng Product tới checkout số | Video/e-book dùng detail chung, chưa player/file; share PDF/mô tả bổ sung chỉ thông báo |
| Checkout số `/digital-checkout` | Ảnh/tên/format/giá đúng sản phẩm, guard dữ liệu, Back/catalog | Preview; chưa form đặt mua đầy đủ, đơn số/gateway/thanh toán/cấp quyền |
| Thư viện `/library` | Guard phiên, tìm/lọc/trạng thái, quyền mẫu | Xem tiếp/Tải/menu ba chấm chỉ thông báo; chưa mở/phát/tải hoặc cập nhật tiến độ, đúng phạm vi đã hoãn |
| Hồ sơ `/profile` | Guard phiên/tải/retry, mở sửa/đơn/địa chỉ/voucher/thư viện, logout | Cài đặt tài khoản chỉ thông báo; chưa phân tách dữ liệu nhiều tài khoản |
| Sửa hồ sơ | Nhập/validation tên/điện thoại/giới tính/ngày sinh, chọn ảnh thư viện/xem trước/lưu avatar mock, lỗi/retry và cập nhật profile/menu | Email chỉ đọc; mật khẩu chỉ thông báo; avatar chưa upload/persistence/API |
| Sổ địa chỉ/editor `/addresses` | Guard phiên/tải/rỗng/retry, thêm/sửa/lưu mock, xác nhận xóa, đổi mặc định trên card/form; lỗi/retry | Không xóa mặc định trước khi chọn địa chỉ thay thế; không sửa checkout draft hoặc snapshot đơn, chưa persistence/API |
| Voucher `/vouchers` | Guard phiên, nhập mã/kiểm tra rỗng, tab/trạng thái, copy mã có sẵn và xử lý lỗi clipboard | Áp dụng/Dùng ngay chỉ thông báo, chưa redeem; mã thiếu không tự sinh, hiệu lực là fixture |
| FAQ/hỗ trợ `/faq`, `/support` | Tìm/lọc/accordion/trạng thái, kèm ID đơn | Chỉ một câu có đáp án P2; chưa gửi yêu cầu/chat hỗ trợ |
| Blog/bài `/blog`, `/article` | Tìm/lọc/trạng thái, đúng ID, Back giữ query, đọc nội dung đã có | Nhiều bài thiếu thân bài; share/video/sản phẩm minh họa không thực hiện hành động thật |
| Giới thiệu `/about` | Cuộn/tải/retry/CTA catalog | Nội dung thương hiệu còn là mẫu cần duyệt |
| `/customs`, `/chat`, `/policies` | Màn tạm có tên/thông báo riêng, Back/Home | Chưa UI nghiệp vụ/gửi yêu cầu/chat/tính len/chính sách công bố |

## Phát hiện cần ưu tiên

### F1 - danh tính mock chưa nhất quán

[AuthPage](../apps/customer/lib/features/auth/presentation/auth_page.dart) gọi repository.signIn cho cả login và register; register chỉ đổi tên, chưa cập nhật email/điện thoại từ identity. [MockLenlabRepository](../packages/lenlab_shared/lib/src/data/mock_lenlab_repository.dart) chỉ kiểm tra không rỗng sau độ trễ, không có kho tài khoản. [CustomerProfile](../packages/lenlab_shared/lib/src/domain/models.dart) là hồ sơ Nguyễn Văn A mẫu.

Khi đăng ký email mới rồi mở Hồ sơ vẫn có thể thấy email mẫu. Form bấm được nhưng chưa có tạo danh tính mock nhất quán, càng chưa phải tài khoản thật. Cần rà mô hình phiên/hồ sơ trước khi thử nhiều người dùng; không tự nối đơn/voucher theo tên.

### F2 - nút trông dùng được nhưng chỉ thông báo

Các nhóm dễ hiểu nhầm nhất:

- Giỏ: [voucher](../apps/customer/lib/features/cart/presentation/widgets/cart_voucher.dart), menu ba chấm. Chọn từng dòng đã hoạt động sau audit.
- Đơn: Mua lại đã có FE mở detail để chọn lại; không còn là nút chỉ thông báo.
- Địa chỉ: Xóa/đổi mặc định đã có FE mock trong C03; không còn là nút chỉ thông báo.
- Hồ sơ: mật khẩu/cài đặt; avatar đã có chọn/xem trước/lưu mock trong C05.
- Voucher: [Áp dụng/Dùng ngay](../apps/customer/lib/features/vouchers/presentation/voucher_page.dart).
- Nội dung số: Xem tiếp/Tải (`apps/customer/lib/features/library/presentation/widgets/library_card.dart`; historical reference; source removed from MVP, do not restore).

Không coi mọi mục trên là lỗi: redeem/nội dung thật đã được chủ động hoãn. Tuy nhiên toast chưa hỗ trợ không được tính là chức năng đã xong. Nên ưu tiên tương tác giỏ/đơn/địa chỉ đã đủ quy tắc, thay vì dựng thêm màn chỉ xem.

### F3 - guest checkout và phạm vi dữ liệu chưa chốt

[CartPage](../apps/customer/lib/features/cart/presentation/cart_page.dart) cho Để sau; [CartCheckoutButton](../apps/customer/lib/features/cart/presentation/widgets/cart_checkout_button.dart) sau đó mở checkout không kiểm tra phiên. Route đơn/detail cũng đọc fixture chung, không guard tài khoản. Đánh giá kiểm tra signedIn và Đã giao trong store, chưa có hệ thống ownership thật.

Ghi nhận đây là hành vi mock hiện có, không kết luận đã chốt guest checkout hoặc bảo vệ dữ liệu nhiều người dùng. Không tự khóa/mở hoặc thay đổi gộp giỏ khi chưa có quyết định.

### F4 - luồng số/hỗ trợ chưa đi đến hành động chính

Mua ngay truyền đúng sản phẩm nhưng dừng ở checkout preview (`apps/customer/lib/features/checkout/presentation/digital_checkout_preview_page.dart`; historical reference; source removed from MVP, do not restore). Thư viện chỉ metadata/quyền mẫu. Liên hệ footer tới Chat tạm; hỗ trợ trong đơn tới FAQ/dialog, chưa tạo ticket. Bình luận có UI nhưng chưa có điểm mở từ detail. Trang mở được không đồng nghĩa luồng hoàn thiện.

## Kiểm chứng và giới hạn

Chạy ngày 24/10/2026 tại apps/customer:

- flutter test --no-pub --reporter expanded: **279 test qua**, gồm tương tác và golden hiện có; không cập nhật ảnh chuẩn trong lượt audit.
- flutter analyze --no-pub: **không lỗi/cảnh báo**.
- Đọc 27 nhánh route rõ ràng; editor hồ sơ/địa chỉ push trực tiếp. Ba route tạm qua PendingPage ghi riêng trong ma trận.

Bằng chứng test: [đăng ký](../apps/customer/test/register_test.dart), [giỏ](../apps/customer/test/cart_test.dart), [guest](../apps/customer/test/guest_cart_test.dart), [COD](../apps/customer/test/cod_checkout_test.dart), [sửa hồ sơ](../apps/customer/test/profile_editor_test.dart), [địa chỉ](../apps/customer/test/address_editor_test.dart), [đánh giá sau mua](../apps/customer/test/post_purchase_review_test.dart), checkout số (`apps/customer/test/digital_checkout_preview_test.dart`; historical reference; source removed from MVP, do not restore), [điều hướng](../apps/customer/test/customer_navigation_test.dart).

Test qua xác nhận hành vi đang được kiểm tra, không chứng minh mọi nút P2 đã làm. Chưa chạy máy Android/iPhone, gateway, player/file, email/tin nhắn, persistent storage, xác thực hoặc phân quyền backend. Không dùng kết quả Flutter Web admin để xác nhận customer native.

## Task tiếp đề xuất

1. **C01 - để backend sau:** không làm kho tài khoản/xác thực mock riêng theo quyết định chỉ làm FE. F1 vẫn là giới hạn tích hợp, không coi là đã sửa.
2. **C02 - đã xong FE chọn dòng giỏ và Mua lại:** Mua lại mở detail hiện tại để chọn lại theo quyết định mới; không tự thêm dòng/biến thể/giá cũ.
3. **C03 - đã xong:** xác nhận xóa/đổi mặc định bằng mock, giữ draft checkout/snapshot đơn; checkbox dùng chung màu nâu theo yêu cầu.
4. Hoãn phần phụ thuộc chưa chốt: gateway, redeem, nội dung thật, custom/chat/công thức len/chính sách; không mở lại gửi minh chứng.

Lượt audit ban đầu không sửa chức năng; các task sau audit đã hoàn thành C02/C03/C04/C05/C06. Đề xuất tiếp: kiểm thử nhiều ảnh đánh giá/quyền/Hủy/giới hạn5ảnh5MB/gửi lỗi rồi thử lại trên Android. iOS cần macOS/Xcode. Không mở thêm nghiệp vụ chưa chốt.
