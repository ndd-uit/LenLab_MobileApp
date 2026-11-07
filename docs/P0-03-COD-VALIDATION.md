# P0-03 - COD checkout validation

Chỉ triển khai COD mock. Không làm P0-04, Backend/API/database, CRUD Admin, VNPay hoặc đối soát chuyển khoản; không sửa Figma hoặc chính sách tồn kho thật.

## Nguyên nhân

- CartLine giữ tham chiếu Product mutable từ catalog: sửa giá catalog có thể tự làm giá/tổng giỏ đổi, không có bước xác nhận rõ ràng.
- Store trước đây chỉ kiểm tra địa chỉ, dòng đã chọn, subtotal và discount. Chưa kiểm tra ID chuẩn, published, quantity, stock hay phí ship.
- MockCodOrderSource có độ trễ trước khi trả Order nhưng chưa kiểm tra lại catalog sau độ trễ. Dữ liệu có thể đổi trong lúc đang gửi.

## Thay đổi

1. `Product.snapshot` và CartLine chụp dữ liệu sản phẩm khi thêm giỏ. ID vẫn là ID chuẩn P0-02; không yêu cầu cùng object mutable với catalog. Tên/giá/ảnh/tồn hiển thị trong giỏ không tự đổi do catalog bị sửa.
2. Submit chụp các dòng được chọn, địa chỉ, ghi chú, coupon và số tiền đang xác nhận; khóa thao tác hiện có trong cả thời gian đọc catalog lẫn gửi COD. Hai lời gọi đồng thời dùng cùng Future tạo đơn.
3. Store đọc `repository.products()` trước khi gọi order source. Mock source kiểm tra thêm lần nữa sau độ trễ checkout và sau khi đọc lại catalog, ngay trước khi tạo Order, không có await giữa kiểm tra cuối và tạo Order.
4. Validator kiểm tra: ID không rỗng/còn tồn tại/duy nhất; key dòng giỏ không trùng; sản phẩm published; giá dương; số lượng dương; còn hàng; tổng số lượng các biến thể cùng product ID không vượt stock cấp sản phẩm hiện có.
5. Khi giá hoặc stock khác snapshot trong giỏ, từ chối submit và yêu cầu review, kể cả khi stock mới vẫn đáp ứng số lượng. Không tự đổi số lượng hoặc bỏ dòng hàng.
6. Kiểm tra số tiền theo đúng fixture đang có: subtotal từ dòng chọn, LEN50 theo điều kiện cũ, shipping 30.000đ, total bằng subtotal − discount + shipping. Không thay công thức voucher/ship. Phí 15.000đ tự truyền vào trước đây nay bị từ chối.
7. Chỉ cập nhật catalog snapshot trong giỏ sau khi khách bấm **Cập nhật thông tin và xem lại tổng tiền**. Đọc/kiểm tra toàn bộ dòng chọn thành công mới thay chúng; giữ nguyên key, quantity, địa chỉ, ghi chú, coupon và các dòng không chọn. Lỗi refresh không áp dụng một phần.
8. Điều hướng về Tổng quan đơn hàng hiện có; khách xem lại số tiền, chọn phương thức và bấm đặt COD lần nữa. Nút đặt COD bị khóa khi còn yêu cầu review. Lỗi khác cho phép thử lại hoặc mở giỏ để sửa.
9. Thành công chỉ xóa các key đã mua, giữ dòng không chọn; tạo snapshot tên, giá, số lượng từ dữ liệu đã xác minh. Reset coupon/note/payment draft theo hành vi thành công cũ. Không reserve/deduct/refund stock.

`MockLenlabRepository.catalog` vẫn là nguồn chuẩn P0-02. Không sửa seed, ID, tên, ảnh hoặc giá trong `mock_product_catalog.dart`. Mua lại vẫn tra ID chuẩn và mở Detail với giá hiện tại, không tự thêm giỏ.

## Giữ dữ liệu khi lỗi

Validation thất bại, đọc catalog lỗi hoặc submit lỗi: không thêm Order, không xóa CartLine, không đổi quantity, không bỏ lựa chọn, không reset coupon/note/address. Draft Order chỉ là bản chụp tạm chưa được thêm vào store. `whenComplete` giải phóng khóa để có thể retry. Refresh được bảo vệ khỏi áp dụng kết quả lên giỏ đã đổi trong lúc chờ.

UX dùng component thông báo inline và TextButton hiện có, thêm hành động xem lại giỏ/cập nhật rồi review trong trạng thái lỗi. Màu/bố cục màn bình thường giữ nguyên; **không cập nhật golden**.

## Files

