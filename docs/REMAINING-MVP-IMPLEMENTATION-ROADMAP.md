# LENLAB - Remaining MVP Implementation Roadmap

Ngày lập: 05/11/2026. **PROPOSED - kế hoạch để nhóm duyệt, không phải lệnh triển khai.** Audit nền: [REMAINING-MVP-WORKFLOWS-AUDIT.md](REMAINING-MVP-WORKFLOWS-AUDIT.md).

> Trạng thái mới (06/11/2026): V04a đã nghiệm thu kỹ thuật quote; [readiness V04b](P1-01-V04B-READINESS.md) đã hoàn thành; [R1](P1-01-R1.md) đã nghiệm thu. [R2](P1-01-R2.md) đã triển khai contract/provider shipping dùng chung và tests, chờ nghiệm thu: 789 PASS, analyzer sạch. Chưa wiring provider vào app demo, nối UI/re-quote hoặc triển khai R3–R7; COD voucher mới vẫn khóa. Một voucher/đơn, không stacking; Guest public read, usage private và không Cart Merge giữ nguyên. Typed demo/UI exit/pricing binding vẫn chờ duyệt theo readiness.

## 1. Ràng buộc và mức sẵn sàng

- Giữ Flutter/Dart Customer và Admin Web; Backend NestJS/TypeScript, Supabase PostgreSQL, Gemini qua Backend.
- P0-04 dừng 4A; **không lên lịch auto merge 4B hoặc reconcile 4C**. Không tự xóa dữ liệu Guest pending của implementation cũ khi retention chưa rõ.
- Giữ P0-01/02/03 và ownership/session/selected-line rules. V01 đã xong, không mở lại công thức LEN50 trong task UI.
- Admin tạo/công khai voucher, Customer tự xem/dùng; không có bước Admin phát từng tài khoản bắt buộc.
- Không phục hồi Blog, sản phẩm số, abandoned cart, upload biên lai hoặc dashboard nâng cao.
- Không chuyển framework/state management/routing, không refactor hàng loạt. Một task = một thay đổi reviewable; chạy analyze và tests liên quan rồi nghiệm thu trước task kế tiếp.
- Không sửa UI P2 khi chưa đủ frame hoặc interaction spec; task dưới đây ghi rõ phần phải xác minh thiết kế. Audit không xác nhận có đủ frame cho mọi form mới.
- Mỗi module giữ mock và API adapters tách biệt. API lỗi không fallback sang seed mock để hiển thị đơn/thanh toán giả thành dữ liệu thật.

| Nhãn | Ý nghĩa |
| --- | --- |
| MOCK FE - làm được ngay | Không cần API đang chạy, rule của phần đó đã đủ rõ; vẫn phải duyệt task trước triển khai |
| CHỜ QUYẾT ĐỊNH | Thiếu rule/UI scope; được soạn proposal, không tự code thành business policy |
| CHỜ BACKEND CONTRACT | Chưa có DTO/state/error/auth/version đủ để tích hợp; có thể review contract/fixture nhưng chưa gọi là API integration |
| CHƯA CẦN MVP | Không đưa vào implementation hiện tại; không phải bug phải phục hồi |

P0 = bảo toàn scope/owner/tiền và contract quan trọng, P1 = core MVP còn thiếu, P2 = bổ sung sau đường mua hàng. Các endpoint/schema trong backend-design là draft, không sử dụng như API đã được nghiệm thu.

## 2. Thứ tự các đợt nhỏ

| Đợt | Công việc | Điều kiện kết thúc |
| --- | --- | --- |
| 0 | R00; V02a đọc campaign công khai mock; đề xuất V02b/C01/O00 | Chính sách hiện tại rõ, không lẫn campaign công khai với usage riêng; rule chưa chốt được ghi unknown |
| 1 | V03a → V03b → V04 sau contract; có thể làm U01a auth contract song song ở mức tài liệu | Apply mock xuyên selected checkout, không tự đặt rule hoặc tạo đơn khi Auth |
| 2 | C01 → A01 → từng A02/A03; A04 sau stock definitions | Admin commands và published catalog mapper có cùng IDs; không claim hai app chạy thật đã liên thông |
| 3 | O00 → O01 → từng O02; P01/P02; U01/API adapters tương ứng | Order/payment DTO thống nhất; mock states/contract tests đủ, server authority vẫn thuộc Backend |
| 4 | X01 → từng X02; G01 → G02; M01; P03 khi có môi trường | Custom/Chatbot trong MVP có luồng rõ; sáu E2E có bằng chứng qua API/dev environment |
| 5 | A05/A06 nếu giữ trong bản nghiệm thu tối thiểu | Read tích hợp đúng và chỉ write được duyệt; không mở lại quản trị nâng cao |

