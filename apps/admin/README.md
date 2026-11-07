# LENLAB Admin - Flutter Web

Admin dùng Flutter Web. Hiện có login/session mock, shell/sidebar, Dashboard cơ bản, danh sách sản phẩm/đơn/khách hàng/đánh giá, chi tiết đơn/khách hàng, form voucher mẫu chỉ đọc, hội thoại/kịch bản chatbot và cấu hình.

Chủ yếu là đọc mock, tìm/lọc/phân trang và loading/empty/error/retry. Nút ghi chưa triển khai vẫn khóa hoặc báo giới hạn; chưa CRUD vận hành, RBAC server hoặc API thật. Blog, sản phẩm số, abandoned cart và thống kê nâng cao đã loại.

## Setup

Pubspec yêu cầu Dart `^3.13.4`; môi trường ghi nhận Flutter 3.47.5/Dart 3.13.4. Từ root:

```powershell
Push-Location packages/lenlab_shared
flutter pub get
Pop-Location
cd apps/admin
flutter pub get
flutter devices
flutter run -d edge
```

Chọn thiết bị Web khác nếu `edge` không có trong `flutter devices`. Chưa có hướng dẫn production deployment ở đây.

Login demo lấy từ `MockAdminAuthSource.demoEmail/demoPassword` trong `lib/features/auth/data/admin_auth_source.dart`; chỉ fixture local, không credential thật. Không nhập secret production vào source. Phiên riêng Customer, chỉ RAM; reload mất phiên. Quên mật khẩu/Ghi nhớ đăng nhập chưa tích hợp.

Kiểm tra từ `apps/admin`:

```powershell
flutter analyze
flutter test
```

Baseline kiểm chứng 07/11/2026: 181 Admin tests PASS, không phải bộ test chạy mới trong lượt dọn tài liệu. Giữ `test/goldens/`, không track `test/failures/`. Kiểm assets từ root: `node scripts/verify-assets.mjs`.

## Dữ liệu

`lenlab_shared` chia sẻ source/model/widgets qua dependency path, không chia sẻ RAM giữa Admin Web và Customer Mobile. Fixtures chưa liên thông catalog/order/voucher. Import cùng package không phải đồng bộ hai tiến trình.

Backend dự kiến NestJS/TypeScript + Supabase PostgreSQL; Gemini qua Backend, không secret trực tiếp trong Flutter. API phải cung cấp authorization, IDs/version, transitions, pricing/stock/payment và idempotency có thẩm quyền. Không coi mock là đã thanh toán/thu tiền COD. COD voucher mới Customer vẫn bị khóa.

Xem [root README](../../README.md), [cleanup](../../docs/FE-SCOPE-CLEANUP.md), [audit](../../docs/REMAINING-MVP-WORKFLOWS-AUDIT.md), [roadmap](../../docs/REMAINING-MVP-IMPLEMENTATION-ROADMAP.md). Báo cáo cũ chỉ là lịch sử khi mâu thuẫn scope mới.
