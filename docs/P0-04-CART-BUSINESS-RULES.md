# P0-04 - Chính sách giỏ hàng và điều kiện bắt đầu đợt 4

Ngày cập nhật: 05/11/2026.

**Trạng thái: đã đọc hai bản gốc SRS/UI-UX được bổ sung, không phát hiện mâu thuẫn mới chưa có quyết định ảnh hưởng trực tiếp 4A. Được tiếp tục riêng 4A theo yêu cầu hiện tại; chưa triển khai 4B/4C.**

Điểm dừng thiếu SRS/UI-UX ở lượt trước đã được giải quyết. Hai file được cung cấp thực tế ở the local directory supplied by the project owner; đã đưa bản sao nguyên byte vào `docs/` theo vị trí tài liệu dự án mà chủ dự án chỉ định. D01–D12 và sáu chính sách Mobile vẫn giữ hiệu lực, không yêu cầu duyệt lại.

## 1. Nguồn, mức độ kiểm chứng và thứ tự áp dụng

| Nguồn | Kết quả kiểm tra | Cách sử dụng |
| --- | --- | --- |
| Yêu cầu “APPROVE & IMPLEMENT P0-04” trong trao đổi | D01–D12 đã được chủ dự án phê duyệt | Căn cứ chính sách Guest/session; không lấy hành vi code thay quyết định |
| Yêu cầu “FINALIZE CART BUSINESS RULES & PREPARE P0-04 BATCH 4” | Sáu chính sách được phê duyệt về nguyên tắc; chỉ cho phép code 4A sau đối chiếu thành công | Căn cứ cập nhật trong tài liệu này |
| Báo cáo LENLAB cũ (`docs/Nhóm 4_LenLabProject_Report.pdf`; local-only; not distributed with this repository) | Có trong repo. UC_US_01/04/05/06 và hình sequence đã được đọc ở lượt Pre-Batch 4; đối chiếu lại phần đặc tả ở lượt này | Nguồn lịch sử, ghi rõ chỗ khác quyết định Mobile |
| Mobile.docx (`docs/Mobile.docx`; local-only; not distributed with this repository) | Đã đọc nội dung/bảng | Nêu phạm vi, các mâu thuẫn và dẫn chiếu SRS/UI-UX; không thay thế hai bản gốc |
| Giải trình sau báo cáo (`docs/Giải trình sau báo cáo - Nhóm 4.docx`; local-only; not distributed with this repository) | Lượt Pre-Batch 4 đã đọc; ghi nhận chỉnh sequence giỏ | Bổ sung lịch sử sửa báo cáo, không quy định đủ merge/logout/detached COD |
| [Đợt 1](P0-04-BATCH-1.md), [đợt 2](P0-04-BATCH-2.md), [đợt 3](P0-04-BATCH-3.md) | Có; đã đối chiếu nội dung bàn giao | Bằng chứng hiện trạng và giới hạn triển khai, không phải nguồn tự phê duyệt nghiệp vụ |
| LENLAB_SRS.docx (`docs/LENLAB_SRS.docx`; local-only; not distributed with this repository) | Đã đọc bản 1.0 dự thảo, đặc biệt mục 6.1/6.4/6.5/6.6, BR-01/06 và NFR_11 | Đối chiếu bên dưới; quyết định Mobile mới hơn thay các mô tả cũ khác biệt |
| LENLAB_UI_UX.docx (`docs/LENLAB_UI_UX.docx`; local-only; not distributed with this repository) | Đã đọc bản 1.0 dự thảo, mục 2, UI-03/06/07/10, mục 4.1/4.5/5 và 7 | Luồng chính và các ngoại lệ; không phải lệnh đổi thiết kế P2 |
| `Đồ án khung mẫu.pdf` | Chưa tìm thấy trong lượt Pre-Batch 4 và lượt kiểm tra này | Chưa xác minh yêu cầu cấu trúc/trình bày từ bản mẫu |