Các nhánh độc lập có thể được nhóm bố trí riêng, nhưng không triển khai toàn bộ cùng lượt. Đợt 0 là đề xuất bước tiếp theo, không được xem là đã bắt đầu code.

## 3. Task cards

### R00 - Chuẩn hóa tài liệu trạng thái MVP

| Trường | Nội dung |
| --- | --- |
| Priority | P0 |
| Sẵn sàng | MOCK FE / DOCS - có thể làm ngay |
| Dependency | Audit hiện tại và quyết định mới. |
| Mục tiêu/phạm vi | Đề xuất sửa các đoạn chờ merge/phát voucher cá nhân/feature đã loại trong WORKFLOW-SCOPE, Cart Rules và draft integration; không đổi báo cáo bàn giao lịch sử thành trạng thái chưa từng có. |
| Acceptance criteria | Danh sách superseded rõ; không còn roadmap tự tiếp tục 4B/4C hoặc phân phối voucher per-user. Tách retention legacy pending thành câu hỏi riêng, chưa xóa source state. |
| Tests cần bổ sung/chạy | Kiểm link/diff/scope; không cần test ứng dụng nếu chỉ docs. |
| File/port dự kiến | WORKFLOW-SCOPE, Cart Rules, backend-design references; chưa sửa ở lượt audit này. |

### V02a - Model public voucher và nguồn danh sách mock

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | MOCK FE - có thể làm ngay trong scope đọc |
| Dependency | Quyết định voucher công khai đã chốt; R00 chỉ để docs rõ. |
| Mục tiêu/phạm vi | Tách public campaign metadata khỏi usage cá nhân; mock list dùng dữ liệu chiến dịch tường minh, giữ UI card hiện có. Không suy rule từ text/date label và không bật apply. |
| Acceptance criteria | A/B đọc cùng campaign ID; không nhận trạng thái used/lịch sử của nhau. Không cần Admin phát riêng. Giữ auth guard hiện tại; không tự mở Guest voucher khi chưa chốt visibility. |
| Tests cần bổ sung/chạy | List loading/empty/error, A/B campaign equality, usage isolation, no coupon auto-set; golden chỉ thay nếu nội dung đúng phạm vi. |
| File/port dự kiến | Customer voucher_source + DTO/mock fixtures, voucher tests; review theo quyết định mới. |

### V02b - Contract eligibility/quote và rule register voucher

| Trường | Nội dung |
| --- | --- |
| Priority | P0 |
| Sẵn sàng | CHỜ QUYẾT ĐỊNH + BACKEND CONTRACT (có thể soạn đề xuất ngay) |
| Dependency | V02a; min/cap/date/quota/stack/rounding/usage decisions. |
| Mục tiêu/phạm vi | Thiết kế request theo selected items/context và response eligible/reason/totals/version; fixture kết quả rõ, không dựng engine tự đặt rule. |
| Acceptance criteria | Nhóm duyệt trường bắt buộc, error codes và rule áp dụng cho từng loại; chưa biết thì optional/unknown, không mặc định vô hạn/stackable. |
| Tests cần bổ sung/chạy | DTO decode/unknown enum/missing field và fixtures phân biệt invalid code/min/expiry; không tự gán hạn thật theo đồng hồ. |
| File/port dự kiến | Voucher Source interfaces, checkout quote contract; chưa chọn HTTP library. |

