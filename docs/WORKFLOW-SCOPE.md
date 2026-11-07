# Phạm vi nghiệp vụ đang triển khai

> Scope update 2026-11-04: This document contains historical milestones. For the current FE scope, removals and remaining integration work, use [FE-SCOPE-CLEANUP.md](FE-SCOPE-CLEANUP.md). Blog/digital products/advanced marketing are excluded; do not restore them from this history.

> Cập nhật 05/11/2026 - P0-04: đã đối chiếu hai bản gốc SRS/UI-UX bổ sung, không có blocker mới trực tiếp 4A. Xem [CART Business Rules](P0-04-CART-BUSINESS-RULES.md) và [bàn giao 4A](P0-04-BATCH-4A.md). Giỏ/checkbox/coupon Guest/A/B được tách trong RAM; fixture cũ thuộc A, Guest/B mới rỗng, coupon không tự áp. Guest cart khi login được giữ riêng chờ merge 4B, chưa reconcile giỏ COD 4C. Quy tắc checkout chỉ chặn dòng không hợp lệ được chọn mua. Các ghi chú lịch sử bên dưới không thay thế D01–D12 và sáu chính sách mới. Dừng chờ nghiệm thu 4A.

Quyết định mới nhất của chủ dự án: tạm để lại các nghiệp vụ chưa chốt; tiếp tục từng task có đủ thông tin. Cả app khách hàng và admin web dùng Flutter/Dart. Báo cáo kiến trúc Laravel/web cũ không thay thế lựa chọn hiện tại.

## Quyết định mới - chỉ làm frontend customer

Không triển khai kho tài khoản/xác thực/database/dịch vụ backend cho C01. FE tiếp tục nhập liệu/validation/điều hướng/trạng thái và dữ liệu mock để thử UI. Phần chọn dòng giỏ đã được duyệt: mặc định chọn tất cả, tổng và checkout theo lựa chọn; COD mock chỉ xóa dòng đã mua, giữ dòng chưa chọn. Chưa tự chốt gộp giỏ/guest checkout, redeem, gateway, hủy/hoàn hoặc quyền nội dung thật. Mua lại và Xóa/đổi mặc định địa chỉ là task riêng, chưa làm cùng lượt này.

## Mua lại - quyết định FE đã chốt

Chủ dự án chọn mở chi tiết sản phẩm hiện tại để khách chọn lại biến thể/số lượng, không thêm thẳng dòng cũ. Nút ở đơn Đã giao tra catalog theo ID, kiểm tra hiển thị/tồn; một sản phẩm mở detail, nhiều sản phẩm có hộp chọn. Không tìm thấy/ID trùng/ẩn/hết hàng báo không khả dụng, lỗi đọc có Thử lại. Không dùng giá/variant/quantity cũ, tự giảm lượng theo tồn, tạo đơn, thanh toán hoặc trừ tồn. Chưa làm C03 Xóa/đổi mặc định địa chỉ; quy tắc backend chưa chốt vẫn hoãn.

## C03 và checkbox - đã có FE mock

Xóa có xác nhận, chỉ địa chỉ không mặc định theo P2; muốn xóa mặc định chọn địa chỉ khác trước. Xóa địa chỉ không mặc định cuối cùng cho sổ rỗng, không tự tạo địa chỉ. Đổi mặc định qua card hoặc công tắc rồi Lưu trong form; giữ địa chỉ đang mặc định khi chưa chọn thay thế, không tự chọn mặc định đầu tiên. Mọi thay đổi chỉ trong sổ địa chỉ mock, không sửa draft checkout đang nhập/snapshot đơn, không tự thêm auto-fill vào checkout mới. Lỗi có retry, stale record có tải lại; đang gửi khóa thao tác. Không backend/database/persistence.

Yêu cầu mới đồng bộ checkbox customer ưu tiên hơn màu riêng của các frame: giỏ/sổ địa chỉ/phương thức dùng chung nền trắng, viền nâu/dấu tích nâu. Giữ hành vi chọn nhiều/chọn một và Switch bật/tắt, không lan sang admin.

## C04 và task avatar

Chủ dự án yêu cầu bỏ qua FE chọn/xem trước avatar, không tiếp tục đề xuất task này. C04 dùng sheet biến thể P2 2034:5 chỉ cho Merino: chọn màu/size/quantity/tổng, confirm mới thêm mock giỏ và cập nhật selection detail; cancel/Back không commit. Be hiển thị là cùng key Kem cũ, không tạo biến thể khác. Giới hạn stock là dữ liệu mock cấp Product và số lượng cùng variant trong giỏ hiện có; chưa hệ SKU/tồn theo biến thể, chưa backend. Không mở rộng lựa chọn sang sản phẩm khác khi chưa có dữ liệu.

## C05 - mở lại avatar theo yêu cầu mới nhất

FE chọn avatar từ thư viện native/xem trước/lưu mock đã được yêu cầu trở lại; thay quyết định bỏ qua trước đó. Chỉ gallery, không camera/crop/upload/backend/persistence. Draft chỉ commit khi Lưu hồ sơ thành công, Cancel/Back giữ ảnh cũ; lỗi quyền/file/save có xử lý, Android lost-data chỉ phục hồi preview. Hồ sơ/Drawer dùng chung ảnh bộ nhớ. Quy tắc dung lượng/định dạng upload server chưa chốt nên không áp giới hạn JPG/PNG/5MB của luồng minh chứng cũ sang avatar.