Ở lượt trước chưa có đường dẫn SRS/UI-UX; lượt này chủ dự án đã cung cấp hai file gốc. Bản khung mẫu chưa có nhưng không phải điều kiện bổ sung để tự chặn 4A sau chỉ thị mới: chỉ mâu thuẫn mới chưa được quyết định ảnh hưởng trực tiếp 4A mới chặn phần code liên quan.

Thứ tự áp dụng: quyết định Mobile mới nhất của chủ dự án → các quyết định Mobile trước đó còn hiệu lực → tài liệu nguồn phù hợp. Khác biệt với tài liệu cũ được ghi nhận bên dưới; không sửa quyết định Mobile để khớp implementation cũ. Các draft backend-design cũ không phải SRS đã duyệt.

## 2. Business Rules Mobile đã xác nhận

Giữ **CONFIRMED IN PRINCIPLE** cho sáu chính sách được duyệt. Kiểm tra chéo SRS/UI-UX đã hoàn thành trong phạm vi giỏ/session 4A; chi tiết merge/reconcile vẫn chỉ là hướng thực thi cho các đợt sau.

| ID | Quy tắc | Căn cứ và trạng thái | Phạm vi dự kiến |
| --- | --- | --- | --- |
| CART-01 | Guest được xem/thêm/sửa/xóa giỏ. Phải đăng nhập trước checkout và submit COD. | Đã duyệt D01–D02 | Guard đợt 2 giữ nguyên; giỏ riêng ở 4A |
| CART-02 | Guest mới, B mới và account đăng ký mới bắt đầu giỏ rỗng. Fixture giỏ cũ thuộc A tường minh, không thuộc người đăng nhập đầu tiên. | Chính sách 6 - CONFIRMED IN PRINCIPLE | 4A |
| CART-03 | Giỏ account tách theo user ID, giữ trong RAM khi logout. Logout tạo Guest cart mới, không chuyển giỏ account sang Guest. Chuyển trực tiếp A → B chỉ mở giỏ B. | D05–D06, D09; chính sách 6 | 4A |
| CART-04 | Sau login/register thành công, Guest cart merge đúng một lần vào account, giữ hàng hợp lệ. Auth lỗi/hủy không làm mất Guest cart. Không tự đặt hàng sau Auth. | D03, D07 | 4B; chưa làm trong 4A |
| CART-05 | Dòng trùng product ID/variant ID cộng số lượng. Không ghép bằng tên hiển thị, ảnh hoặc index. Retry không cộng trùng. | D04 | 4B |
| CART-06 | Dòng account giữ checkbox account; dòng mới từ Guest giữ checkbox Guest; dòng trùng giữ checkbox account. | Chính sách 1 - CONFIRMED IN PRINCIPLE | 4A cách ly checkbox theo giỏ; quy tắc merge ở 4B |
| CART-07 | Giữ dòng mất/ẩn/hết hàng/vượt tồn để người dùng xử lý; không tự giảm lượng hoặc bỏ hàng. **Chỉ chặn checkout khi dòng không hợp lệ được chọn mua.** Không có dòng chọn vẫn không đặt được đơn. | Chính sách 2 - CONFIRMED IN PRINCIPLE; P0-03 | 4B cho merge/xung đột; không làm yếu validator dòng chọn hiện có |
| CART-08 | COD A pending khóa chỉnh giỏ A; Guest và B không bị ảnh hưởng bởi khóa giỏ A. Logout vẫn được phép và không có nghĩa hủy COD. | Chính sách 3 - CONFIRMED IN PRINCIPLE; D10 | Phần scope khóa phải được đánh giá khi làm 4A; không tự mở rộng quyền tạo COD đồng thời ngoài phạm vi |
| CART-09 | Guest đăng nhập A khi COD A pending: giữ riêng Guest cart, reconcile COD trước rồi mới merge đúng một lần. Không merge sớm hoặc xóa Guest cart đang chờ. | Chính sách 4 - CONFIRMED IN PRINCIPLE | Phối hợp 4B/4C; 4A không được bỏ dữ liệu Guest để né merge |
| CART-10 | COD chỉ mua các dòng được chọn và giữ snapshot tên/giá/số lượng/owner. Thất bại không xóa giỏ. Thành công giữ phần không mua. | Quyết định chọn dòng và P0-03 đã duyệt | Giữ hồi quy; bổ sung identity/snapshot cho detached ở 4C |
| CART-11 | COD hoàn tất sau logout thuộc owner request ban đầu. Lịch sử đúng owner chỉ có một bản ghi, không mở confirmation phiên cũ trong phiên mới. | D10; yêu cầu và nghiệm thu đợt 3 | Giữ đợt 3 |
| CART-12 | Detached COD chỉ reconcile đúng dòng/số lượng request ban đầu bằng identity/snapshot. Không xác định an toàn thì không tự xóa, yêu cầu kiểm tra giỏ. Không sửa B/Guest. | Chính sách 5 - CONFIRMED IN PRINCIPLE | 4C |
| CART-13 | Coupon không tự chuyển tài khoản hoặc được áp mặc nhiên sau merge. Không áp sẵn LEN50 cho Guest/B/account mới. | Chính sách 6 - CONFIRMED IN PRINCIPLE | 4A ngăn rò rỉ/áp mặc nhiên; 4B không mang coupon Guest sang account. Không sửa công thức voucher |
| CART-14 | Sau Auth từ Thanh toán, quay về Cart để xem lại rồi chủ động Thanh toán; không replay submit. Dữ liệu account khác không được phục hồi qua route/history. | D02, D06–D07 | Giữ đợt 2/3 |
| CART-15 | Public catalog/reviews và popup Guest giữ UI được duyệt. Dữ liệu giỏ account không hiển thị trong Guest/B. | D01, D08 và yêu cầu hiện tại | 4A; không thay nội dung/màu/layout popup |