### V03a - Cart mở nhập/chọn mã qua UI hiện có

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | IMPLEMENTED - navigation/candidate mock; chờ nghiệm thu, chưa apply/evaluate |
| Dependency | V02a/b; chốt payload/candidate theo phiên, return context và Back/cancel khi thiếu context. Chưa cần lifecycle quota/TTL cụ thể cho navigation-only mock. |
| Mục tiêu/phạm vi | Nối Cart/Ví qua UI hiện có, giữ candidate đúng phiên. Chưa có dòng chọn thì về Cart, không tự tick hàng/đặt đơn. Navigation-only không giả Apply thành công; Dùng ngay đủ context/eligible được nối trực tiếp ở V03b, không bắt nhập lại mã. |
| Acceptance criteria | Back/cancel giữ coupon hợp lệ trước; Guest vẫn phải Auth trước đặt; không tự create order. Nếu P2 chưa mô tả đích điều hướng, trình phương án trước khi code. |
| Tests cần bổ sung/chạy | Navigation/Back/cancel, keyboard, không context giỏ, session switch; UI không đổi màu/layout. |
| File/port dự kiến | CartVoucher, VoucherPage, navigation payload tối thiểu. |

### V03b - Áp dụng/Dùng ngay/bỏ lựa chọn bằng mock evaluator

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | IMPLEMENTED MOCK - chờ nghiệm thu. UI bỏ lựa chọn mới chưa có thiết kế được duyệt; quote/COD mới chờ V04 |
| Dependency | V02b + V03a; quy tắc thay/bỏ mã được duyệt. |
| Mục tiêu/phạm vi | Dùng mock kết quả đánh giá được inject; busy/error/retry, no stale apply. Không thêm quota/expiry engine ngầm. |
| Acceptance criteria | Dùng ngay bằng campaignId không bắt nhập lại code; đủ context và eligible thì áp đúng giỏ/người. Mã sai giữ kết quả cũ chỉ nếu còn hợp lệ cùng context; request cũ không ghi phiên mới. Quota theo campaign, không dùng đã từng dùng để tự chặn; full/capped ship hiển thị đúng nghĩa. Không auto submit hoặc điều khiển lifecycle usage server. Bỏ mã theo flow được duyệt. |
| Tests cần bổ sung/chạy | Valid/invalid, double tap, retry, cart changed while waiting, logout/A→B; mỗi test nêu fixture policy chứ không ngầm định business rule. |
| File/port dự kiến | Voucher Source/actions, Store state seam nhỏ; giữ ChangeNotifier. |

### V04 - Voucher và tổng tiền xuyên Cart → Review → COD

> Tách đợt: **V04a đã triển khai mô hình/source mock quote và đồng bộ hiển thị Cart/Review**, chưa quote API. **V04b chưa bắt đầu**, không mở COD với voucher mới, không cập nhật order snapshot/lifecycle. Bảng dưới là phạm vi toàn V04, không phải cấp phép làm cả hai đợt. Gate tiếp theo: rule demo tường minh, phí ship/context và UI bỏ/thay voucher; xem [bàn giao V04a](P1-01-V04A.md).

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ QUOTE CONTRACT → MOCK FE, rồi API |
| Dependency | V03b; quote inputs/output, snapshot fields và P0-03. |
| Mục tiêu/phạm vi | Đánh giá lại khi selected items/qty/price/address liên quan đổi; cùng quote/totals/snapshot tới Order. |
| Acceptance criteria | V01 tiếp tục đạt; stale quote không tạo đơn, lỗi giữ draft; order ghi khoản giảm có trace được; ship không thay ngoài contract. |
| Tests cần bổ sung/chạy | Selected/unselected min threshold, source errors, stale version, owner, snapshot; P0-03 regression. |
| File/port dự kiến | OrderReviewSource/CodOrderSource mappers, Payment UI error handling. |

### C01 - Product/Variant/Category DTO và mapping chuẩn

| Trường | Nội dung |
| --- | --- |
| Priority | P0 |
| Sẵn sàng | CHỜ BACKEND CONTRACT + SKU RULE |
| Dependency | P0-02 đã xong; nhóm xác nhận product/variant IDs, fields, media và stock unit. |
| Mục tiêu/phạm vi | Soạn read/write DTO fixtures và mapping Customer/Admin, không ghép theo tên. Không tự sinh SKU từ chuỗi biến thể. |
| Acceptance criteria | Cùng ID resolve được cả hai view; default/nonvariant product rõ; hidden/missing/unknown handled; DTO API không chứa class UI. |
| Tests cần bổ sung/chạy | Mapper/ID duplicates/unknown category/unavailable/variant mismatch; preserve product_identity_test. |
| File/port dự kiến | Catalog sources, AdminProduct projection, shared model adapters theo module. |