## C06 - ảnh đánh giá đã chốt giới hạn

Theo trả lời chủ dự án: tối đa5 ảnh JPG/PNG, mỗi ảnh tối đa5MB (5*1024*1024 byte). FE chọn thư viện/xem trước/bỏ ảnh, validation số lượng/dung lượng/format/ảnh đọc được; submit mock gắn đúng order/product và chỉ một lần như đánh giá cũ. Ảnh không bắt buộc. Batch chọn lỗi không làm mất draft; submit lỗi giữ ảnh/nhận xét. Đổi sản phẩm/đơn xóa draft cũ, không tự mang ảnh sang review khác. Danh sách và lọc ảnh dùng cùng localPhotos.

Chưa upload/persistence/backend/chỉnh sửa hoặc camera/crop. Nếu Android process bị hủy trong lúc chọn ảnh đánh giá thì mở lại đúng form và chọn lại; không auto-restore thiếu liên kết order/product hoặc dùng ảnh đó làm avatar. Avatar có marker purpose riêng để recovery không nhận nhầm. Giới hạn này chỉ cho review, không áp sang avatar hoặc mở lại minh chứng chuyển khoản.

## Nguồn và thứ tự áp dụng

- Quyết định mới nhất của chủ dự án trong trao đổi.
- UI từ ba trang Figma P2 được duyệt; không sửa Figma.
- Báo cáo `Nhóm 4_LenLabProject_Report.pdf` và `Giải trình sau báo cáo - Nhóm 4.docx` trong thư mục này để hiểu nghiệp vụ. Nếu khác quyết định mới hoặc chưa thống nhất, ghi nhận và chưa triển khai phần đó.

## Task hiện tại đã rõ

A02 đã dùng mẫu xanh P2 10729 theo lựa chọn chủ dự án. Có login/validation/busy/error/retry/phiên mock, guard các route và logout xóa phiên/lịch sử. Demo local được ghi README admin; chưa auth/roles/API thật, phiên mất khi reload, không lưu mật khẩu. Ghi nhớ/Quên mật khẩu chưa tích hợp. Footer tên/email từ phiên, avatar/badge vẫn mẫu; không dùng phiên customer cho admin. Bước sau đề xuất A03.1 thẻ thống kê/biểu đồ mock, chưa danh sách ảnh Dashboard đang bất nhất.

A01 admin đã có shell/sidebar/header theo Dashboard 5862, điều hướng từng mục tới màn tạm rõ tên, viewport hẹp dùng Drawer. Chưa login/dashboard số liệu/API/phân quyền. Identity/badge/thông báo chỉ minh họa P2, nút tìm kiếm/chuông/giao diện/logout báo chưa khả dụng. 7 test admin, analyze và build web qua. Bước kế tiếp A02 cần chọn một trong hai biến thể login, không tự suy ra phiên admin từ customer.

Đã khảo sát hai trang P2 Admin và lập [ADMIN-BACKLOG.md](ADMIN-BACKLOG.md): 30 frame, chia A01–A15. Admin vẫn chỉ scaffold; đề xuất bắt đầu shell/header/sidebar theo Dashboard 5862. Không mở lại nghiệp vụ custom/thanh toán/chứng từ hoặc coi mock frontend là phân quyền. Biến thể login, menu khác nhau và asset Dashboard chưa khớp tên sản phẩm được ghi rõ để xử lý theo từng task.

Ba route tạm custom/chat/chính sách đã có tên và thông báo riêng về phần chưa khả dụng; không còn mô tả chung hoặc cam kết sẽ làm trong task kế tiếp. Đây vẫn là màn tạm, chưa triển khai nghiệp vụ. Route không tồn tại báo không tìm thấy, có back/về Home.

Home và chi tiết bài `autumn-colors` đã dùng chung metadata, tiêu đề Thu Đông 2026 theo nội dung Home hiện có do chủ dự án sửa. Đây là năm biên tập cố định, không phải ngày động; chưa có thân bài nên giữ thông báo nội dung đang cập nhật. Không đổi ngày/tiêu đề bài Blog khác.

`/digital-checkout` đã có DigitalCheckoutPreviewPage: hiển thị ảnh/tên/chuyên mục/format/giá Product đã chọn, lỗi dữ liệu cho chọn lại catalog số. Thông báo thanh toán chưa khả dụng, có quay lại. Chưa form nhận file/mã đơn/QR/chứng từ hoặc tạo đơn/thanh toán/mở khóa; không dùng PendingPage chung cho route này nữa. Các ghi chú route tạm trước đây được hiểu là giới hạn nghiệp vụ, không phải chưa hiển thị sản phẩm.

Mua ngay của video/e-book đã truyền đúng Product đang xem vào `/digital-checkout`, thống nhất với PDF. Route còn là màn tạm, chưa dùng payload để hiển thị một checkout hoàn chỉnh; không tạo đơn/thanh toán/tải hoặc cấp quyền. EPUB mẫu chưa published vẫn giữ nguyên trạng thái.

Điều chỉnh mới nhất của popup guest: nền trắng, ẩn hoàn toàn giỏ/sản phẩm phía sau khi popup mở; không chỉ blur giỏ. Đóng popup khôi phục giỏ và giữ nguyên dữ liệu.