**Hiệu lực thay thế:** CART-07 làm rõ D04 cũ. Không tiếp tục dùng đề xuất Pre-Batch 4 “phải xử lý mọi dòng xung đột trước checkout”. Dòng không hợp lệ không chọn mua không cản các dòng chọn hợp lệ; dòng đó vẫn ở giỏ.

Chính sách checkbox merge đã chốt không cho phép mượn selection của A cho B khi hai giỏ có cùng product/variant. Snapshot giỏ Guest cần được giữ để 4B xử lý sau; tách giỏ ở 4A không đồng nghĩa bỏ Guest cart khi login.

## 3. Đối chiếu Use Case và Sequence lịch sử

Số trang dưới đây là trang PDF 1-based; số trang in trong báo cáo lớn hơn ba trang. Đối chiếu bổ sung hai bản gốc ở mục 3.1.

| Use Case | Đặc tả/Sequence báo cáo cũ | Kết luận đối chiếu với Mobile | Đề xuất cập nhật |
| --- | --- | --- | --- |
| UC_US_01 - Đăng nhập/đăng ký | PDF 45–48; sequence PDF 87, hình 4.5.1. Login/register tạo session rồi về Home. Không có merge hoặc chờ COD cũ. | Khác D07 khi Auth bắt đầu từ Thanh toán. Merge/pending là phần chưa có, không phải đã được tài liệu cũ phê duyệt. | Return intent hợp lệ → Cart; bổ sung merge một lần/chờ reconcile. Login lỗi/hủy giữ Guest cart. Register tạo identity riêng. Không tự submit. |
| UC_US_04 - Giỏ hàng | PDF 52–55; sequence PDF 90, hình 4.5.4. Precondition đăng nhập, Guest bị chuyển Login; có cộng lượng, ProductVariant và bước chọn dòng trước checkout. | Guest cart khác D01. Cộng lượng có căn cứ cho thao tác thêm thông thường, chưa đủ chứng minh policy merge hai giỏ. Không có ownership/logout/delayed merge. | Actor Guest/Customer; phân tách giỏ, selection và coupon. Thêm các nhánh CART-04 đến CART-09. Bỏ luồng Blog khỏi phạm vi MVP. |
| UC_US_05 - Đặt hàng/thanh toán | PDF 55–58; sequence PDF 91, hình 4.5.5. Đăng nhập trước đặt; tạo đơn, trừ kho, xóa giỏ theo user ID; có upload biên lai. | Điều kiện đăng nhập phù hợp. Xóa toàn bộ giỏ trái quyết định mua dòng chọn. Trừ kho thật chưa chốt; biên lai đã loại. Không có nhánh đổi phiên khi pending. | Chỉ mua snapshot dòng chọn; kiểm tra lại trước tạo đơn. Thất bại giữ giỏ. Thêm nhánh current/detached và reconcile an toàn; bỏ upload biên lai. Không suy COD đã tạo là đã thu tiền. |
| UC_US_06 - Theo dõi đơn | PDF 58–60; sequence PDF 92, hình 4.5.6. List theo user ID; có detail, hủy đơn và mua lại tự thêm hàng cũ. | Hướng owner phù hợp; detail phải kiểm tra cả owner, không chỉ ID. Mua lại cũ khác quyết định mở detail để chọn lại. Không có detached result. | Giữ kiểm tra owner tại source/Store và Backend. Đơn detached trở lại lịch sử đúng chủ một lần. Mua lại mở detail catalog, không tự thêm giỏ. Không phục hồi nút hủy đã bỏ. |
| Logout/chuyển account | Không tìm thấy nhánh logout/đổi tài khoản trong các UC/Sequence liên quan đã đọc. | Thiếu đặc tả; không suy ra policy từ truy vấn có user ID. | Bổ sung luồng tham chiếu CART-03/08/09/11/12: giữ giỏ account trong RAM, Guest mới, chặn kết quả cũ áp sang phiên mới. |