### A01 - Admin form tạo sản phẩm mock

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ C01 + FIELD RULE + UI P2 |
| Dependency | C01; các trường bắt buộc/price/media validation; frame tạo chưa kiểm chứng trong audit này. |
| Mục tiêu/phạm vi | Dựng form bằng thiết kế đã duyệt, validate/submit/error/cancel; thêm vào injected mock repository, chưa API. |
| Acceptance criteria | Tạo thành công một record ID ổn định, list reload thấy record; lỗi giữ form, submit trùng không nhân bản; không tự publish nếu policy chưa chốt. |
| Tests cần bổ sung/chạy | Required/invalid, save retry/cancel, list reload, permissions fixtures. |
| File/port dự kiến | Admin products Source/commands + form; không bật nút giả khi chưa có command. |

### A02 - Admin sửa/publish/archive sản phẩm mock

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ POLICY + C01 + A01 |
| Dependency | Version/conflict; publish conditions; xử lý hàng đã có đơn; chọn archive/delete rõ. |
| Mục tiêu/phạm vi | Tách edit và visibility/archive thành các đợt nhỏ, không hard-delete theo suy đoán. |
| Acceptance criteria | Update đúng ID/version; cancel giữ bản cũ; published projection phản ánh đúng; xung đột báo tải lại; không sửa snapshot đơn cũ. |
| Tests cần bổ sung/chạy | Stale edit/version, hidden/missing, cancel, historical order snapshot unchanged. |
| File/port dự kiến | Product command source và UI theo P2; Customer mapper fixtures. |

### A03 - Category và Variant CRUD tối thiểu

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ SCHEMA/RULE + UI/CONTRACT |
| Dependency | C01; unique SKU/option combinations/default variant/inactive policy. |
| Mục tiêu/phạm vi | Category và variant thành hai task riêng khi triển khai; không nhét toàn inventory vào form product. |
| Acceptance criteria | ID ổn định, không orphan reference; inactive variant không được mua; lỗi giữ draft. Chỉ phần field/schema đã duyệt. |
| Tests cần bổ sung/chạy | Duplicate SKU/options, category in use, active/inactive mapping; stock per SKU fixtures. |
| File/port dự kiến | Admin category/variant Source/editor; Customer variant adapter. |

### A04 - Inventory read và điều chỉnh tối thiểu

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ BACKEND CONTRACT + LIFECYCLE |
| Dependency | C01/A03; on-hand/available/reserved definitions và movement permission. |
| Mục tiêu/phạm vi | Read balances trước; adjustment command riêng sau rule. Không viết reservation/ledger có thẩm quyền ở Flutter. |
| Acceptance criteria | UI không coi stockTone fixture là threshold; version/error handling; server/source trả balance mới. Không tự cộng hoàn lượng chưa bị trừ. |
| Tests cần bổ sung/chạy | Out-of-stock, stale balance, allowed/denied adjustment, no client double effect. |
| File/port dự kiến | Inventory read/command adapter + Admin stock UI khi được duyệt. |

### O00 - Chốt state/actor/stock/payment matrix

| Trường | Nội dung |
| --- | --- |
| Priority | P0 |
| Sẵn sàng | CHỜ QUYẾT ĐỊNH + BACKEND CONTRACT |
| Dependency | D03/D04/D13 trong backend approval register; các quyết định đã chốt không hỏi lại. |
| Mục tiêu/phạm vi | Tách order, payment method/status, COD collection và allowed actions; ghi pending/logout recovery contract, không code 4C. |
| Acceptance criteria | Nhóm duyệt triggers/permissions; delivered không tự paid, cancel/refund không được thêm mặc định; recovery khác merge. |
| Tests cần bổ sung/chạy | Acceptance scenarios phiên cũ, double request, stock race, late payment; đây là test spec trước implementation. |
| File/port dự kiến | Backend design/API draft và enum mapping đề xuất, không migration. |