Chủ dự án đã duyệt **popup giỏ guest sáng, gọn hơn** thay popup tối P2 1270 sau khi xem bản chạy. Nền cream, viền rose, icon túi/đóng nâu, CTA cam; bỏ ảnh lớn, giảm bóng và rút gọn nội dung. Giữ logic close/later/Back/login và dữ liệu như trước. Đây là điều chỉnh UI được duyệt, không sửa Figma hoặc thay quy tắc checkout/gộp giỏ.

Giỏ guest P2 `2026:1270` đã có popup trên nền giỏ thực làm mờ, chỉ hiện khi chưa đăng nhập mỗi lượt mở. Close/Để sau/Back đóng mà giữ dữ liệu, CTA mở login/register hiện có, member bỏ qua. Đây là UI nhắc đăng nhập, không tự chốt gộp giỏ hoặc checkout guest; luồng checkout cũ sau khi đóng popup chưa thay đổi. Không phát sinh tải API hoặc trạng thái loading/error giả cho popup tĩnh.

Quyết định mới: viết đánh giá từ **Đơn hàng của tôi** và **chi tiết đơn hàng**, chỉ với đơn **Đã giao**, yêu cầu đăng nhập và sản phẩm thuộc đơn đã mua. Không đặt nút viết đánh giá ở detail sản phẩm. Đã bổ sung nút Đánh giá trong chi tiết khi state delivered, giữ nút sẵn có trong danh sách; bỏ hoàn toàn nút Hủy đơn hàng và dialog hủy khỏi chi tiết ở mọi trạng thái. Hỗ trợ giữ đúng mã đơn. Hai nút mở form `/write-review` bằng order ID. Đã duyệt form dùng component P2 vì chưa có frame riêng: 1–5 sao bắt buộc, nhận xét tùy chọn, chưa ảnh; mỗi sản phẩm trong một đơn gửi một lần, chưa sửa. Lưu mock vào nguồn shared sau khi kiểm tra phiên/trạng thái/đúng sản phẩm trước và sau await, khóa gửi trùng, lỗi giữ draft/thử lại. Store là bộ đơn mẫu một khách hàng; ownership/uniqueness thực phải do backend xác minh. Không dùng trang bình luận chỉ đọc làm form đánh giá sau mua.

Bình luận P2 `2026:120` đã có route `/comments` với product ID, nguồn mock riêng và tải/rỗng/lỗi/retry. Merino bốn bình luận gốc/một phản hồi shop; sản phẩm khác rỗng. Nhãn thời gian/lượt hữu ích/tim là mẫu cố định từ P2; không biến thành thời gian hệ thống hoặc cập nhật thật. Composer/gửi/trả lời/hữu ích chỉ thông báo; không nhập nội dung, ảnh, thay dữ liệu hoặc phiên. Vị trí mở từ detail chưa rõ trong P2, đang chờ lựa chọn của chủ dự án; chưa tự thêm nút trên các màn hiện có.

Chi tiết mẫu móc PDF P2 `2026:3032` đã có PdfProductPage trong route `/product` khi category Mẫu móc/format PDF. Tên/ảnh/giá/format từ Product, metadata Dino từ nguồn riêng có loading/rỗng/lỗi/retry. Dino có một nhận xét P2 trong nguồn shared, preview/list cùng 5.0/1; chưa biết ngày/helpful nên để optional, không tự giả timestamp hay quyền đã mua. Mua ngay truyền đúng Product tới route digital checkout vẫn chưa triển khai; không tạo đơn/thanh toán/đổi giỏ hoặc tải/mở khóa tệp. Chia sẻ/mô tả bổ sung chỉ thông báo. Copy nhận link sau thanh toán là minh họa P2, chưa vận hành thật. Video/e-book và vật lý không dùng template Dino.

Drawer đã căn hai frame P2 `2026:338/413`, dùng chung Home/catalog: sáu mục chính, guest login/register/social minh họa; member hồ sơ hiện tại/logout mock. Đơn và thư viện vẫn qua Hồ sơ; không thêm mục custom/chat ngoài P2. Điều khoản dẫn route tạm có thông báo; các route/guard không đổi. Logout chỉ kết thúc phiên như Hồ sơ, không sửa giỏ/đơn. Phiên bản 1.0.0 theo app; avatar người mẫu chỉ có trong golden, runtime dùng ảnh/placeholder hồ sơ. Close/scrim/Back đóng menu; nội dung cuộn với chữ lớn, footer có SafeArea.

Đã có `/reviews` theo P2 `2026:1037`, nhận product ID từ detail, chỉ đọc/lọc/sắp mock. Nguồn model/fixture đã chuyển sang shared; LenlabStore.productReviews và reviewsFor là dữ liệu chung cho catalog/detail/danh sách. Merino thống nhất 4.5/4; sản phẩm không có dòng không hiện badge và có trạng thái 0 nhận xét. Không còn dùng fixture 4.8/120 hoặc Product.rating cho UI; trường rating legacy chỉ giữ tương thích snapshot. Có loading/rỗng/lỗi/retry/reset. Gửi nhận xét qua form đơn Đã giao vào nguồn mock chung; chưa gửi backend/ảnh/hữu ích hoặc cấp nhãn đã mua thật. P2 Hoàng Phúc có glyph 5 sao nhưng text 4 sao: giữ mẫu, ghi nhận cần duyệt. Bình luận đã có trang chỉ đọc riêng như ghi chú ở đầu mục này; điểm mở đang chờ xác nhận.