| File | Nội dung |
| --- | --- |
| `packages/lenlab_shared/lib/src/domain/models.dart` | Snapshot Product/CartLine |
| `packages/lenlab_shared/lib/src/data/cod_checkout_validation.dart` (mới) | Lỗi có reason và validator dòng/tổng tiền COD |
| `packages/lenlab_shared/lib/src/data/cod_order_data.dart` | Snapshot draft/coupon và kiểm tra trước mock tạo Order |
| `packages/lenlab_shared/lib/src/state/lenlab_store.dart` | Validation submit, khóa, explicit refresh nguyên khối |
| `packages/lenlab_shared/lib/lenlab_shared.dart` | Export validator/error |
| `apps/customer/lib/features/checkout/presentation/payment_method_page.dart` | Thông báo và bước cập nhật/review/xác nhận lại |
| `packages/lenlab_shared/test/cod_validation_test.dart` (mới) | 26 tests validation/race/refresh/snapshot |
| `apps/customer/test/cod_validation_test.dart` (mới) | 7 widget tests lỗi, giữ draft và review |
| `packages/lenlab_shared/test/cod_order_test.dart` | Test hợp lệ dùng đúng phí mock 30.000; vẫn kiểm tra double submit/snapshot/retry |
| `apps/customer/test/product_identity_test.dart` | Giữ kiểm tra P0-02 theo ID/giá, thay assertion cùng object bằng snapshot độc lập |
| Tài liệu này | Báo cáo bàn giao |

## Kiểm thử

| Yêu cầu | Bằng chứng |
| --- | --- |
| Đơn hợp lệ | COD tests và bốn flow Home → COD → Mua lại của P0-02 |
| Xóa/ẩn/hết hàng/vượt tồn | Test validator và thông báo widget riêng |
| Số lượng 0/âm/trùng key | Unit tests, không gọi order source |
| Giá sau khi thêm giỏ đổi | Giá giỏ giữ cũ; submit bị chặn; explicit refresh, review rồi xác nhận mới tạo đơn |
| Không có dòng chọn | Unit test không tạo đơn, giữ giỏ |
| Double submit | Cùng Future, chỉ một order; có test khóa lựa chọn trong lúc gửi |
| Lỗi giữ giỏ | Catalog error, checkout error, validation, refresh lỗi nguyên khối |
| Snapshot | Sửa catalog/tên/giá/số lượng tham chiếu cũ không sửa đơn đã tạo |
| Chỉ mua dòng chọn | Dòng không chọn bị xóa khỏi catalog vẫn được giữ trong giỏ và không chặn dòng chọn hợp lệ |
| Tồn cấp sản phẩm | Tổng quantity nhiều variant cùng ID được kiểm tra, không giả định đã có SKU stock |
| Catalog đổi khi đang gửi | Đổi giá/stock/xóa/ẩn trong độ trễ bị phát hiện ở kiểm tra cuối |
| Tổng tiền stale | Subtotal/discount sai, phí âm hoặc phí cũ 15.000 đều bị từ chối |
| Mua lại | Toàn bộ product_identity_test và buy_again_test hiện có vẫn qua |

Kết quả: **Customer 310, shared 58, Admin 181 tests passed - tổng 549**. Thêm 33 test mới (26 unit, 7 widget). Analyzer cả ba project không báo lỗi. Các golden hiện có đều đạt, không chỉnh ảnh. Customer app đã hot restart thành công để khởi tạo giỏ với snapshot mới. Chưa kiểm thử Android/iOS thật trong lượt này.

Một test hợp lệ cũ dùng shipping 15.000 không khớp fixture runtime 30.000: đã chỉnh dữ liệu hợp lệ về 30.000 và thêm test riêng xác nhận phí cũ bị từ chối, không bỏ coverage lỗi.

## Backend cần xác minh lại

- Danh tính/quyền sở hữu giỏ và đơn, địa chỉ, khả năng dùng COD, trạng thái sản phẩm và variant/SKU.
- Giá, voucher, shipping, rounding/tax và quote version/expiry từ nguồn server, không tin số tiền Flutter.
- Stock, giữ/trừ/hoàn kho bằng transaction và quy tắc nghiệp vụ được duyệt; không dựa vào hai lần kiểm tra mock để ngăn cạnh tranh giữa nhiều khách.
- Idempotency bền vững qua retry, timeout, restart hoặc nhiều thiết bị; khóa Future ở FE chỉ chống gửi trùng trong phiên.
- Snapshot order line lưu bền vững và transition/trạng thái giao hàng từ Backend. Bước Đã giao để kiểm thử Mua lại chỉ là fixture test.

## Giới hạn còn lại

Model hiện tại chỉ có stock cấp Product và variant dạng chuỗi; chưa thể xác minh SKU/biến thể đã ngừng bán. Kiểm tra quantity dùng giới hạn stock hiện có, không tự thêm giới hạn mua mới. Product/CartLine là DTO mutable nhưng snapshot đã tách khỏi catalog; production vẫn cần snapshot lưu bền vững ở server. Không thay guest/auth policy (P0-04), voucher nghiệp vụ, VNPay hay chuyển khoản.

Backup trước sửa: `.design/p0-03/before.zip`.