Mobile.docx bảng nghiệp vụ mâu thuẫn đã ghi rõ vấn đề thời điểm trừ kho và phân biệt trạng thái đơn/thanh toán. Bảng MVP có giỏ, checkout, COD; nhưng không mô tả checkbox sau merge, giỏ sau logout hoặc identity dòng khi reconcile. Đây là các quyết định Mobile mới, không gán nguồn giả thành “đã có trong SRS”.

Các khác biệt lịch sử về Guest, return intent, dòng chọn, mua lại và biên lai được giải quyết bằng quyết định Mobile mới nhất. Policy tồn kho Backend vẫn cần thống nhất riêng, không nằm trong 4A.

### 3.1. Kết quả đối chiếu SRS/UI-UX gốc bổ sung

| Nguồn | Nội dung gốc / khác biệt | Cách giải quyết theo quyết định đã có |
| --- | --- | --- |
| SRS 6.1 UC_US_01 | Login/register luôn về Home; không có merge, logout/switch cart | D03/D05/D07 đã quy định return intent, tách giỏ và merge. 4A chỉ tách và giữ Guest chờ 4B; không tự submit. |
| SRS 6.4 UC_US_04 | Yêu cầu đăng nhập để quản lý giỏ; cộng lượng khi trùng, từ chối lượng không hợp lệ | D01 cho Guest sửa giỏ. Chính sách 1/2 giải quyết merge/checkbox/xung đột, không tự giảm lượng. Không biến quy tắc giữ xung đột merge thành quyền nhập lượng sai ở thao tác sửa thông thường. |
| SRS 6.5 UC_US_05 | Đăng nhập trước checkout; hậu điều kiện làm trống giỏ/trừ tồn; các đoạn bổ sung tách COD, chuyển khoản, VNPay | Giữ auth guard. Chỉ xử lý dòng chọn theo quyết định đã duyệt, không xóa toàn giỏ. Không trừ kho thật trong mock; lifecycle tồn chờ Backend, không chặn việc tách giỏ RAM. |
| SRS 6.6 UC_US_06 | Có hủy đơn và mua lại tự thêm hàng cũ | Giữ quyết định bỏ nút hủy và Mua lại mở Product Detail, không khôi phục hành vi cũ. |
| UI/UX mục 2, UI-03/06/07/10, mục 4.1/4.5 | Luồng Home → Product → Cart → Checkout → Payment → Order; có trạng thái thiếu thông tin/hết hàng/lỗi mạng; không quy định giỏ Guest/account hoặc merge | D01–D12 và sáu chính sách bổ sung phần còn thiếu; không đổi layout P2. |
| UI/UX mục 5 | Lượng nhập sai báo lỗi và giữ lượng hợp lệ trước đó; voucher sai không tự đổi tổng | Không mâu thuẫn chính sách 2: sửa lượng sai khác với xung đột phát sinh sau merge/catalog thay đổi. Giữ validator hiện có; coupon không tự chuyển hoặc áp mặc nhiên. |
| SRS BR-01/06, PAY-01–05; UI/UX mục 4.2/4.3/7 | Kiểm tra dữ liệu trước giao dịch, tách đơn/thanh toán, bỏ biên lai và Backend xác minh VNPay | Phù hợp định hướng; không triển khai thanh toán thật hoặc mở rộng 4A. |
| Metadata hai bản gốc và SRS NFR_12 | Laravel/MySQL; còn Blog, hàng số và giỏ bỏ quên; UI/UX link Figma chưa cập nhật | Stack mới NestJS/Supabase/Flutter Admin và cleanup đã được quyết định. Không đổi stack, phục hồi chức năng đã loại hoặc sửa Figma. |