Đã hoàn tất lượt rà soát UI/điều hướng customer, xem [CUSTOMER-CHECKLIST.md](CUSTOMER-CHECKLIST.md). Footer runtime dùng năm hiện tại, riêng golden cố định năm 2026. Đã sửa icon tài khoản catalog theo signedIn và guard arguments `/product`: thiếu/sai kiểu hiển thị ProductUnavailablePage, không tự chọn sản phẩm khác; payload Product hợp lệ giữ nguyên. Không dùng checklist để tự mở lại các nghiệp vụ còn hoãn.

Giới thiệu P2 `2026:3774` đã có `/about` công khai, nối menu/footer; nguồn nội dung mock riêng với loading/rỗng/lỗi/thử lại. Hero, ba giá trị, tầm nhìn/sứ mệnh và các mốc 2021/2022/2024 theo P2; đây là nội dung minh họa cần duyệt trước phát hành, không tự xác minh hay mở rộng tuyên bố thương hiệu. CTA Khám phá sản phẩm mở danh sách sản phẩm hiện có, không đổi giỏ/đơn/voucher/phiên. Nút cố định dưới có SafeArea; nội dung cuộn không chồng CTA.

Chi tiết bài viết P2 `2026:3694` đã có `/article` nhận đúng ID từ Home/Blog, nguồn mock riêng và loading/lỗi/retry/không tìm thấy. Chỉ bài bảo quản len có thân bài P2; các bài khác hiện metadata riêng và nội dung đang cập nhật, không dùng chung thân bài sai chủ đề. Back giữ tìm kiếm Blog. Nút xem sản phẩm cuộn đến phần được đề cập. Sản phẩm minh họa chưa khớp ID catalog nên chưa thêm giỏ; video/chia sẻ chưa có tệp/URL nên chỉ thông báo. Không gửi bình luận hoặc đột biến giao dịch. Ghi chú này thay thế giới hạn trước rằng mọi nút Xem chi tiết Blog chỉ hiện dialog.

Danh sách Tin tức & Blog P2 `2026:3618` đã có `/blog` công khai, nối menu và footer. Ba bài fixture giữ thứ tự/ngày từ P2; chưa coi là nguồn tin hiện hành. Có tìm tên/chuyên mục tại chỗ và loading/rỗng/lỗi/thử lại. Xem chi tiết hiện thông báo task tiếp theo kèm đúng tên bài, chưa có nội dung bài đầy đủ, bình luận hoặc chia sẻ thật. Bài viết ở home có fixture khác nên chưa tự nối vào ba ID của Blog. Không thay giao dịch hoặc phiên tài khoản khi đọc/tìm bài.

Trung tâm trợ giúp/Hỏi đáp P2 `2026:2669` đã có UI công khai `/faq`, nối menu và Hồ sơ. `/support` dùng cùng trang với mã đơn được truyền vào, không gửi thông điệp. Có tìm kiếm câu hỏi, lọc nhóm, accordion, loading/rỗng/lỗi/thử lại. Nguồn mock tách riêng; chỉ câu về xù lông có đáp án P2, các đáp án thiếu hiện đang cập nhật. Không tự suy ra chính sách vận chuyển/đổi trả/thanh toán từ tiêu đề câu hỏi. Liên hệ chỉ thông báo chưa kết nối dịch vụ; copy 24/7 là minh họa, chưa phải cam kết vận hành. Không đổi dữ liệu đơn/giỏ/quyền hoặc khôi phục gửi minh chứng.

Sửa hồ sơ P2 `2026:3961` đã nối từ nút Sửa. Chỉ lưu mock tên, điện thoại, giới tính, ngày sinh; hai nút lưu chung xử lý, giữ form khi lỗi và tải lại trang Hồ sơ sau thành công. Email khóa theo P2. Đổi ảnh/mật khẩu chỉ là UI báo chưa hỗ trợ, không có ô nhập mật khẩu thực sự hoặc nhận file. Avatar optional trong model phục vụ cùng một ảnh/placeholder ở cả hai màn; không tự gán ảnh người mẫu P2 cho tài khoản runtime.

Giới tính Nam/Nữ/Khác theo enum male/female/other trong báo cáo; có thể chưa chọn. Điện thoại dùng validator hiện có, cho khoảng trắng trình bày rồi lưu 10 số bắt đầu 0. Ngày sinh optional, dùng dd/MM/yyyy để thống nhất model hiện tại; kiểm tra ngày lịch thực/ngày nhuận/không tương lai, không tự áp tuổi tối thiểu. Không đổi email đăng nhập, mật khẩu, ảnh, địa chỉ checkout, snapshot đơn hoặc quyền sản phẩm số. Đây chưa phải API xác minh thông tin hoặc cập nhật tài khoản thật. Thay thế giới hạn trước đây rằng Sửa hồ sơ chưa triển khai.

Thư viện Sản phẩm số của tôi P2 `2026:3352` đã có `/library`, nối từ hồ sơ và menu. MockLibrarySource đọc các dòng sản phẩm từ đơn số có `canDownload` và không hủy; không cấp quyền mới. Bộ hiện tại chỉ có course đã xác nhận, không tự gán Teddy/EPUB/Cardigan cho người dùng để giống Figma. Fixture bốn card chỉ dùng kiểm thử/render. Thư viện không gọi download hoặc mở URL/file, không đổi payment/đơn/quyền và không ghi downloaded/progress khi bấm. Backend tương lai phải xác định quyền sở hữu và cấp truy cập nội dung bảo vệ; logic mock không phải cơ chế bảo mật thực.

