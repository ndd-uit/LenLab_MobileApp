# LENLAB - Flutter frontend MVP

Customer là app Flutter Mobile cho Android/iOS; Admin là Flutter Web. FE hiện dùng dữ liệu mock trong RAM, chưa tích hợp đầy đủ API và chưa liên thông dữ liệu thực giữa Customer và Admin.

`lenlab_shared` dùng chung source/model/widgets, **không phải bộ nhớ dùng chung** giữa hai ứng dụng đang chạy. Backend dự kiến NestJS/TypeScript, database Supabase PostgreSQL. Gemini sẽ được gọi qua Backend; không đặt secret hoặc gọi Gemini trực tiếp từ Flutter.

## Môi trường

- Các pubspec khai báo Dart `^3.13.4`; dùng Flutter SDK có Dart tương thích. Môi trường ghi nhận Flutter 3.47.5/Dart 3.13.4, chưa pin SDK trong repo.
- Customer: Android SDK và thiết bị/emulator; iOS cần macOS + Xcode. Customer chưa cấu hình Web.
- Admin: thiết bị Web có trong `flutter devices`.
- Node chỉ cần cho scripts bảo trì/kiểm tra, không cần chạy Flutter. Đã kiểm assets với Node v24.19.0. Scripts dùng `import.meta.dirname`; browser audit còn dùng WebSocket global. Chưa xác minh Node tối thiểu.

## Setup từ clean clone

Tại root, sau khi cài Flutter và cấu hình platform:

```powershell
flutter --version
flutter doctor
flutter devices
foreach ($project in @('packages/lenlab_shared', 'apps/customer', 'apps/admin')) {
  Push-Location $project
  try {
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "Dependency setup failed: $project" }
  } finally { Pop-Location }
}
```

Giữ hai app `pubspec.lock`; shared dependency dùng path tương đối trong repo. Mock không cần Backend, `.env`, secret, manifest Figma local hoặc tải lại assets. Snapshot chỉ từ file dự kiến public đã được kiểm dependency offline, analyzer/tests và Android debug APK với SDK/package/Gradle cache của máy. Chưa kiểm clone GitHub thật trên máy mới hoặc chạy APK trên thiết bị; không phải chứng nhận build release.

Customer:

```powershell
cd apps/customer
flutter run -d <device-id>
```

Admin trong terminal khác:

```powershell
cd apps/admin
flutter run -d edge
```

Dùng `edge` khi có trong `flutter devices`. Thông tin login mock được khai báo tại CustomerAuthSource/MockAdminAuthSource; không dùng credential thật. Customer mới phải qua Đăng ký để tạo identity riêng trong RAM. Xem [Admin README](apps/admin/README.md).

## Kiểm tra

Từ root, PowerShell:

```powershell
foreach ($project in @('packages/lenlab_shared', 'apps/customer', 'apps/admin')) {
  Push-Location $project
  try {
    flutter analyze
    if ($LASTEXITCODE -ne 0) { throw "Analyze failed: $project" }
    flutter test
    if ($LASTEXITCODE -ne 0) { throw "Tests failed: $project" }
  } finally { Pop-Location }
}
node scripts/verify-assets.mjs
```

Kiểm chứng snapshot ngày 07/11/2026: **789 tests chạy mới PASS** (Shared 149 / Customer 459 / Admin 181), analyzer sạch; 518 assets hợp lệ; Android debug APK build thành công. Snapshot không chứa cache/build cũ của dự án; dependency resolve offline vẫn dùng package cache của máy. Chưa release signing/native smoke. Giữ `apps/*/test/goldens/`; `test/failures/` chỉ là diagnostic local.

## Cấu trúc

```text
apps/customer/             Flutter Mobile, routes/features và tests
apps/admin/                Flutter Web, phiên và Source mock Admin riêng
packages/lenlab_shared/    Models, Store/Source, widgets và runtime assets/fonts
scripts/                   Kiểm assets và công cụ bảo trì
docs/                      Markdown whitelist; bản gốc giữ local
```

## Trạng thái và giới hạn

- Customer có catalog/detail, hồ sơ/avatar/địa chỉ, giỏ selected lines, COD mock, lịch sử/chi tiết đơn, mua lại mở catalog hiện tại và đánh giá sau mua. Guard/ownership client theo user ID không thay authorization Backend.
- Guest xem sản phẩm/sửa giỏ; bắt buộc Auth trước đặt đơn. Không tự merge Guest/account; P0-04 dừng 4A. Không tự chọn hàng khi selection rỗng.
- Voucher public read và usage riêng, candidate/evaluation/quote kỹ thuật, exit command R1/provider shipping R2 đã có. **COD voucher mới vẫn bị safety gate chặn.** Chưa wiring provider/fixtures demo mặc định hoặc UI bỏ voucher/Payment-COD quote hoàn chỉnh. LEN50/ship legacy chỉ là pricing fixture.
- Chuyển khoản chỉ preview/copy thông tin mẫu; chưa payment API/đối soát. VNPay chưa tích hợp. COD creation không đồng nghĩa đã thu tiền.
- Admin chủ yếu đọc mock/tìm/lọc/phân trang; chưa CRUD vận hành, RBAC thật hoặc đồng bộ với Customer. Custom/Chatbot chưa có workflow thực hoàn chỉnh; FAQ tĩnh không phải Gemini.
- Không phục hồi Blog, sản phẩm/thư viện số, abandoned cart, biên lai hoặc thống kê nâng cao đã loại. Android release còn debug signing, chưa production-ready.

Tham khảo [scope](docs/WORKFLOW-SCOPE.md), [cleanup](docs/FE-SCOPE-CLEANUP.md), [audit](docs/REMAINING-MVP-WORKFLOWS-AUDIT.md), [roadmap](docs/REMAINING-MVP-IMPLEMENTATION-ROADMAP.md), [R2](docs/P1-01-R2.md). Tài liệu lịch sử không mở lại scope; proposal chưa duyệt không là policy.

## Assets và phân phối tài liệu

Runtime assets/font/license đã có trong `packages/lenlab_shared/assets/`. `scripts/verify-assets.mjs` kiểm registry, không tải mạng.

`scripts/download-assets.mjs` là công cụ bảo trì Windows dùng `curl.exe`, cần `.design/assets.json` local với entry `{file, url}`. Manifest chứa URL Figma và không được phân phối mặc định; người clone không cần chạy script tải này. Chưa cần manifest public: registry và assets sẵn có đủ cho runtime/kiểm tra. Không đưa cả `.design/`, backup hoặc browser profile lên để sửa setup.

Đọc [chính sách phân phối](docs/DISTRIBUTION-POLICY.md). PDF/DOCX gốc giữ local; không commit `.env`, signing keys, credential thật. Chủ dự án cần xác nhận visibility và quyền chia sẻ ảnh/Figma trước khi publish repository.