SRS chủ yếu là UC dạng bảng, không có sequence chi tiết mới cho Guest merge/logout/detached COD. UI/UX mục 7 chỉ nêu các nhánh thanh toán chính, không thay sequence chi tiết của báo cáo cũ. Không suy diễn phần vắng mặt thành quy tắc mới. Không tìm thấy quyết định mới chưa được giải quyết ảnh hưởng trực tiếp đến tách giỏ/checkbox/coupon RAM ở 4A.

## 4. Đề xuất thay đổi Sequence - chưa sửa tài liệu nguồn

Các bước sau là bản đề xuất đưa vào Use Case/Sequence cập nhật, không phải endpoint/DTO hay transaction Backend đã chốt.

### 4.1. Auth và chuyển giỏ

1. Guest sửa giỏ của phiên Guest; snapshot gồm dòng và checkbox, không chứa dữ liệu account khác.
2. Bấm Thanh toán → Auth, giữ Guest cart/return intent. Login ↔ Register không làm mất intent.
3. Auth lỗi/hủy → giữ giỏ, không merge hoặc tạo đơn.
4. Auth thành công → kích hoạt đúng user ID; mở giỏ account đó. Không chuyển giỏ account trước thành Guest hoặc giỏ account mới.
5. Nếu COD của account còn pending: giữ riêng Guest cart, khóa chỉnh giỏ chủ COD; chờ kết quả. Guest/B không bị khóa giỏ bởi request A.
6. Nếu cần reconcile: xử lý đúng owner/request một lần, trường hợp không xác định an toàn giữ dòng và yêu cầu kiểm tra.
7. Merge Guest vào account một lần: cộng theo ID, áp checkbox CART-06, giữ xung đột, không mang coupon sang. Chỉ đánh dấu đã tiếp nhận sau thao tác merge thành công.
8. Về Cart xem lại. Người dùng chọn dòng và chủ động Thanh toán; dòng không hợp lệ chỉ chặn khi được chọn mua.