Đã có lọc loại, tìm tên, loading/rỗng/lỗi/thử lại và guard phiên mock. Thiếu ngày mua hoặc tiến độ thì thông báo thiếu, không lấy số liệu mẫu áp cho mọi đơn. Nút Tải về/Tải lại/Xem tiếp/Đọc ngay và overlay video chỉ báo chưa hỗ trợ nội dung thật. Menu tùy chọn chưa triển khai. Ghi chú này thay thế giới hạn cũ rằng Thư viện số chưa có UI.

Ví voucher P2 `2026:4081` đã có UI `/vouchers`, nối từ hồ sơ; nguồn VoucherSource riêng với loading/rỗng/lỗi/thử lại và guard phiên mock. Ngày, điều kiện mô tả và trạng thái là fixture P2, chưa phải kết quả xét điều kiện từ backend. Không tính hạn theo đồng hồ máy, không thay coupon LEN50 hiện có hoặc tổng tiền checkout.

Áp dụng/Dùng ngay báo chưa tích hợp; Hết hạn/Đã dùng không cho thao tác. Sao chép chỉ ghi clipboard nếu nguồn cung cấp mã thật; card 50K P2 chưa có mã nên báo thiếu dữ liệu, không tự đặt LEN50. Chưa có phát hành, nhận mã, xác minh điều kiện, hạn mức, tích lũy hoặc redeem. Ghi chú này thay thế giới hạn trước đây rằng ví voucher chưa có UI.

Form thêm/sửa Sổ địa chỉ P2 `2026:3872` đã nối từ danh sách. Hai nút Lưu dùng chung xử lý: validation bắt buộc/tên, điện thoại theo validator hiện có (10 số bắt đầu 0), địa giới phụ thuộc, lưu mock/thử lại và trở về danh sách. Nguồn lưu riêng không sửa draft checkout hay snapshot đơn. Chưa đổi mặc định: giữ cờ của địa chỉ cũ, địa chỉ mới false; công tắc hiện thông báo phần chưa triển khai. Xóa vẫn chưa triển khai. Ghi chú này thay thế giới hạn Thêm/Sửa chưa có ở phần bàn giao danh sách trước.

Sổ địa chỉ P2 `2026:4234` đã có phần danh sách `/addresses`, nối từ Hồ sơ. Nguồn mock đọc cùng `store.addresses` như checkout; không đọc/ghi `deliveryAddress`, không yêu cầu giỏ có hàng. Có loading/rỗng/lỗi/thử lại và guard phiên mock. Nhãn mặc định và dấu tròn chỉ thể hiện dữ liệu hiện có, chưa cho chọn lại. Thêm/Sửa/Xóa đang báo rõ sẽ triển khai ở bước tiếp theo. Chưa làm form `2026:3872`, lưu, xóa hoặc đổi mặc định trong lượt này. Thay thế ghi chú cũ rằng toàn bộ Sổ địa chỉ chưa có UI.

Danh sách đơn hàng: đọc cùng bộ đơn với chi tiết, lọc trạng thái hiện có, mở đúng mã đơn; loading/empty/error/retry. Dữ liệu mock tách khỏi UI, không tạo đơn hoặc đổi trạng thái khi xem danh sách. Chưa có backend xác thực/phân quyền nên dữ liệu hiện tại chỉ là bộ mẫu; API sau này phải giới hạn đơn theo người dùng đăng nhập.

Phần dữ liệu đã có `OrderListSource` / `MockOrderListSource` trong package dùng chung. Adapter giữ thứ tự bộ dữ liệu, không tự bổ sung thời gian hoặc quy tắc sắp xếp. Kết quả là danh sách không cho thêm/xóa, nhưng đối tượng Order vẫn là model mutable dùng chung với chi tiết. Đã nối `/orders` từ menu với UI danh sách P2 `2026:1852`, trạng thái tải/rỗng/lỗi/thử lại và điều hướng đúng mã đơn. Có kéo tải lại và tải lại sau khi quay về từ chi tiết.

Tab theo P2 gồm Tất cả/Chờ xác nhận/Đang giao/Đã giao/Đã hủy. OrderState.processing vẫn xuất hiện trong Tất cả với nhãn Đang xử lý; không tự gộp vào Chờ xác nhận hoặc Đang giao. Chưa bổ sung tab khác thiết kế. Nút Mua lại vẫn báo chưa hỗ trợ; Đánh giá đã mở form sau mua cho phiên đăng nhập/đơn Đã giao theo quy tắc hiện hành ở đầu mục. Có thể bấm card đã giao để xem chi tiết.

Ngày đặt thiếu thì báo chưa có ngày đặt; không gán ngày mẫu Figma cho mọi đơn. Ảnh/tên/số lượng/tổng lấy từ Order hiện có nên một số card khác nội dung mẫu Figma. Chưa có metadata nhãn Sản phẩm bền vững/Bao bì không nhựa nên không tự gán nhãn cho sản phẩm trong mock. Các khác biệt này được ghi nhận để bổ sung dữ liệu chuẩn sau.

## Chưa triển khai khi còn thiếu quyết định

Hồ sơ P2 `2026:244` đã có UI và nguồn mock riêng; `/profile` cần signedIn mock. Đã nối sửa hồ sơ, sổ địa chỉ, ví voucher, thư viện số và FAQ như mô tả hiện hành ở trên. Cài đặt tài khoản, đổi ảnh và đổi mật khẩu vẫn chưa triển khai. Phiên bản dùng số bản app hiện tại, nhãn thành viên chỉ là dữ liệu mẫu P2.