### O01 - Order read contract Customer/Admin

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ BACKEND CONTRACT → MOCK DTO rồi API |
| Dependency | O00; same order IDs/owner/snapshots/timeline data. |
| Mục tiêu/phạm vi | Chuẩn hóa hai Source read projections, fake response fixtures chung cho mapper tests; sau đó API adapters. |
| Acceptance criteria | Cùng DTO fixture hiện đúng list/detail hai app; unknown/missing fields không thay đơn khác; ownership và Back giữ. Không gọi fixture tests là runtime liên thông. |
| Tests cần bổ sung/chạy | Customer/Admin mapping, permission denied/not found, stale list/detail, timestamp absent. |
| File/port dự kiến | OrderList/DetailSource, AdminOrdersSource; không chia sẻ RAM giữa tiến trình. |

### O02 - Admin transition từng action

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ O00/O01 + PERMISSION RULE |
| Dependency | Allowed transition/expectedVersion/actor và tác động tồn/thanh toán. |
| Mục tiêu/phạm vi | Mỗi action Confirm/Processing/Shipping/Delivered (chỉ state duyệt) một task mock nhỏ; dùng Source command trả result. |
| Acceptance criteria | Không dropdown arbitrary status; double tap/version race an toàn; Customer view đọc được event DTO tương ứng trong test harness, không fake API integration. |
| Tests cần bổ sung/chạy | Allowed/forbidden transitions, stale version, pending/error/retry, delivery/payment separation. |
| File/port dự kiến | Admin order detail actions/source; không mở Customer cancel. |

### P01 - Bank transfer pending/instructions/status UI

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ BACKEND CONTRACT → MOCK STATES |
| Dependency | O00/O01; create timing/reference/đối soát, bank instructions. |
| Mục tiêu/phạm vi | Thay demo-only preview bằng contract-driven state UI; mock trạng thái từ Source, chưa giao dịch thật. |
| Acceptance criteria | Không có upload bill; QR minh họa ghi rõ trong demo. Pending không hiện paid; lỗi/return giữ order ID; confirmation chỉ theo source verified. |
| Tests cần bổ sung/chạy | Pending/verified/rejected/unknown/network theo vocab đã duyệt; clipboard không xác nhận tiền. |
| File/port dự kiến | BankTransferSource/Page, payment DTO; Backend đối soát là dependency ngoài FE. |

### P02 - VNPay launch/return/result UI và fixture tests

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ BACKEND CONTRACT + DEEP LINK |
| Dependency | O00/O01; payment attempt URL/status, merchant sandbox plan. |
| Mục tiêu/phạm vi | UI loading/pending/result/cancel/retry theo contract; mock return/status; tiếp theo mới sandbox integration. |
| Acceptance criteria | Return query không tự paid; request đúng order/attempt, resume đọc lại source; retry chỉ khi được cho phép. |
| Tests cần bổ sung/chạy | Return before verify, cancel vs pending, process resume/owner changed/old response, duplicate tap. |
| File/port dự kiến | Payment Source/new VNPay presentation khi P2 đủ; không để secret trong Flutter. |

### P03 - Smoke/API E2E trên Android và Admin Web

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ BACKEND/MÔI TRƯỜNG |
| Dependency | Auth/catalog/orders/payment adapters có dev endpoints; thiết bị/browser khả dụng. |
| Mục tiêu/phạm vi | Chạy sáu flow liên kết với cùng ID qua server; bao gồm return/resume và permission boundaries. |
| Acceptance criteria | Admin tạo/publish, Customer mua, Admin xử lý và Customer reload đúng dữ liệu; có log bằng chứng. Không dùng hai nguồn fixture để ghi E2E PASS. |
| Tests cần bổ sung/chạy | Network interruption, Back/reload, token expiry, idempotency, actual native gallery; snapshot regression. |
| File/port dự kiến | Integration tests và evidence; không deploy production tự động. |

### U01 - Auth + Profile + Address API adapters

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ BACKEND CONTRACT |
| Dependency | Provider/session/profile/address/media contracts; C01/O00 không bắt buộc để bắt đầu auth read. |
| Mục tiêu/phạm vi | Chia Auth, Profile, Address thành ba đợt, giữ Source injection và guards đã nghiệm thu. |
| Acceptance criteria | Identity server ổn định; không fallback mock khi API lỗi; user B không đọc A; address ID/version/default atomic. |
| Tests cần bổ sung/chạy | Session expiry/login cancel, stale request, register conflict, profile/addresses ownership, draft preserve. |
| File/port dự kiến | CustomerAuthSource, feature Sources, session composition; Admin auth riêng. |