Bước 5–7 thuộc phối hợp 4B/4C; không triển khai ngầm trong 4A. Cách nhận diện snapshot/dòng/revision/merge receipt là thiết kế kỹ thuật cần hoàn thiện trước đúng đợt, không mặc định ghép bằng key hiển thị.

### 4.2. COD và đổi phiên

1. Customer chọn dòng, địa chỉ và dữ liệu xác nhận. Kiểm tra auth, chụp owner/session cùng snapshot dòng/tiền.
2. Kiểm tra lại catalog, lượng, tồn, giá và tổng theo P0-03. Sai thì giữ giỏ/draft và trả lý do.
3. Khi request đang pending, khóa chỉnh giỏ chủ request. Logout vẫn được phép.
4. Source hoàn tất tạo đơn đúng owner ban đầu; không coi logout là hủy.
5. Còn đúng phiên: xử lý đúng phần giỏ đã mua, giữ dòng không mua, mở confirmation hợp lệ.
6. Đổi phiên: không sửa draft/receipt/giỏ phiên mới; lịch sử đơn thuộc owner gốc.
7. Chủ đơn quay lại: nhận lịch sử đúng một lần và reconcile giỏ theo identity/snapshot đúng một lần. Không xác định an toàn thì không tự xóa.
8. Sau reconcile mới xử lý Guest merge đang chờ; không nhân đôi đơn/merge hoặc dọn giỏ lần hai.

“Đơn đã có trong lịch sử” không chứng minh “giỏ đã reconcile”. Cần phân biệt hai kết quả, vì đợt 3 đã reconcile lịch sử mà chưa xử lý giỏ. Không dùng việc queue lịch sử đã rỗng để bỏ qua xử lý giỏ ở 4C.

## 5. Ranh giới Mobile, mock FE và Backend

| Lớp | Trách nhiệm | Không được suy ra |
| --- | --- | --- |
| Quyết định nghiệp vụ Mobile | Các CART rules, Guest không checkout, ownership, dòng chọn, xử lý an toàn khi đổi phiên | Quyết định công nghệ lưu trữ, SKU hoặc thời điểm trừ kho thật đã chốt |
| Mock FE | Trong các đợt được phép: map giỏ theo user ID, Guest session riêng, checkbox/coupon đúng scope, session guards, snapshot và chống áp kết quả cũ; tất cả RAM | Dữ liệu đã persist, xác thực có thẩm quyền hoặc đảm bảo đa thiết bị |
| Backend | Xác thực principal/ownership; giỏ/variant ID ổn định; kiểm tra giá/tồn/totals; transaction/idempotency; trạng thái đơn/thanh toán và lưu lâu dài | Tin user ID, giá hoặc generation do client gửi |

Backend còn phải thống nhất contract merge retry/version, identity dòng mua/revision khi reconcile, trạng thái request chưa rõ kết quả, và lifecycle giữ/trừ/hoàn tồn. Những chi tiết này không được tự triển khai trong 4A mock hoặc lấy SQL xóa toàn giỏ của sequence cũ làm chính sách.

## 6. Phạm vi và kiểm chứng 4A

Phạm vi duy nhất sau khi vượt điều kiện tài liệu: giỏ riêng Guest/A/B, giữ giỏ account trong RAM, logout/switch không rò rỉ, fixture A và coupon/selection đúng scope. Giữ UI P2/popup và kiến trúc hiện tại. Chưa merge ở 4B, chưa reconcile giỏ COD ở 4C. Kết quả triển khai/kiểm chứng ghi tại [P0-04-BATCH-4A.md](P0-04-BATCH-4A.md).

File dự kiến đánh giá/sửa khi được phép code:

- `packages/lenlab_shared/lib/src/state/lenlab_store.dart`: cart access/mutation, selection, coupon, session transition và các chỗ sử dụng khóa COD.
- `packages/lenlab_shared/lib/src/state/customer_account_data.dart`: nơi giữ giỏ account trong RAM hoặc tham chiếu state giỏ riêng phù hợp kiến trúc hiện tại.
- Nếu cần, một state helper nhỏ cho cart; không thay ChangeNotifier/CustomerScope hoặc refactor hàng loạt.
- `apps/customer/lib/features/cart/presentation/cart_page.dart` và widget liên quan: chỉ nếu cần ngăn controller/callback/cart view cũ tác động giỏ mới; không đổi layout/popup.
- Shared/Customer session/cart tests; các fixture và golden dùng giỏ A cần login A tường minh, không cập nhật golden hàng loạt để che thay đổi ngoài phạm vi.

Acceptance/tests chuẩn bị cho 4A:

1. Guest mới rỗng nhưng được thêm/sửa/xóa/chọn dòng; B và account đăng ký mới rỗng, A nhận đúng fixture.
2. A → logout không đưa hàng A sang Guest. Guest mới không giữ checkbox/coupon A.
3. A → B, kể cả chuyển trực tiếp không có frame Guest, không rò rỉ cart/selection/coupon.
4. A → logout → A giữ đúng giỏ và lựa chọn account A trong vòng đời Store; không persistence sau restart.
5. B sửa giỏ riêng rồi A/B quay lại thấy đúng dữ liệu; cùng product/variant ở hai account không dùng chung CartLine mutable.
6. Tham chiếu hoặc callback cart từ phiên cũ không sửa cart phiên mới.
7. Login lỗi/hủy giữ Guest cart; Auth từ checkout vẫn về Cart, không tạo đơn. Giỏ Guest không bị mất chỉ vì 4A chưa merge.
8. Không tự merge ở 4A; các test cộng lượng/checkbox merge thuộc 4B.
9. COD A pending khóa giỏ A, Guest/B vẫn sửa giỏ riêng được; giữ owner/draft guards cũ. Không xử lý detached cart trong 4A.
10. P0-01/02/03, protected routes, ownership đợt 3 và các test popup/UI liên quan tiếp tục đạt với fixture đúng owner.

Kết quả 638 test của đợt 3 là lịch sử bàn giao. Lượt 4A chạy analyzer/tests riêng; số liệu và giới hạn runtime ghi trong báo cáo 4A, không dùng kết quả cũ thay kiểm chứng mới.

## 7. Điều kiện mở khóa triển khai

| Điều kiện | Trạng thái |
| --- | --- |
| Sáu chính sách được chủ dự án phê duyệt về nguyên tắc | Đạt |
| Đối chiếu báo cáo cũ và Mobile.docx; ghi nhận khác biệt với quyết định Mobile | Đạt trong phạm vi nguồn hiện có |
| Đọc và đối chiếu bản gốc `LENLAB_SRS` và `LENLAB_UI_UX` | Đạt; xem mục 3.1 |
| Xử lý khác biệt mới phát hiện từ hai bản gốc, nếu có | Các khác biệt có quyết định Mobile mới thay thế; không phát hiện blocker mới trực tiếp 4A |
| Triển khai 4A, analyze/tests và nghiệm thu | Xem báo cáo 4A; dừng chờ nghiệm thu trước 4B/4C |

Hai bản gốc đã có; không yêu cầu duyệt lại sáu chính sách. Bản khung mẫu vẫn chưa được cung cấp, không tự lấy báo cáo LENLAB thay bản khung; yêu cầu hiện tại cho phép tiếp tục 4A khi không có mâu thuẫn mới trực tiếp nên không giữ blocker lịch sử này cho 4A.

Lượt trước dừng ở tài liệu do thiếu hai bản gốc. Lượt hiện tại chỉ triển khai Flutter mock 4A và tests tương ứng; không sửa Backend, database, API, dependency hoặc Figma; không cập nhật golden. Không thực hiện merge 4B hay reconcile giỏ 4C.