- Custom: thời điểm chuyển yêu cầu/báo giá thành đơn, thời điểm tạo sản phẩm riêng và bắt đầu sản xuất.
- Cổng thanh toán: nhà cung cấp, hợp đồng API, thời điểm tạo đơn, giữ/giải phóng tồn kho và xử lý giỏ. Không khôi phục UI gửi ảnh; xem [PAYMENTS.md](PAYMENTS.md).
- Các quy tắc thực tế còn thiếu như phí giao hàng, điều kiện voucher, công thức ước tính len và quyền truy cập nội dung số. Fixture không phải chính sách vận hành.

Hủy đơn chờ xác nhận có lý do và mua lại có kiểm tra tồn kho đã được mô tả trong báo cáo (trang in 61–63, sơ đồ trang 95). Chưa làm trong task danh sách: cần xử lý nhất quán với tồn kho mock hiện chưa trừ khi đặt COD; không cộng hoàn một lượng chưa từng bị trừ. Không tự thêm hoàn tiền vào thao tác hủy.

## Admin A03.1 - đã triển khai

Thẻ thống kê và biểu đồ Dashboard P2 5862 dùng source mock riêng; loading/empty/error/retry, thích ứng web hẹp/chữ lớn. Không nối store customer. Tỷ lệ được tính nhất quán từ số đơn; dữ liệu và nhãn tăng trưởng chỉ minh họa. Chưa chọn kỳ thực, tạo đơn hoặc backend. Sản phẩm dashboard chờ chốt ảnh không khớp tên. Tiếp theo đề xuất A04.1 danh sách sản phẩm admin chỉ đọc, chưa thêm/sửa/xóa. Xem ADMIN-BACKLOG.md.

## Admin A04.1 - đã triển khai

Danh sách sản phẩm P2 6669 chỉ đọc: tìm tên/SKU, lọc danh mục và hiển thị/ẩn, phân trang 5 dòng, trạng thái tải/rỗng/lỗi/retry. Source mock riêng 12 dòng; chưa thêm/sửa/xóa/đổi hiển thị hoặc đồng bộ store customer. Màu tồn chỉ là fixture, chưa ngưỡng vận hành. Sidebar giữ A01, header sản phẩm theo frame riêng. Task rõ tiếp theo đề xuất A06.1 danh sách đơn hàng admin chỉ đọc, chưa chuyển trạng thái/hủy/hoàn tiền. Chi tiết ADMIN-BACKLOG.md.

## Admin A06.1 - đã triển khai

Danh sách đơn hàng P2 7027 chỉ đọc: tìm mã/tên, lọc trạng thái và phương thức COD/CK, 5 dòng/trang, tải/rỗng/lỗi/retry. Source riêng 12 fixture, chưa đồng bộ customer; ngày thiếu có fallback. Không khôi phục minh chứng, tạo đơn, chuyển trạng thái/hủy/hoàn tiền. Chi tiết mới thông báo tạm đúng ID. Task tiếp theo A06.2 chi tiết đơn admin chỉ đọc theo 7320, cùng nguồn/đúng ID và guard thiếu dữ liệu. Các quy tắc chưa chốt tiếp tục hoãn. Xem ADMIN-BACKLOG.md.

## Admin A06.2 - đã triển khai

Chi tiết đơn theo P2 7320, cùng nguồn list, URL có ID và guard đăng nhập/thiếu/sai/nhầm dữ liệu. Back từ list giữ tìm/lọc/trang. Chỉ ORD-202502 có supplement P2; các đơn khác hiển thị summary và báo thiếu trường. Giữ ngày/trạng thái list trước bất nhất mẫu. Chưa xác nhận thanh toán, timeline, minh chứng hoặc Duyệt/Hủy/Sửa. Asset ảnh P2 không khớp tên đã ghi nhận, không tự thay. Tiếp theo đề xuất A07.1 danh sách khách hàng admin chỉ đọc, chưa khóa/mở/sửa vai trò/thêm người dùng. Xem ADMIN-BACKLOG.md.

## Admin A14.1 - danh sách sản phẩm số chỉ đọc đã triển khai

P2 2037:2, /digital-products từ menu Sản phẩm → Sản phẩm số. Ba fixture đúng frame và số lượng từ dữ liệu, loading/empty/error/retry, thiếu giá/metadata/trạng thái có fallback. Không có tìm/lọc/phân trang trong frame nên không tự thêm control. Thêm bị khóa; Chỉnh sửa mở UI A14.2. Chưa CRUD/file thật/upload/URL tải/quyền/publish; trạng thái mock không cấp quyền customer.

## Admin A14.2 - UI chỉnh sửa sản phẩm số, chưa lưu

P2 2037:413, route /digital-products/edit?id=… cùng source danh sách. Nhập tạm tên/mô tả/giá bán/giá gốc; định dạng/hiển thị/tệp/quyền chỉ đọc. Hủy quay về danh sách, bỏ nội dung sửa. Supplement chỉ có Dino; phần chưa biết của video/e-book báo thiếu. Loading/lỗi/retry/thiếu-sai ID và guard phiên hoạt động. Lưu/Thay tệp khóa; chưa validation lưu, persistence, upload, xuất bản/cấp quyền. Cần chốt định dạng giá/giới hạn trường/quan hệ giá và hợp đồng tệp trước thao tác ghi. Đề xuất A15.1 preview danh sách hội thoại chỉ đọc sau khi đọc context 2038:9, chưa gửi tin/AI. Nghiệp vụ chưa chốt tiếp tục hoãn.