### M01 - Media và Review API

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ BACKEND CONTRACT |
| Dependency | U01; storage/upload purpose/media ID và review unique/eligibility. |
| Mục tiêu/phạm vi | Avatar upload và review upload/create tách đợt; giữ 5 ảnh JPG/PNG 5 MiB rule review. |
| Acceptance criteria | Không nhận ảnh phiên cũ; lỗi upload giữ draft; server xác minh order delivered/owner, một lần/order/product. |
| Tests cần bổ sung/chạy | Partial failure/retry/size/format, duplicate review, foreign order, public summary reload. |
| File/port dự kiến | Media adapter, profile/review Sources; không dùng review limits cho Custom/Avatar. |

### X01 - Custom request tối thiểu Customer

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ FIELD RULE/CONTRACT + UI |
| Dependency | SRS UC_US_07; input/ảnh mẫu/ownership; full payment không phải điều kiện tự đặt cho request. |
| Mục tiêu/phạm vi | Chốt form read/create/detail trước, chưa production/payment flow. Dùng mock request IDs/version ổn định. |
| Acceptance criteria | Gửi mô tả/ảnh mẫu hợp lệ tạo request owner; lỗi/cancel giữ draft; không tự tạo catalog product/order/paid. |
| Tests cần bổ sung/chạy | Required data, attachments, duplicate submit, owner/stale response, unpaid request not silently lost theo policy được duyệt. |
| File/port dự kiến | Customer custom feature Source/pages, media contract. |

### X02 - Admin Custom inbox và quote; Customer phản hồi

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ BUSINESS RULE + X01 + UI |
| Dependency | Quote revision/expiry/amount, accept/reject, deposit/full, trigger order/production. |
| Mục tiêu/phạm vi | Inbox/detail trước; quote/edit/accept từng task. Hội thoại hiện có chỉ dùng nếu contract liên kết rõ request ID. |
| Acceptance criteria | Admin nhận đúng request; Customer xem đúng quote version; stale accept bị từ chối; không ghi đè quote đã accept. |
| Tests cần bổ sung/chạy | Cross-user IDs, quote races, source failures, request→order trigger chỉ theo policy. |
| File/port dự kiến | Admin Custom source/pages, Customer quote Source; không suy từ conversation fixture. |

### G01 - FAQ nội dung được duyệt và Chat UI/mock

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | MOCK FE cho states; CHỜ CONTENT/UI cho toàn flow |
| Dependency | FAQ approved, chat history/retention scope, thiết kế chat còn chưa kiểm chứng. |
| Mục tiêu/phạm vi | FAQ content/source riêng; chat composer/list states theo P2; mock reply rõ nguồn, không gọi là Gemini thật. |
| Acceptance criteria | Gửi/cancel/retry không mất draft, owner history, error/fallback rõ; không tự đưa công thức len chưa duyệt. |
| Tests cần bổ sung/chạy | Pending/error/empty/late reply, logout, public FAQ vs private order context. |
| File/port dự kiến | FAQ/chat Source/presentation; không keys, không model call trực tiếp. |

### G02 - Gemini qua NestJS + fallback FAQ

| Trường | Nội dung |
| --- | --- |
| Priority | P1 |
| Sẵn sàng | CHỜ BACKEND CONTRACT |
| Dependency | G01; Gemini server orchestration, rate/error/fallback, data access/privacy. |
| Mục tiêu/phạm vi | Thay Source bằng chat API; FAQ fallback do contract định nghĩa. Calculator chỉ sau công thức riêng được duyệt. |
| Acceptance criteria | Không lộ secret/owner data; timeout/429 có fallback đúng, không tự create order/mark paid; thông tin thiếu không bịa policy. |
| Tests cần bổ sung/chạy | Invalid output/prompt injection/network, source attribution, forbidden financial mutation. |
| File/port dự kiến | NestJS do Backend cung cấp; FE chỉ adapter/state. |

