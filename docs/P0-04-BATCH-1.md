# P0-04 - Đợt 1: Mock identity và session

Ngày bàn giao: 04/11/2026. Chỉ đợt 1, chờ nghiệm thu trước đợt 2. Không thay bố cục, màu sắc, nội dung popup Guest, routing framework hay ChangeNotifier/CustomerScope.

## Đã triển khai

- `CustomerIdentity` chứa ID ổn định, tên, email, điện thoại. `CustomerSessionStamp` chứa user ID và session generation trong RAM, không phải token.
- `CustomerAuthSource` có hợp đồng login/register riêng, inject qua `LenlabStore(authSource: ...)`. Mock login chỉ nhận danh tính đã có; không tự tạo tài khoản từ email bất kỳ như trước. Đăng ký tạo danh tính mới, từ chối email/điện thoại trùng, kể cả hai request đăng ký đồng thời.
- Tài khoản A: ID `customer-demo-a`, email `nguyenvan.a@example.com`, điện thoại `0901234567`. B: ID `customer-demo-b`, email `nguyenvan.b@example.com`, điện thoại `0901234568`. Có thể inject danh sách tài khoản khác vào mock source; ID và alias phải duy nhất.
- Mock chấp nhận mật khẩu thử nghiệm bất kỳ không rỗng. Không lưu, log hay so khớp mật khẩu thật. Tài khoản đăng ký chỉ tồn tại trong vòng đời source RAM; email được trim/lowercase, điện thoại được trim.
- `LenlabStore.signIn/register/logout` là các điểm chuyển phiên tập trung. `signedIn` được suy ra từ identity. Login/logout thành công thay generation; login lỗi không thay identity/generation hoặc giỏ.
- Request auth mang request version và generation ban đầu. Request cũ, logout trong lúc login, đăng nhập mới hơn, form bị dispose hoặc store bị dispose đều chặn áp dụng kết quả cũ. Lỗi auth cũ cũng không ghi đè phiên mới. `false` từ login/register nghĩa là kết quả không còn được phép áp dụng; form không toast thành công hoặc điều hướng.
- AuthPage gọi đúng hợp đồng login/register; Drawer và Profile gọi logout tập trung. Bỏ đăng nhập khỏi repository sản phẩm. Repository không phải mock mà thiếu AuthSource sẽ báo chưa cấu hình, không âm thầm bật mock auth.
- Định danh owner fixture cũ được khai báo `LenlabStore.fixtureOwnerId = customer-demo-a`, không lấy người đăng nhập đầu tiên. Đây mới là khai báo owner cho bước chuyển dữ liệu đợt 3, chưa phải kiểm soát truy cập.

## File thay đổi

File mới:

- `packages/lenlab_shared/lib/src/domain/customer_identity.dart`
- `packages/lenlab_shared/lib/src/data/customer_auth_source.dart`
- `packages/lenlab_shared/test/customer_session_test.dart`
- `apps/customer/test/customer_session_test.dart`
- `docs/P0-04-BATCH-1.md`

File cập nhật:

- `packages/lenlab_shared/lib/lenlab_shared.dart` - export hợp đồng mới.
- `packages/lenlab_shared/lib/src/state/lenlab_store.dart` - identity, generation, request guard, login/register/logout.
- `packages/lenlab_shared/lib/src/data/lenlab_repository.dart`, `mock_lenlab_repository.dart` - bỏ hợp đồng login cũ trả void; giữ API sản phẩm.
- `apps/customer/lib/features/auth/presentation/auth_page.dart` - dùng AuthSource qua store.
- `apps/customer/lib/shared/navigation/customer_drawer.dart`, `features/profile/presentation/profile_page.dart` - logout tập trung.
- `apps/customer/test/customer_test.dart` - dùng tài khoản demo có danh tính rõ ràng.
- `apps/customer/test/register_test.dart` - fault injection riêng cho operation register.
- `apps/customer/README.md` - cách đăng nhập mock và giới hạn đợt 1.

Không sửa Admin, catalog chuẩn, COD validation, route, golden hoặc dependency. Bản sao trước thay đổi: `.design/p0-04-batch-1/before.zip`.

## Kiểm chứng

18 test mới: Shared 14, Customer 4. Bao phủ alias A/B, ID ổn định, đăng nhập không tự đăng ký, đăng ký danh tính riêng, trùng alias và đăng ký đồng thời, lỗi/retry riêng login/register, generation, lỗi giữ giỏ/identity, request cũ, logout khi login đang gửi, A → logout → A, dispose form/store và wiring form/điều hướng.

Toàn bộ test: **567 PASS** (Shared 72, Customer 314, Admin 181), tăng 18 từ 549. Test P0-01, P0-02, P0-03 và golden hiện có tiếp tục đạt, không cập nhật golden. Analyzer chạy cho cả ba project; kết quả cuối ghi nhận không có diagnostics.

Đã thử hot restart qua Dart MCP: DTD kết nối được nhưng không có app đang chạy, nên chưa xác minh runtime trên thiết bị. Widget tests đã chạy các form; không xem chúng là kiểm chứng native trên APK.

## Những việc chưa hoàn thành trong đợt này

- D01–D08 và D10–D12 chưa được hiện thực đầy đủ: checkout/route/COD guard thuộc đợt 2; ownership và transient draft thuộc đợt 3; giỏ riêng/merge một lần/logout/reset Guest thuộc đợt 4; bất đồng bộ COD và hồi quy toàn chính sách thuộc các đợt sau.
- Riêng bộ lọc kết quả auth đã hoàn thành; session stamp chưa được áp vào COD, review, profile, địa chỉ hay các source còn lại. Không được suy ra rằng request COD cũ đã an toàn.
- Profile/địa chỉ/đơn/custom/favorites vẫn là dữ liệu fixture chung. Đăng ký mới đã có identity riêng nhưng profile UI chưa bind theo identity; login B chưa chứng minh cách ly dữ liệu A. Chưa dùng bản này để kiểm chứng bảo mật hoặc acceptance toàn P0-04.
- Login hiện vẫn về Home; chưa return-to-cart theo D07. Login/logout đợt 1 chưa merge/tách/clear giỏ hoặc draft. Không coi giữ nguyên giỏ hiện tại sau logout là chính sách D05 cuối cùng.
- Setter `signedIn` có `@visibleForTesting` được giữ tạm cho fixture tests cũ, ánh xạ true vào demo A. Production Customer không còn gán bool trực tiếp. Không dùng setter này làm hợp đồng tích hợp API.
- D09 RAM-only đã được giữ; không persistence. D11 có A/B, injection và owner ID tường minh; thực thi owner-scoped reads/writes chờ đợt 3.

## Chờ Backend

Backend cần cung cấp hợp đồng login/register trả user ID ổn định, lỗi danh tính trùng/thông tin không hợp lệ và profile theo user ID. AuthSource HTTP sau này thay mock qua injection; xác thực, token và kiểm tra quyền có thẩm quyền thuộc Backend, không được dựa vào generation hoặc guard Flutter.

Đợt tiếp theo sau nghiệm thu: guard tại nút Thanh toán, route/private action, COD submit và đích sau đăng nhập, giữ nguyên UI và validation P0-03. Chưa triển khai trong bàn giao này.