## Admin A15.1 - hội thoại khách hàng chỉ đọc

P2 2038:9, /conversations từ sidebar. Ba preview, tìm tên/email/mã yêu cầu và chọn xem đúng hội thoại. Hai tin nhắn/trạng thái hỗ trợ/chưa đọc của Nguyễn Văn A là fixture P2; hai khách khác báo thiếu lịch sử, không gán email hoặc liên kết Custom/người dùng bằng tên. Chọn không đánh dấu đã đọc. Source mock riêng, loading/empty/error/retry, đổi source không lộ dữ liệu cũ. Khung phản hồi/Gửi/Đánh dấu đã xử lý khóa; chưa gửi tin, persistence, AI, thời gian thực hoặc áp báo giá/phí ship từ copy mẫu. Task đề xuất A15.2 UI kịch bản chatbot chỉ đọc sau khi đọc context 2038:395; quy tắc chưa rõ tiếp tục hoãn.

## Admin A15.2 - kịch bản chatbot chỉ đọc

P2 2038:395, /conversations/chatbot từ mục con Hội thoại. Sáu trường mẫu và nút Lưu khóa; Chủ đề Ước tính số lượng len/Đang bật không thực thi công thức hoặc kích hoạt chatbot. Source riêng/null record/thiếu trường/null trạng thái khác false; tải/rỗng/lỗi/retry và bỏ kết quả cũ khi đổi source. Chưa input/toggle/lưu/publish/persistence, thu thập dữ liệu, API/AI hoặc chuyển yêu cầu cho nhân viên. Đề xuất A12.1 chỉ đọc dữ liệu mẫu giỏ bỏ quên theo 7960 sau khi đọc frame, chưa xác định bỏ quên tự động/gửi nhắc/đồng ý tiếp thị. Nghiệp vụ chưa rõ tiếp tục hoãn.

## Admin A12.1 - giỏ hàng bị bỏ quên chỉ đọc

P2 7960, /marketing/abandoned-carts: bốn dòng P2, tìm khách/liên hệ, phân trang 4 dòng/tổng từ nguồn và tải/rỗng/không khớp/lỗi-retry. Nguồn mock riêng, không lấy store customer hoặc ghép bằng tên. Nhãn2 giờ/5 giờ/1 ngày/2 ngày là tĩnh, chưa ngưỡng bỏ quên/lastActivity/retention/đồng ý tiếp thị. Sắp xếp/thời gian khóa vì P2 thiếu quy tắc và thứ tự mẫu không khớp nhãn giảm dần; không tự đặt khoảng ngày. Checkbox/Gửi nhắc/Voucher khóa, chưa chi tiết/email/tin nhắn/cấp ưu đãi/API ghi. Đề xuất A09.1 UI mã phần trăm chỉ đọc sau khi đọc 5399, chưa tạo/lưu/áp mã; nghiệp vụ chưa rõ tiếp tục hoãn.

## Admin UI A09.1 - mã phần trăm chỉ đọc

P2 5399, /marketing/coupons/percentage: thông tin/điều kiện/thời gian, mẫu 20%/tối đa 50.000đ/tối thiểu 0/ngày 12/05/2024. Đây là mẫu màn tạo, chưa có mã được lưu; LENLABSALE50/100/dd/mm/yyyy là placeholder, không coi null giới hạn/hết hạn là vô hạn. Trường/Lưu nháp/Tạo mã khóa; Hủy/breadcrumb chỉ điều hướng về Marketing. Loading/rỗng/lỗi/retry, dữ liệu thiếu và snapshot cũ được xử lý. Chưa validation/tạo/lưu/áp mã, cấp voucher, đối tượng/ưu tiên ưu đãi/múi giờ/persistence/API ghi. A09.2 đã có UI tiền cố định 6470 chỉ đọc; nghiệp vụ chưa chốt tiếp tục hoãn.

## Admin A11.1 - cấu hình chung chỉ đọc đã triển khai

P2 6148/6349, /settings có nhóm giao diện/thông báo và footer cố định. Mock riêng Lenlab Official/#E89F70/logo minh họa/hai thông báo tắt; tải/rỗng/lỗi/retry, trường thiếu và mã màu sai có trạng thái rõ. Chưa sửa/lưu/upload/đổi theme/favicon/name app, gửi email hoặc xin quyền thông báo; null không coi là tắt. Chưa quy tắc validation/quyền cấu hình/API ghi. Đề xuất A14.1 UI quản lý sản phẩm số admin chỉ đọc theo 2037:2 sau khi đọc context/screenshot; chưa nhận file thật/cấp quyền/phát hành. Các luồng chưa chốt tiếp tục hoãn.

## Admin A10.3 - UI nhập bài tạm đã triển khai

P2 9969, /marketing/articles/new mở từ Thêm mới; tiêu đề/nội dung văn bản/danh mục nhập trong màn, tác giả theo phiên. Back giữ trạng thái danh sách, direct URL/guard/logout hoạt động. Chưa lưu nháp hoặc tạo bài; rời màn bỏ nội dung đang nhập và có ghi rõ. Đăng/Lưu/upload/rich text bị khóa. Tin tức trong form chưa ánh xạ vào danh mục lưu trữ; còn thiếu quy tắc bắt buộc/giới hạn/định dạng/quyền tác giả/file trước khi lưu mock hay tích hợp API. Không tự đặt các quy tắc này. Đề xuất tiếp A11.1 UI cấu hình chung P2 6148 chỉ đọc, sau khi đối chiếu frame; chưa thay đổi dịch vụ thật.