### A05 - Customer management read và Dashboard basic API

| Trường | Nội dung |
| --- | --- |
| Priority | P2 |
| Sẵn sàng | CHỜ BACKEND CONTRACT; scope write CHỜ QUYẾT ĐỊNH |
| Dependency | User/history DTO và metric definitions; read UI hiện có. |
| Mục tiêu/phạm vi | Hai module read tách đợt; không mở lock/roles, không làm dashboard nâng cao. |
| Acceptance criteria | User/order IDs thật, thiếu metadata rõ; metric đúng nghĩa/kỳ; không ghép theo tên, không tự ngưỡng low-stock. |
| Tests cần bổ sung/chạy | Read filters/page/empty/error + identity mapping; unauthorized access. |
| File/port dự kiến | AdminCustomersSource/DashboardSource adapters. |

### A06 - Moderation cơ bản nếu xác nhận cần cho MVP

| Trường | Nội dung |
| --- | --- |
| Priority | P2 |
| Sẵn sàng | CHỜ QUYẾT ĐỊNH + CONTRACT |
| Dependency | Scope công khai/chờ duyệt/hide và quyền actor, review IDs chung. |
| Mục tiêu/phạm vi | Giữ readonly hiện có; chỉ thêm hide/basic response nếu được duyệt riêng. |
| Acceptance criteria | Không sửa review owner/rating; Customer public projection phản ánh server; không nâng cấp moderation toàn diện. |
| Tests cần bổ sung/chạy | Allowed/denied hide, stale state, cross-app DTO projection. |
| File/port dự kiến | AdminReviewsSource/commands; không cần nâng cao trong MVP. |

## 4. Những card phải tách tiếp khi triển khai

Các card tổng hợp trên là dependency packages. Không code hết một package trong một thay đổi:

- **U01a Auth → U01b Profile → U01c Address**: mỗi Source/API adapter được nghiệm thu riêng.
- **A03a Category → A03b Variant**: không làm đồng thời inventory ledger.
- **O02**: mỗi transition được duyệt là một task riêng; không thêm tất cả trạng thái vào dropdown rồi coi workflow đã đúng.
- **X02a Custom inbox/detail → X02b tạo quote revision → X02c Customer xem/accept/reject**; trigger tạo đơn/sản xuất là gate riêng.
- **M01a Avatar upload → M01b review attachments/create**; không áp chung giới hạn file khi chưa có rule.
- **G01a FAQ content/state → G01b chat composer/history mock**; Gemini integration chỉ ở G02.
- **A05a Customers read → A05b Dashboard basic**; lock user và quản lý role không được gộp vào read task.

Mỗi phần có acceptance và tests của phần đó; các card phụ thuộc không được đánh dấu complete vì phần trước đã có UI.

## 5. Sáu acceptance scenarios tích hợp

Các scenario sau nghiệm thu ở P03 sau các module/Backend tương ứng, không phải chức năng đã chạy:

| Scenario | Dependencies | Acceptance |
| --- | --- | --- |
| Admin product → Customer purchase | C01/A01/A02/A03 + catalog/cart/quote/order APIs | Một product/variant published có ID thống nhất; Customer đọc đúng và mua đúng; ẩn/ngừng bán bị chặn đúng policy |
| Customer COD → Admin | U01/O00/O01 + create order API | Cùng order ID, owner, lines/số tiền snapshot; retry không nhân bản; Admin không đọc nguồn fixture riêng |
| Admin transition → Customer tracking | O02 + order events/status APIs | Allowed transition thành công, Customer reload thấy đúng event/time; unauthorized/stale không mutate |
| Publish voucher → Customer apply | V02–V04 + Admin voucher publish command | Campaign công khai dùng chung ID, không phát từng tài khoản; source trả eligibility đúng context; usage riêng không lộ giữa user |
| Pay → payment/order status | P01/P02 + bank/VNPay Backend sandbox | Xác minh server trước paid; return/cancel/pending/duplicate callbacks không tự giao/thu tiền hai lần |
| Custom submit → quote response | X01/X02 + Custom/media APIs | Request owner ổn định, Admin phản hồi đúng revision; Customer không accept bản giá cũ; payment/production chỉ theo policy |

