# P0-02 - Product identity consistency

Chỉ triển khai P0-02. Quyết định dữ liệu được chủ dự án chốt: giữ P2, bổ sung sản phẩm còn thiếu vào catalog chuẩn; không tự gộp sản phẩm qua tên, ảnh hoặc vị trí.

## Nguyên nhân và nguồn chuẩn

Home tạo bốn Product ngoài repository, Related tạo ba Product khi bấm card. Cart/COD giữ các ID đó, nhưng Mua lại chỉ tìm ID trong catalog chín sản phẩm nên không tìm thấy. Tên gần giống không chứng minh hai record là một sản phẩm: giá/ảnh của các frame P2 khác nhau.

Nguồn chuẩn duy nhất cho sản phẩm có thể mua trong Customer mock là `MockLenlabRepository.catalog`, khởi tạo qua `createMockProductCatalog()` trong `packages/lenlab_shared/lib/src/data/mock_product_catalog.dart`. Giữ nguyên chín sản phẩm cũ và bổ sung bảy record P2, tổng cộng 16. Factory tạo object riêng cho từng repository/session, không dùng singleton Product mutable.

## Mapping được thực hiện

Giữ nguyên ID đã được sử dụng; đưa chúng vào catalog có thể tìm kiếm/mua/Mua lại. ID Related là literal ổn định, không còn sinh từ tên ảnh lúc bấm.

| Nơi xuất hiện | ID chuẩn | Tên P2 | Giá | Ảnh |
| --- | --- | --- | ---: | --- |
| Home | `featured-handknit` | Áo Len Cổ Lọ Handknit | 850.000 | `472b3.png` |
| Home | `featured-beanie` | Mũ Len Beanie Basic | 320.000 | `70aca.png` |
| Home | `featured-socks` | Tất Len Cổ Cao | 150.000 | `57e60.png` |
| Home | `featured-crochet-bag` | Túi Tote Crochet Hoa | 480.000 | `8c711.png` |
| Related | `related-356e2.png` | Áo Len Cổ Lọ | 850.000 | `356e2.png` |
| Related | `related-dc895.png` | Mũ Len Beanie | 320.000 | `dc895.png` |
| Related | `related-eb513.png` | Găng Tay Len | 290.000 | `eb513.png` |

Không đổi `sweater` giá 1.200.000, `beanie` giá 120.000, `gloves` giá 350.000 hoặc các record cũ khác. Các record P2 khác nhau vẫn có ID riêng trong cùng catalog; không ép giá/ảnh của frame này lên frame khác. Không tự tạo SKU cho bảy record chưa có thông tin SKU.

## Hành vi

- Home/Related chỉ giữ ID và metadata trình bày (badge), lấy Product từ repository đang hoạt động. Không tạo Product bên trong UI.
- Route `/product` tra lại ID trong repository thay vì tin tên/giá/ảnh từ payload. Payload giả/stale không trở thành dữ liệu mua hàng.
- Chỉ resolve đúng một record, đang published và có stock; thiếu/trùng/ẩn/hết hàng dùng `ProductUnavailablePage` hiện có. Không chọn record khác theo tên/index.
- Catalog có loading/error/retry khi dùng cho Home/Related/detail. Home bị giữ offstage dưới route khác chưa khởi động request thừa.
- Cart tiếp tục nhận Product hiện tại; COD tiếp tục tạo snapshot cùng ID. Mua lại vẫn tra catalog rồi mở detail, không tự thêm giỏ hoặc sao chép giá/variant cũ.
- Không thay submit COD, inventory lifecycle, voucher, Admin CRUD, Backend/API hoặc state management. Chưa triển khai P0-03.

## File thay đổi

- `packages/lenlab_shared/lib/src/data/mock_product_catalog.dart` - mới, toàn bộ seed Product vật lý.
- `packages/lenlab_shared/lib/src/data/mock_lenlab_repository.dart` - dùng factory catalog.
- `apps/customer/lib/features/home/data/home_content.dart` - metadata theo ID.
- `apps/customer/lib/features/home/presentation/home_page.dart` - lấy sản phẩm từ repository.
- `apps/customer/lib/features/home/presentation/widgets/home_featured_card.dart` - nhận Product đã resolve.
- `apps/customer/lib/features/products/presentation/widgets/detail_related.dart` - các ID tường minh, bỏ Product dựng tại chỗ.
- `apps/customer/lib/shared/widgets/catalog_products.dart` - mới, đọc repository/resolve ID/loading/retry dùng chung.
- `apps/customer/lib/features/products/presentation/product_detail_route.dart` - mới, kiểm tra identity trước detail.
- `apps/customer/lib/app/customer_app.dart` - nối route adapter, không thay framework.
- `apps/customer/test/product_identity_test.dart` - mới, kiểm chứng identity và luồng mua.
- `apps/customer/test/catalog_test.dart` - số dòng trang 2 theo catalog 16 record.
- `apps/customer/test/goldens/products.png` - số lượng 9 → 16 và phân trang 2 → 3; không đổi card/layout.
- Tài liệu bàn giao này.

## Kiểm chứng

14 test identity mới: mọi ID Home/Related tồn tại duy nhất trong catalog; object/giá từ cùng repository; các session độc lập; bốn luồng Home → Detail → Cart → Checkout → COD → Mua lại → Detail; ba luồng Related → Detail → Cart; mất/ẩn/hết hàng/trùng ID; payload giả; lỗi tải và retry. Bước chuyển đơn sang Đã giao chỉ là thiết lập fixture trong test để mở Mua lại, không thêm UI đổi trạng thái.

Kiểm tra snapshot: giá đơn đã mua không đổi khi giá catalog thay đổi; Mua lại lấy giá mới và không tự thêm giỏ. Không gộp record chỉ vì trùng tên.

Chỉ một golden thay đổi. Kiểm tra pixel xác nhận khác tại hàng 156–172 (số sản phẩm) và 1238–1282 (phân trang). Golden Home/detail/Related và các màn khác giữ nguyên. Backup trước sửa tại `.design/p0-02/before.zip`; bằng chứng pixel tại `.design/p0-02/golden-diff.json`.

Kết quả cuối qua Dart MCP: **Customer 303, shared 32, Admin 181 tests passed, tổng cộng 516**. Analyzer cả ba project không báo lỗi. Customer app đã hot reload và hot restart thành công qua DTD để nạp lại catalog mới. Các log lỗi picker trong test là tình huống lỗi chủ động; cảnh báo SVG filter đã có trước task. Không chạy giao dịch hoặc tích hợp API thật.

## Giới hạn còn lại

- Đây là catalog mock, chưa phải catalog Backend có product/variant/SKU chính thức. Cần mapping ID khi tích hợp API; không suy luận mapping từ tên/ảnh.
- Các fixture đọc của Admin vẫn độc lập; task này không triển khai CRUD hoặc đồng bộ hai tiến trình.
- Kiểm tra tồn kho tại thời điểm submit COD là P0-03, chưa làm trong task này.
- Chưa kiểm thử native trên Android/iOS thật trong lượt này.