## Admin A10.2 - danh sách bài viết chỉ đọc đã triển khai

Chủ dự án chọn chuyển sang bài viết; A10.1 tạm hoãn vì frame 9439 là cấu hình banner, không có danh sách banner. P2 9663 ở /marketing có tìm tiêu đề/danh mục/Public-Draft/phân trang/trạng thái tải-rỗng-lỗi-retry. 4 fixture P2 + 4 minh họa, chưa đồng bộ nội dung customer; thiếu tác giả/ngày báo -. Tab Banner/Thêm/Sửa/Xóa bị khóa; chưa editor/upload/publish và không áp giảm giá theo bài mẫu. Đề xuất A10.3 UI soạn bài theo 9969 sau khi đối chiếu thiết kế/quy tắc trường; chưa xuất bản thật hoặc tự đặt SEO/lịch đăng.

## Admin A08.2 - đã triển khai UI bảng thống kê chỉ đọc

P2 8805 là bảng xếp hạng sản phẩm với sao/lượt, không có biểu đồ. /reviews/statistics có tìm tên/SKU, danh mục, phân trang, tải/rỗng/lỗi/retry. Năm snapshot P2 chưa tổng hợp từ đánh giá A08.1; chưa có liên kết ID/SKU hoặc thuật toán xếp hạng/hòa hạng/kỳ. Không tự tính hạng, giữ thứ hạng mẫu khi lọc. Tồn/danh mục dùng cùng fixture catalog theo SKU, khác một số giá trị P2; đã ghi ADMIN-BACKLOG.md. Chưa lọc kỳ/xuất báo cáo/moderation/backend. Đề xuất A10.1 danh sách banner P2 9439 chỉ đọc sau khi đọc thiết kế, chưa thêm/sửa/xóa/upload/hẹn lịch/phát hành.

## Admin A08.1 - đã triển khai danh sách đánh giá chỉ đọc

P2 5597, tìm tên/sản phẩm, lọc số sao và nhóm, phân trang/trạng thái tải/rỗng/lỗi/retry. Source mock riêng 8 dòng, giữ 3 dòng P2; không gán liên kết người dùng/đơn hoặc đồng bộ customer. Số chờ duyệt tính từ nguồn, trạng thái chỉ là fixture. Duyệt/Ẩn bị khóa; chưa xóa/phản hồi/upload/moderation. Asset không khớp tên giữ nguyên/chờ chốt. Đề xuất A08.2 UI thống kê theo 8805 sau khi đọc thiết kế; chỉ tính chỉ số đủ rõ từ mock, chưa tự đặt kỳ hoặc quy tắc kiểm duyệt. Xem ADMIN-BACKLOG.md.

## Admin A07.2 - đã triển khai phần chi tiết chỉ đọc

Chi tiết P2 9129 dùng cùng source với danh sách, đúng ID/tên/email/SĐT/vai trò/trạng thái. Nút mắt hoặc URL mở detail; guard phiên/thiếu/sai/nhầm ID, loading/error/retry và Back giữ tìm/lọc/trang. Ngày tham gia/chi tiêu/hạng/địa chỉ/lịch sử chưa có dữ liệu liên kết; không lấy thông tin người mẫu gán cho mọi ID hoặc ghép đơn bằng tên/SĐT. Tìm/lọc lịch sử và sửa/khóa/mở/đổi quyền/Lưu chưa khả dụng. Cần quan hệ người dùng–đơn hàng trước khi làm tiếp lịch sử. Task kế tiếp đề xuất A08.1 danh sách đánh giá chỉ đọc: tìm/lọc/phân trang/trạng thái; chưa moderation/ẩn/xóa/phản hồi. Xem ADMIN-BACKLOG.md.

## Admin A07.1 - đã triển khai

Danh sách người dùng P2 8502 chỉ đọc: tên/email/SĐT, lọc vai trò và trạng thái, 4 dòng/trang, tải/rỗng/lỗi/retry. Source admin riêng 10 fixture; gồm khách hàng/nhân viên như frame, không cấp quyền thật. Số đơn thiếu hiển thị -. Chưa thêm/khóa/mở/sửa vai trò/chi tiết hoặc thao tác ghi. Tiếp theo đề xuất A07.2 chi tiết người dùng theo 9129, cùng nguồn và đúng ID, dữ liệu thiếu có guard; chưa sửa/liên hệ/đổi quyền. Xem ADMIN-BACKLOG.md.

## Admin UI A09.2 - tiền cố định chỉ đọc

P2 6470, /marketing/coupons/fixed: mẫu giảm 50.000đ, đơn tối thiểu 0, nhãn ngày 12/05/2024. Code/quota/expiry chưa điền; không coi ví dụ là mã đã tạo hoặc null là vô hạn. Hai loại chuyển bằng điều hướng xem mẫu, nguồn mock riêng, không tính/áp ưu đãi, liên kết ví voucher customer hoặc ghi dữ liệu. Lưu nháp/Tạo mã khóa, không có thành công giả. Chưa nhập/validation, cấp voucher, đối tượng/hạn mức/ưu tiên ưu đãi/timezone/API.
