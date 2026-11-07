# lenlab_shared

Package Flutter dùng chung cho customer và admin, không publish.

Sau cleanup, repository/catalog/order seed chỉ còn sản phẩm vật lý. Không còn API mock gửi/xác nhận biên lai hay tải sản phẩm số. Ảnh Custom, avatar, ảnh đánh giá vẫn giữ. Xem [báo cáo cleanup](../../docs/FE-SCOPE-CLEANUP.md).

- `src/domain/`: models.
- `src/data/`: interface repository, mock và nguồn địa chỉ.
- `src/state/`: store trong bộ nhớ.
- `src/ui/`: theme P2, widget dùng chung, map asset.
- `assets/`: ảnh/SVG gốc, font và giấy phép OFL.

Import public API bằng `package:lenlab_shared/lenlab_shared.dart`. Các app không import file trong `src/` trực tiếp. Chưa có HTTP backend hoặc persistence; dữ liệu reset khi khởi động lại.

Chạy `flutter analyze` và `flutter test` trong thư mục package. Xem [CODEBASE.md](../../docs/CODEBASE.md) cho quyết định giữ/xóa dependency và asset.