Test harness dùng cùng DTO fixtures có ích để kiểm mapping nhưng không thay sáu scenario chạy qua server. Không tạo “shared mock RAM” để tuyên bố mobile và admin web đã đồng bộ runtime.

## 6. Các câu hỏi chốt trước từng module

Không yêu cầu duyệt lại no-merge, owner, selected checkout, voucher công khai, review eligibility/ảnh hay stack đã chốt.

1. **Voucher:** schema campaign/publication và lifecycle; min/cap/rounding/expiry/timezone/stack/quota; usage trigger; Guest được xem campaign hay vẫn cần Auth; Apply từ Wallet không có giỏ sẽ đi đâu?
2. **Catalog:** đơn vị stock Product hay SKU, variant IDs/default options, media, field validation; archive/delete sản phẩm đã có order.
3. **Order/inventory:** allowed transitions và actor; thời điểm reserve/deduct/release; thu tiền COD tách delivered; recover request/giỏ chưa rõ kết quả. P0-04 4C vẫn dừng.
4. **Payment:** create timing, instructions/reference, merchant sandbox/deep link, pending/retry/expiry/mismatch. Bank đối soát từ đâu và ai có quyền xác nhận?
5. **Custom:** form/attachment limits, quote version/expiry, accept/reject, full/deposit, khi nào tạo order hoặc bắt đầu sản xuất?
6. **Chatbot:** FAQ approved và nguồn catalog được phép đọc; history/privacy/fallback/handoff; calculator formula là gate riêng.
7. **Auth/media:** provider, verification/reset/session expiry, permissions; storage/retention/URL access. Không dùng generation Flutter làm authority.
8. **Admin customers/moderation:** tối thiểu MVP chỉ read hay cần lock/hide; quyền và tác động phiên/đơn là gì?
9. **Legacy Guest pending:** giữ hay loại bỏ các container được để chờ merge trong 4A sau quyết định no-merge? Không tự xóa state hoặc tiếp tục merge để “dọn” vấn đề.

Backend design dùng các mã D01–D15 riêng, cần sửa register sau khi các câu hỏi được giải quyết; không lẫn với D01–D12 Guest/Session.

## 7. Không cần làm / không tự khôi phục trong MVP này

| Nội dung | Trạng thái |
| --- | --- |
| Auto Guest/account merge 4B | Không triển khai theo quyết định mới |
| P0-04 4C | Dừng; yêu cầu recovery Backend phải được thống nhất riêng, không tự tiếp tục |
| Blog, digital products/library/digital checkout | Đã loại; không phục hồi từ SRS/draft cũ |
| Abandoned cart/remarketing/phát voucher từng account bắt buộc | Không nằm trong luồng voucher công khai đã chốt |
| Upload bill/duyệt ảnh để xác nhận tiền | Đã loại; Custom image/review/avatar không phải biên lai |
| Dashboard biểu đồ/phân tích nâng cao | Đã loại; chỉ basic snapshot/read nếu giữ |
| Customer cancel button | Đã yêu cầu bỏ; không khôi phục theo UC_US_06 lịch sử |
| Refund/returns/deposit phức tạp, nhiều kho, realtime/handoff nâng cao, favorite list mới, role editor đầy đủ | Không tự thêm; chỉ thực hiện phần nào được nhóm đưa vào MVP rõ ràng |

## 8. Đề xuất bước tiếp theo để nghiệm thu

**Task hiện tại: nghiệm thu R1 - command bỏ voucher đúng session/revision/target, chống pending response khôi phục selection.** Chưa có UI gọi command, chưa re-quote/pricing hoặc mở COD mới. Không tự chuyển R2–R7; tiếp tục các gate trong readiness sau khi được giao riêng.

R00 có thể thực hiện như đợt tài liệu riêng để tránh backlog cũ tiếp tục đề xuất merge. Chưa thực hiện các task này trong audit.

Bộ kiểm tra audit gốc: 658 PASS; V02a: 669; V03a: 684; V03b: 714; V04a: 737. Sau R1: **762 PASS** (Customer 451, Shared 130, Admin 181), analyzer sạch cả ba project, 100 golden baseline không đổi. Đây là kiểm chứng mock/hồi quy, không phải API/Gemini/payment integration.
