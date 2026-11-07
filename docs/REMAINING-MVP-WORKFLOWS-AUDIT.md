# LENLAB - Remaining MVP Business Workflows Audit

Ngày audit: 05/11/2026. Chỉ khảo sát source/tests và tạo hai tài liệu bàn giao; không triển khai tính năng, sửa source/test/Figma/Backend/Database.

> Cập nhật sau audit: [V02a](P1-01-V02A.md) đã triển khai nguồn đọc campaign công khai A/B, tách usage theo user ID; nhận định “wallet A-only” bên dưới là baseline trước V02a. Apply/eligibility và liên thông Admin publish vẫn chưa được triển khai. Không tự suy các workflow khác đã hoàn tất.

## Kết luận

Customer có luồng mua COD hoạt động với mock và các guard/validation đã nghiệm thu. Phần lớn Admin là các màn đọc có tương tác tìm/lọc/phân trang; không phải CRUD đã vận hành. **Cả sáu luồng Customer–Admin được yêu cầu kiểm tra đều chưa liên thông đầu cuối.** Custom Customer và Chatbot Gemini chưa được triển khai ngoài placeholder/FAQ tĩnh.

Hai khác biệt chính sách cần ưu tiên ghi nhận:

- Không tự động merge Guest/account đã được chốt. P0-04 dừng ở 4A; các ghi chú “chờ merge 4B” trong docs/source cũ là lịch sử, không phải việc tiếp theo được phép làm.
- Voucher là campaign do Admin tạo và công khai, Customer tự xem/sử dụng; không cần Admin phát riêng. Mock wallet hiện chỉ trả fixture cho A, chưa phản ánh yêu cầu mới này. Tuy nhiên, trạng thái sử dụng cá nhân vẫn cần owner nếu có; “công khai campaign” không có nghĩa công khai lịch sử dùng mã của mọi khách.

Không có workflow nào trong audit được đánh giá là đã tích hợp API chỉ vì UI/mock hoạt động. Mock source, tests và code client không thay quyền xác thực hoặc giao dịch có thẩm quyền của Backend.

## 1. Căn cứ và phương pháp

Đã đọc/đối chiếu:

- [WORKFLOW-SCOPE](WORKFLOW-SCOPE.md), [cleanup](FE-SCOPE-CLEANUP.md), [Cart Business Rules](P0-04-CART-BUSINESS-RULES.md).
- [P0-04 đợt 1](P0-04-BATCH-1.md), [đợt 2](P0-04-BATCH-2.md), [đợt 3](P0-04-BATCH-3.md), [4A](P0-04-BATCH-4A.md), [P1-01/V01](P1-01-V01.md).
- Backend design: [ADR/approval register](backend-design/PHASE-1.md), [ERD/state](backend-design/DATA-MODEL.md), [API draft](backend-design/API-CONTRACT.md), [integration draft](backend-design/FLUTTER-INTEGRATION.md).
- LENLAB_SRS.docx (`docs/LENLAB_SRS.docx`; local-only; not distributed with this repository): FR_US/FR_AD, UC_US_01–09, UC_AD_01–09, BR/PAY/NFR; LENLAB_UI_UX.docx (`docs/LENLAB_UI_UX.docx`; local-only; not distributed with this repository): UI-01–16, navigation và ngoại lệ. Các phần đã loại không tự trở lại vì còn trong bản dự thảo này.
- Source composition roots, route guards, Source interfaces/implementations, Store mutations, widgets có callback bị khóa/thông báo và các tests được ghi trong từng workflow.

Thứ tự ưu tiên: yêu cầu audit hiện tại và các quyết định mới nhất → quyết định Mobile còn hiệu lực → scope cleanup → các phần tài liệu không mâu thuẫn. Backend design vẫn **PROPOSED**; các endpoint/state/schema nêu dưới đây là nhu cầu/đề xuất contract, chưa phải API đã sẵn sàng.

Các D01–D12 Guest/Session không đồng nghĩa các D01–D15 trong approval register thiết kế Backend: hai nhóm có nội dung và phạm vi khác nhau.

### Phân loại

- **COMPLETE WITH MOCK**: tương tác, validation và trạng thái của phần được ghi rõ đã có; vẫn chỉ RAM/fixtures.
- **UI ONLY / READ MOCK**: xem được hoặc có nút/field, không có command nghiệp vụ tương ứng.
- **PARTIAL**: có phần hoạt động nhưng workflow còn bước thiếu hoặc dữ liệu mẫu không đủ.
- **NOT IMPLEMENTED**: chưa có luồng thực thi, kể cả có PendingPage.
- **BLOCKED BY BACKEND**: API/provider hoặc xác minh có thẩm quyền cần bên Backend; không biến thành claim đã tích hợp.
- **EXCLUDED / DEFERRED**: không tự đưa vào backlog phải code.

Priority là đề xuất theo rủi ro: P0 bảo toàn scope/tiền/owner và chốt contract quan trọng; P1 core MVP; P2 hoàn thiện sau đường mua hàng chính. Không phải cấp phép triển khai.

## 2. Ma trận workflow

Mỗi bảng ghi đủ UI, interaction, mock, tests, Backend dependency, rule còn thiếu và khuyến nghị. Tên test không có hậu tố được hiểu là file `.dart` trong `apps/customer/test` hoặc `apps/admin/test` theo đối tượng; chữ “shared” chỉ `packages/lenlab_shared/test`. Danh sách là bằng chứng tiêu biểu, không phải chứng nhận coverage phần trăm.

### C01 - Authentication / logout

| Trường | Nội dung |
| --- | --- |
| Business workflow | Authentication / logout |
| Use Case | UC_US_01; UI-03 |
| Customer/Admin | Customer |
| Trạng thái | COMPLETE WITH MOCK (login/register/logout); PARTIAL (auth mở rộng) |
| UI | AuthPage, login/register layout; customer_session_gate |
| Interaction | Validate, login/register riêng, A/B, return intent, lỗi/retry; Google/quên mật khẩu chỉ notice. |
| Mock/Data Source | CustomerAuthSource inject, identity/generation RAM; không auth/token thật. |
| Tests | customer_test, register_test, customer_session_test, customer_route_guards_test; shared customer_session_test. |
| Backend dependency | Login/register/me/logout/reset; xác thực, refresh/revocation và principal server. |
| Missing rules | Provider/verification/reset/remember-me; không lấy mock password làm policy. |
| Priority | P1 |
| Recommendation | Giữ guard; thống nhất auth contract rồi thay Source, không viết lại UI. |

### C02 - Profile và avatar

| Trường | Nội dung |
| --- | --- |
| Business workflow | Profile và avatar |
| Use Case | UC_US_02; UI-11 |
| Customer/Admin | Customer |
| Trạng thái | COMPLETE WITH MOCK cho trường đã chốt; PARTIAL cho toàn tài khoản |
| UI | ProfilePage, ProfileEditorPage |
| Interaction | Sửa tên/phone/gender/birthday, chọn/preview/lưu ảnh local; email khóa. Đổi mật khẩu chưa có. |
| Mock/Data Source | Profile Source/Editor; account owner RAM, stamp chống request/picker cũ. |
| Tests | profile_test, profile_editor_test, avatar_test, account_async_isolation_test, account_widget_isolation_test. |
| Backend dependency | Profile read/update/version; media upload/read; đổi mật khẩu sau contract. |
| Missing rules | Avatar format/size/retention server, recovery sau restart; phương thức đổi mật khẩu. |
| Priority | P1 |
| Recommendation | Tích hợp profile/media riêng; không áp giới hạn ảnh review cho avatar. |

### C03 - Sổ địa chỉ và địa chỉ checkout

| Trường | Nội dung |
| --- | --- |
| Business workflow | Sổ địa chỉ và địa chỉ checkout |
| Use Case | FR_US_07; UC_US_02/05; UI-11/07 |
| Customer/Admin | Customer |
| Trạng thái | COMPLETE WITH MOCK trong quy tắc đã duyệt |
| UI | AddressBook/Editor, checkout AddressPage |
| Interaction | CRUD mock, xác nhận xóa, đổi mặc định, validation; chặn xóa default trước khi đổi. |
| Mock/Data Source | Owner guards/stamp; địa chỉ nhận checkout tách snapshot đơn. Region dataset mẫu. |
| Tests | address_actions_test, address_book_test, address_editor_test, address_test; shared customer_ownership_test. |
| Backend dependency | Address ID/version, CRUD/default atomic, vùng giao hàng và phí. |
| Missing rules | Nguồn địa giới/phí thật; không tự cập nhật snapshot đơn khi sửa sổ. |
| Priority | P1 |
| Recommendation | Giữ interaction; mapper ID/version và nguồn địa giới sau contract. |

### C04 - Home và điểm vào catalog

| Trường | Nội dung |
| --- | --- |
| Business workflow | Home và điểm vào catalog |
| Use Case | UC_US_03; UI-01/02 |
| Customer/Admin | Customer |
| Trạng thái | COMPLETE WITH MOCK cho browsing |
| UI | HomePage, home_content và featured widgets |
| Interaction | Menu, search icon, danh mục, product CTA/related tới ID chuẩn. |
| Mock/Data Source | Home metadata/layout fixture; sản phẩm resolve catalog chuẩn P0-02. Không CMS thật. |
| Tests | home_test, product_identity_test, customer_navigation_test, visual_test. |
| Backend dependency | Published catalog/featured content API nếu nội dung cần quản trị. |
| Missing rules | Nội dung thương hiệu/campaign trước phát hành; không phục hồi Blog. |
| Priority | P2 |
| Recommendation | Giữ ID chuẩn; nối featured data khi có API, không thêm Home product giả. |

### C05 - Catalog / Search / Filter / Pagination

| Trường | Nội dung |
| --- | --- |
| Business workflow | Catalog / Search / Filter / Pagination |
| Use Case | UC_US_03; UI-04 |
| Customer/Admin | Customer |
| Trạng thái | COMPLETE WITH MOCK cho tìm tên/danh mục/sort/page; PARTIAL cho lọc giá |
| UI | CatalogPage và category/filter sheet |
| Interaction | Tìm tên local, chọn category, sort giá, phân trang/reset, loading/empty/error/retry. |
| Mock/Data Source | repository.products tải danh sách; lọc/sort client. Chưa filter khoảng giá/server query. |
| Tests | catalog_test, customer_test, scope_cleanup_test, visual_test. |
| Backend dependency | Query/detail/categories, filter/sort/page metadata và tổng kết quả. |
| Missing rules | Khoảng giá/bộ lọc được duyệt và search semantics; không tự thêm control ngoài P2. |
| Priority | P1 |
| Recommendation | Lập contract query; giữ thao tác local; bổ sung khoảng giá chỉ khi scope/UI đủ rõ. |

### C06 - Product Detail / Related / Variant / Add cart

| Trường | Nội dung |
| --- | --- |
| Business workflow | Product Detail / Related / Variant / Add cart |
| Use Case | UC_US_03/04; UI-05 |
| Customer/Admin | Customer |
| Trạng thái | COMPLETE WITH MOCK cấp Product; PARTIAL SKU |
| UI | ProductDetailRoute/Page, related, MerinoVariantSheet |
| Interaction | Resolve ID chuẩn, fallback missing/hidden/unavailable, thêm hàng; Merino chọn màu/size, bounds. |
| Mock/Data Source | Catalog chuẩn P0-02; Product snapshot; variant hiện là chuỗi, stock cấp Product. |
| Tests | product_identity_test, product_detail_test, variant_sheet_test; shared cod_validation_test. |
| Backend dependency | Product/variant ID thật, published, availability/stock, media. |
| Missing rules | SKU/variant mapping và tồn theo biến thể; không tự suy SKU từ label. |
| Priority | P1 |
| Recommendation | Chốt mapping Product/Variant trước adapter; giữ P0-02/P0-03. |

### C07 - Favorites

| Trường | Nội dung |
| --- | --- |
| Business workflow | Favorites |
| Use Case | Hỗ trợ hiện có; chưa có UC độc lập được chốt |
| Customer/Admin | Customer |
| Trạng thái | COMPLETE WITH MOCK cho toggle; NOT IMPLEMENTED danh sách riêng |
| UI | Icon tim Product Detail; không route danh sách favorites |
| Interaction | Login guard và toggle RAM theo user; không replay private action sau Auth. |
| Mock/Data Source | Account favorites set, session-bound view. |
| Tests | product_detail_test; shared customer_ownership_test. |
| Backend dependency | Read/add/remove favorites nếu nhóm giữ trong API MVP. |
| Missing rules | Màn danh sách/đồng bộ đa thiết bị chưa được duyệt; không tự mở rộng. |
| Priority | P2 |
| Recommendation | Giữ toggle; không coi thiếu một trang favorites là mặc định phải thêm MVP. |

### C08 - Guest / account cart, checkbox, coupon scope

| Trường | Nội dung |
| --- | --- |
| Business workflow | Guest / account cart, checkbox, coupon scope |
| Use Case | UC_US_04; UI-06; P0-04 4A |
| Customer/Admin | Customer |
| Trạng thái | COMPLETE WITH MOCK cho 4A; legacy pending state còn |
| UI | CartPage và Store cart containers |
| Interaction | Guest sửa giỏ; account A/B riêng; logout Guest mới; checkbox riêng, coupon không tự áp; Auth trước checkout. |
| Mock/Data Source | RAM; CartLine snapshots. _pendingGuestCarts vẫn giữ data theo thiết kế cũ, không có logic merge. |
| Tests | cart_test, cart_session_isolation_test; shared customer_cart_isolation_test, customer_guards_test. |
| Backend dependency | Account cart CRUD/version; Guest persistence/cross-device không triển khai mặc định. |
| Missing rules | Không auto merge đã chốt. Retention/xử lý legacy Guest pending chưa chốt; không tự xóa. |
| Priority | P0 cho ghi nhận chính sách; P1 cho API |
| Recommendation | Ngừng 4B/4C; thống nhất docs và cách xử lý pending legacy trước cleanup, không sửa hành vi 4A trong audit. |

### C09 - Checkout / Order Review / totals

| Trường | Nội dung |
| --- | --- |
| Business workflow | Checkout / Order Review / totals |
| Use Case | UC_US_05; UI-07 |
| Customer/Admin | Customer |
| Trạng thái | COMPLETE WITH MOCK theo pricing fixture; PARTIAL production |
| UI | AddressPage → OrderReviewPage → PaymentMethodPage |
| Interaction | Địa chỉ/note, selected items, quote loading/error/retry; recalculation khi dữ liệu thay đổi. |
| Mock/Data Source | OrderReviewSource nhận client subtotal/discount/address; shipping 30.000đ mẫu; không quote ID/version. |
| Tests | address_test, order_review_test, payment_method_test, cart_discount_display_test. |
| Backend dependency | Authoritative checkout quote, shipping choice/fee, policy/version/expiry. |
| Missing rules | Shipping/tax/phụ phí; giá trị fixture không thành policy. |
| Priority | P1 |
| Recommendation | Giữ layout; mở rộng input qua adapter quote; không chỉ đổi URL source. |

### C10 - Customer voucher công khai / apply

| Trường | Nội dung |
| --- | --- |
| Business workflow | Customer voucher công khai / apply |
| Use Case | UC_US_05; UI-07; liên quan UC_AD_05 |
| Customer/Admin | Customer |
| Trạng thái | UI ONLY cho apply; PARTIAL mock read; V01 COMPLETE |
| UI | VoucherPage, CartVoucher, CartSummary |
| Interaction | Wallet loading/empty/error/retry, copy code; Apply/Use chỉ notice; Cart chưa mở nhập mã. |
| Mock/Data Source | Wallet fixture chỉ trả A (khác quyết định công khai mới). LEN20/card 50K không nối LEN50; V01 label đúng selected discount. |
| Tests | voucher_test, cart_discount_display_test, account_sources_ownership_test; tests hiện có xác nhận không apply. |
| Backend dependency | Published campaign catalog chung; eligibility/quote; usage per-user nếu rule cần. |
| Missing rules | Min/cap/expiry/timezone/stack/quota/rounding; ý nghĩa Apply ở Wallet khi chưa có giỏ. Không cần Admin phát riêng đã chốt. |
| Priority | P1 |
| Recommendation | Tách public campaign khỏi usage cá nhân; không nhân bản voucher cho từng user; xem roadmap V02–V04. |

### C11 - Đặt COD và receipt

| Trường | Nội dung |
| --- | --- |
| Business workflow | Đặt COD và receipt |
| Use Case | UC_US_05; UI-07/10 |
| Customer/Admin | Customer |
| Trạng thái | COMPLETE WITH MOCK trong phiên; PARTIAL detached cart |
| UI | PaymentMethodPage → CodSuccessPage/receipt |
| Interaction | Guard auth/owner, double-submit, revalidate giá/tồn/totals, snapshot, chỉ xử lý dòng mua, lỗi giữ draft. |
| Mock/Data Source | CodOrderSource + P0-03 validator; detached order về đúng lịch sử, giỏ chưa reconcile; không trừ tồn. |
| Tests | cod_checkout_test, cod_validation_test, product_identity_test; shared cod_order_test, cod_validation_test, account_cod_isolation_test. |
| Backend dependency | Create/get order, idempotency, stock transaction, quote validation. |
| Missing rules | Inventory lifecycle/thu tiền COD; recovery giỏ detached chưa hoàn thành và 4C đang dừng. |
| Priority | P0 cho contract recovery; P1 integration |
| Recommendation | Không tuyên bố D10 hoàn tất cả giỏ; Backend quyết định/reconcile sau, không lén làm 4C. |

### C12 - Chuyển khoản ngân hàng

| Trường | Nội dung |
| --- | --- |
| Business workflow | Chuyển khoản ngân hàng |
| Use Case | UC_US_05; PAY-01/04; UI-08 |
| Customer/Admin | Customer |
| Trạng thái | UI + PARTIAL MOCK PREVIEW |
| UI | BankTransferPage/QR/details |
| Interaction | Xem tiền/thông tin mẫu, copy, loading/error/retry. Không tạo order/transaction hoặc xác minh tiền. |
| Mock/Data Source | MockBankTransferSource chỉ preview; QR/tài khoản minh họa. |
| Tests | bank_transfer_test (Customer/Shared). |
| Backend dependency | Create pending order/payment, instructions/reference thật, read status, bank reconciliation. |
| Missing rules | Ngân hàng/nguồn đối soát, số tiền lệch, pending/expiry/retry; không dùng ảnh. |
| Priority | P1 |
| Recommendation | Contract trước; không dùng preview hoặc copy thành bằng chứng thanh toán. |

### C13 - VNPay / return / resume

| Trường | Nội dung |
| --- | --- |
| Business workflow | VNPay / return / resume |
| Use Case | UC_US_05; PAY-02/03/05; UI-09 |
| Customer/Admin | Customer |
| Trạng thái | NOT IMPLEMENTED / BLOCKED BY BACKEND |
| UI | Chưa route/provider flow VNPay Customer |
| Interaction | Chưa mở phiên, return/resume, polling/read status; không có success thật. |
| Mock/Data Source | Chưa PaymentSource/API adapter. |
| Tests | Không có test VNPay integration; scope/legacy removal tests không thay thế. |
| Backend dependency | Create attempt/payment URL; verify checksum/amount/reference server; read pending/result; idempotency. |
| Missing rules | Merchant/sandbox, deep link, timeout/retry/expiry và payment/order vocabulary. |
| Priority | P1 |
| Recommendation | Duyệt contract rồi làm UI states/fixture tests; sandbox là đợt riêng. |

### C14 - Order History / Detail / Tracking

| Trường | Nội dung |
| --- | --- |
| Business workflow | Order History / Detail / Tracking |
| Use Case | UC_US_06; UI-10 |
| Customer/Admin | Customer |
| Trạng thái | COMPLETE WITH MOCK cho đọc; PARTIAL tracking vận hành |
| UI | OrderListPage/OrderDetailPage/timeline |
| Interaction | Lọc state, reload, đúng ID/owner, fallback metadata, timeline theo snapshot. |
| Mock/Data Source | OrderList/Detail source chung account; không trạng thái từ shop hoặc carrier. |
| Tests | order_list_test, order_detail_test, customer_route_guards_test; shared order_list/detail/customer_ownership. |
| Backend dependency | List/detail/event timeline/status từ server; cập nhật sau Admin transition. |
| Missing rules | Mapping statuses với Admin/payment/carrier; nhãn thiếu ngày không giả dữ liệu. |
| Priority | P1 |
| Recommendation | Thống nhất vocabulary; read/reload trước, realtime không mặc định bắt buộc. |

### C15 - Customer Cancel Order

| Trường | Nội dung |
| --- | --- |
| Business workflow | Customer Cancel Order |
| Use Case | UC_US_06 A1 lịch sử |
| Customer/Admin | Customer |
| Trạng thái | EXCLUDED BY CONFIRMED DECISION |
| UI | Không nút hủy trong detail |
| Interaction | Không có thao tác hủy Customer; đúng quyết định bỏ nút. |
| Mock/Data Source | Không có cancel command; không reserve/refund stock. |
| Tests | order_detail_test kiểm tra không có Hủy; không phải thiếu test hủy. |
| Backend dependency | Không mở endpoint cancel Customer trong kế hoạch FE hiện tại. |
| Missing rules | Không tự dùng UC cũ để khôi phục; thay scope cần quyết định mới. |
| Priority | Không backlog MVP |
| Recommendation | Chỉ ghi chênh lệch tài liệu cũ; không thêm nút/hoàn kho. |

### C16 - Reorder / Mua lại

| Trường | Nội dung |
| --- | --- |
| Business workflow | Reorder / Mua lại |
| Use Case | UC_US_06 A2; quyết định Mobile thay flow cũ |
| Customer/Admin | Customer |
| Trạng thái | COMPLETE WITH MOCK |
| UI | Order list delivered → BuyAgain dialog → Product Detail |
| Interaction | Đúng đơn owner; tra catalog hiện tại, một/nhiều sản phẩm, unavailable/error/retry; khách tự chọn mua. |
| Mock/Data Source | CatalogBuyAgainSource, không tự add dòng/giá/quantity đơn cũ. |
| Tests | buy_again_test, product_identity_test; shared order tests. |
| Backend dependency | Order ownership + current product/variant availability. |
| Missing rules | SKU mapping sau API; không tự giảm lượng hay khôi phục cách auto-add cũ. |
| Priority | P1 integration; không cần viết lại mock |
| Recommendation | Thay source bằng API, giữ trải nghiệm đã duyệt. |

### C17 - Review sau mua / ảnh / đọc công khai

| Trường | Nội dung |
| --- | --- |
| Business workflow | Review sau mua / ảnh / đọc công khai |
| Use Case | UC_US_08; FR_US_12; UI-13 |
| Customer/Admin | Customer |
| Trạng thái | COMPLETE WITH MOCK; BLOCKED API upload/uniqueness |
| UI | Review list/filter và PostPurchaseReviewPage từ delivered order |
| Interaction | 1–5 sao, text optional, tối đa 5 JPG/PNG 5 MiB/ảnh; preview/remove; một lần/order/product/owner. |
| Mock/Data Source | Public review collection + owner eligibility/stamp; ảnh RAM chưa upload; Admin review source riêng. |
| Tests | post_purchase_review_test, review_photos_test, reviews_test, rating_consistency_test; shared review/photo/ownership. |
| Backend dependency | Review eligibility/create/list/summary + media; server unique constraint và moderation. |
| Missing rules | Storage/retention; rule ảnh và review một lần đã chốt, không hỏi lại. |
| Priority | P1 |
| Recommendation | Giữ draft/errors; tích hợp media/review sau contract; không coi local bytes là upload. |

### C18 - Custom Order Customer

| Trường | Nội dung |
| --- | --- |
| Business workflow | Custom Order Customer |
| Use Case | UC_US_07; FR_US_09; UI-12 |
| Customer/Admin | Customer |
| Trạng thái | NOT IMPLEMENTED, placeholder UI |
| UI | /customs → PendingPage |
| Interaction | Chưa gửi mô tả/ảnh/yêu cầu, xem quote/accept/reject hoặc tiến độ. |
| Mock/Data Source | Store chỉ có owner-scoped CustomRequest fixtures; không có create Source/workflow. |
| Tests | scope_cleanup_test/ownership chỉ kiểm tra giữ route/data; không có E2E Custom submit. |
| Backend dependency | Create/read request, media, quote revision/accept/reject, Admin responses. |
| Missing rules | Trường bắt buộc/ảnh, full/deposit, trigger tạo đơn/sản xuất, quote expiry/reject. |
| Priority | P1 |
| Recommendation | Giữ Custom trong MVP; chốt bước đầu request riêng rồi làm từng phần, không suy dữ liệu mẫu là đã vận hành. |

### C19 - Chatbot Gemini / FAQ fallback / ước tính len

| Trường | Nội dung |
| --- | --- |
| Business workflow | Chatbot Gemini / FAQ fallback / ước tính len |
| Use Case | UC_US_09; FR_US_08/10; UI-12/15 |
| Customer/Admin | Customer |
| Trạng thái | NOT IMPLEMENTED chat; PARTIAL FAQ tĩnh |
| UI | /chat → PendingPage; /faq, /support → FaqPage |
| Interaction | FAQ tìm/lọc/accordion hoạt động; đáp án còn mẫu/thiếu. Không gửi chat/Gemini/calculator. |
| Mock/Data Source | FaqSource local; không chat repository/history/API. Support ID đơn chỉ ngữ cảnh, không gửi hỗ trợ. |
| Tests | faq_test, scope_cleanup_test; không test Gemini/chat stream/fallback thực. |
| Backend dependency | NestJS chat/FAQ; Gemini server-side, history ownership; rate/error/fallback. |
| Missing rules | Nội dung FAQ duyệt, giới hạn chat/privacy và công thức ước tính; không tự thêm calculator không có công thức. |
| Priority | P1 core chat; P2 formula chờ quyết định |
| Recommendation | FAQ approved → chat UI/mock → API Gemini; không gọi FAQ search là AI. |

### A01 - Admin auth / shell / RBAC

| Trường | Nội dung |
| --- | --- |
| Business workflow | Admin auth / shell / RBAC |
| Use Case | NFR_06; các UC_AD |
| Customer/Admin | Admin |
| Trạng thái | COMPLETE WITH MOCK session; NOT IMPLEMENTED RBAC thật |
| UI | AdminLoginPage, AdminAccessPage, shell/sidebar |
| Interaction | Login/logout, route guard/direct URL/Back; phiên Admin riêng Customer. |
| Mock/Data Source | MockAdminAuthSource + AdminSession; AdminUser không capabilities/permission matrix. |
| Tests | admin_login_test, admin_session_test, admin_shell_test. |
| Backend dependency | Admin principal/permissions, session expiry/revocation; authorization server. |
| Missing rules | RBAC chi tiết/ai chuyển đơn, thu tiền, quản trị voucher. |
| Priority | P1 |
| Recommendation | Chốt permission matrix, mapper session; không coi sidebar ẩn là phân quyền. |

### A02 - Dashboard cơ bản

| Trường | Nội dung |
| --- | --- |
| Business workflow | Dashboard cơ bản |
| Use Case | FR_AD_10 (phần cơ bản còn giữ) |
| Customer/Admin | Admin |
| Trạng thái | COMPLETE WITH MOCK READ |
| UI | Dashboard content/metrics/product previews |
| Interaction | Loading/empty/error/retry, layout responsive; không số liệu live từ orders. |
| Mock/Data Source | DashboardSource snapshot cố định, previews không nối SKU. Biểu đồ nâng cao đã loại. |
| Tests | dashboard_test, admin_visual_test. |
| Backend dependency | Basic aggregate summary theo kỳ/định nghĩa chỉ số nếu cần. |
| Missing rules | Doanh thu tính lúc nào, đơn mới/kỳ/low-stock threshold; không suy từ badge fixture. |
| Priority | P2 |
| Recommendation | Nối số liệu cơ bản sau orders; không phục hồi thống kê nâng cao. |

### A03 - Product Management

| Trường | Nội dung |
| --- | --- |
| Business workflow | Product Management |
| Use Case | UC_AD_01; FR_AD_02 |
| Customer/Admin | Admin |
| Trạng thái | COMPLETE WITH MOCK READ; CRUD NOT IMPLEMENTED |
| UI | Danh sách products |
| Interaction | Tìm tên/SKU, category/visibility filter, paging, retry; Add/Edit/Delete bị khóa. |
| Mock/Data Source | AdminProductsSource chỉ fetch, fixture immutable riêng Customer catalog. |
| Tests | admin_products_test (bao gồm readonly), admin_visual_test. |
| Backend dependency | Admin product read/create/update/archive/media/version; Customer published projection. |
| Missing rules | Các trường/validation, archive/delete sản phẩm đã có đơn; media và quyền. |
| Priority | P1 |
| Recommendation | Chốt DTO rồi form create/edit mock nhỏ; chưa bật ghi vào backend. |

### A04 - Category / Variant / Inventory

| Trường | Nội dung |
| --- | --- |
| Business workflow | Category / Variant / Inventory |
| Use Case | UC_AD_01; FR_AD_02; NFR_11 |
| Customer/Admin | Admin |
| Trạng thái | UI DISPLAY ONLY / CRUD NOT IMPLEMENTED |
| UI | Category filter, variant string và stock cột trong product list |
| Interaction | Chỉ lọc/xem, chưa category/variant editors hay stock adjustment/history. |
| Mock/Data Source | Enum 2 categories, SKU/stock fixture; không inventory command hoặc reservation. |
| Tests | admin_products_test chỉ read/filter; shared cod_validation không kiểm inventory ledger. |
| Backend dependency | Categories/variants IDs, balances, adjustment/version, reserve/issue/release server. |
| Missing rules | SKU/schema, inactive variant, movement reasons, reserve/deduct/refund trigger. |
| Priority | P1 |
| Recommendation | Contract IDs trước CRUD; không cộng/trừ tồn từ client hoặc tự đặt ngưỡng low-stock. |

### A05 - Order Management / transition / payment view

| Trường | Nội dung |
| --- | --- |
| Business workflow | Order Management / transition / payment view |
| Use Case | UC_AD_02; FR_AD_03 |
| Customer/Admin | Admin |
| Trạng thái | COMPLETE WITH MOCK READ; writes NOT IMPLEMENTED |
| UI | Orders list/detail |
| Interaction | Search/status/payment filter/page, đúng ID/Back; Duyệt/Hủy/Sửa khóa; timeline/payment metadata thiếu có fallback. |
| Mock/Data Source | AdminOrdersSource fetch/detail, immutable fixture ORD-*khác WOOL-* Customer. |
| Tests | admin_orders_test, admin_order_detail_test, admin_order_navigation coverage trong detail test. |
| Backend dependency | Shared order DTO/list/detail/events, allowed transitions/version; payment state và bank reconciliation. |
| Missing rules | Transition matrix/actors, COD collection/stock, cancel Admin nếu nhóm duyệt. |
| Priority | P1 |
| Recommendation | Read contract + field mapping trước, transition từng action sau policy; không gộp order status với paid. |

### A06 - Admin tạo/công khai voucher

| Trường | Nội dung |
| --- | --- |
| Business workflow | Admin tạo/công khai voucher |
| Use Case | UC_AD_05; FR_AD_06; quyết định hiện tại |
| Customer/Admin | Admin |
| Trạng thái | UI ONLY cho form, READ MOCK; publish NOT IMPLEMENTED |
| UI | Percentage/fixed coupon example pages |
| Interaction | Xem mẫu/đổi loại/Cancel/breadcrumb; input readonly, Create/Draft khóa; chưa list/manage/publish. |
| Mock/Data Source | Hai Source chỉ fetch example, không saved coupon ID; không chung wallet Customer. |
| Tests | admin_percentage_coupon_test, admin_fixed_coupon_test, admin_coupon_navigation_test. |
| Backend dependency | Admin voucher CRUD/publish/version + public campaigns + eligibility/usage. |
| Missing rules | Code uniqueness, loại/min/cap/date/quota/stack và lifecycle; không cần phát riêng đã chốt. |
| Priority | P1 |
| Recommendation | Thiết kế public campaign contract; form/publish mock sau rule và P2 screen đủ; không thêm cấp phát account. |

### A07 - Customer Management

| Trường | Nội dung |
| --- | --- |
| Business workflow | Customer Management |
| Use Case | UC_AD_04; FR_AD_05, hiện giữ qua cleanup |
| Customer/Admin | Admin |
| Trạng thái | COMPLETE WITH MOCK READ; mutations NOT IMPLEMENTED |
| UI | Customers list/detail |
| Interaction | Search/role/status/page, ID-safe detail/Back; add/lock/edit roles không hoạt động. |
| Mock/Data Source | Nguồn fixture riêng; history/spend/address thiếu liên kết, không gán theo tên. |
| Tests | admin_customers_test, admin_customer_detail_test. |
| Backend dependency | User summary/detail/history IDs; lock/unlock theo permissions nếu bật. |
| Missing rules | Customer-only vs staff scope, quyền khóa và tác động phiên/đơn; không tự thêm quản lý role đầy đủ. |
| Priority | P2 read integration; P1 chỉ nếu nhóm cần lock MVP |
| Recommendation | Giữ read đã có; xem/lịch sử theo user ID. Lock/write cần gate nghiệp vụ. |

### A08 - Tiếp nhận Custom / phản hồi hỗ trợ

| Trường | Nội dung |
| --- | --- |
| Business workflow | Tiếp nhận Custom / phản hồi hỗ trợ |
| Use Case | UC_AD_03/09; FR_AD_04/11 |
| Customer/Admin | Admin |
| Trạng thái | NOT IMPLEMENTED Custom; READ MOCK conversations |
| UI | Conversations + chatbot scenario readonly |
| Interaction | Tìm/chọn hội thoại, xem history mẫu; send/mark handled/save scenario khóa; không quote editor. |
| Mock/Data Source | ConversationSource.requestCode chỉ label; không linked Custom source hoặc commands. |
| Tests | admin_conversations_test, admin_chatbot_test; chỉ readonly/stale data. |
| Backend dependency | Custom request/quote APIs, conversations/messages/ownership; handoff nếu được duyệt. |
| Missing rules | Quote/deposit/workflow; permission và mức human handoff MVP. |
| Priority | P1 Custom; P2 handoff theo scope |
| Recommendation | Ưu tiên request inbox/detail + quote tối thiểu sau rule; không coi hội thoại mẫu là Custom pipeline. |

### A09 - Review moderation cơ bản (hiện giữ)

| Trường | Nội dung |
| --- | --- |
| Business workflow | Review moderation cơ bản (hiện giữ) |
| Use Case | UC_AD_06; FR_AD_07 |
| Customer/Admin | Admin |
| Trạng thái | COMPLETE WITH MOCK READ; moderation UI ONLY |
| UI | AdminReviewsPage |
| Interaction | Search/filter/read, summary fixture; duyệt/ẩn/phản hồi chưa mutation. |
| Mock/Data Source | AdminReviewsSource riêng, không đồng bộ review Customer. |
| Tests | admin_reviews_test; không có Customer→Admin moderation E2E. |
| Backend dependency | Shared review IDs/status; list/hide nếu scope MVP duyệt. |
| Missing rules | Công khai ngay vs chờ duyệt/hidden, ai được hide; không mở moderation nâng cao. |
| Priority | P2, cần chốt phần tối thiểu |
| Recommendation | Giữ read; không tự thêm nâng cao. Basic hide chỉ sau quyết định rõ. |

## 3. Sáu luồng liên kết bắt buộc

| Luồng | Các phần thực có | Điểm đứt / kết luận | Điều kiện nghiệm thu đầu cuối sau này |
| --- | --- | --- | --- |
| 1. Admin tạo product → Customer xem/mua | Admin list fetch; Customer catalog chuẩn, detail/cart/COD mock | Admin Create khóa, không mutation Source. Admin SKU fixtures và Customer product IDs độc lập. **NOT END-TO-END** | Product được publish qua cùng contract/ID; Customer đọc đúng published variant/giá; selected purchase được server kiểm tra. Không ghép hai nguồn bằng tên/ảnh. |
| 2. Customer COD → Admin tiếp nhận | Customer tạo WOOL-* trong Store account | Admin chỉ đọc ORD-* fixture, không đọc Store hay API order Customer. **NOT END-TO-END** | Cùng order ID/owner/snapshot xuất hiện Admin qua nguồn chung có thẩm quyền; retry không nhân bản đơn. |
| 3. Admin đổi status → Customer tracking | Customer timeline theo Order snapshot, Admin detail đọc fixture | Không transition command Admin; không event feed/reload API chung. **NOT END-TO-END** | Allowed transition/version/actor được kiểm tra; reload Customer thấy đúng status/time, paid không suy từ delivered. |
| 4. Admin tạo/publish voucher → Customer xem/dùng | Admin form example readonly; Customer wallet riêng; V01 discount label đã sửa | Không create/publish, không public campaign source chung, không apply. **NOT END-TO-END** | Publish một campaign, các Customer đủ quyền xem cùng campaign; eligibility theo checkout, usage riêng nếu rule yêu cầu; không cần phát từng account. |
| 5. Customer pay → order/payment cập nhật | COD mock order; bank preview | Không transaction online, VNPay/đối soát Backend. COD creation không có nghĩa đã thu tiền. **NOT END-TO-END** | Backend xác minh payment, event idempotent; FE đọc status. Return URL/QR/copy không tự paid. |
| 6. Customer Custom → Admin nhận/phản hồi | Placeholder Customer, fixture customs account A, hội thoại Admin mẫu | Không submit Source, request ID chung, quote command hoặc phản hồi thật. **NOT END-TO-END** | Submit giữ request owner/media, Admin đọc đúng request và trả quote revision; Customer nhận đúng quote. Trigger production/payment chờ policy. |

Import cùng package Flutter không làm hai tiến trình Customer Mobile và Admin Web dùng chung bộ nhớ. Muốn dữ liệu thực liên thông phải qua Backend/API/database. Bộ fixture/contract tests chung có thể kiểm mapper trong mock, nhưng không được ghi là đã đồng bộ app chạy trên hai thiết bị.

## 4. Bằng chứng source trọng yếu

| Kết luận | File đã kiểm tra |
| --- | --- |
| Route Customer, private guard và màn tạm | [customer_app.dart](../apps/customer/lib/app/customer_app.dart), [PendingPage](../apps/customer/lib/shared/layout/pending_page.dart), [CustomerSessionGate](../apps/customer/lib/app/customer_session_gate.dart) |
| Account/cart/COD/ownership và pending Guest lịch sử | [LenlabStore](../packages/lenlab_shared/lib/src/state/lenlab_store.dart), [account data](../packages/lenlab_shared/lib/src/state/customer_account_data.dart), [cart data](../packages/lenlab_shared/lib/src/state/customer_cart_data.dart) |
| Catalog chuẩn không phải Admin fixtures | [mock catalog](../packages/lenlab_shared/lib/src/data/mock_product_catalog.dart), [AdminProductsSource](../apps/admin/lib/features/products/data/admin_products_source.dart) |
| Voucher đọc A-only, apply notice, V01 đúng selected discount | [VoucherSource](../apps/customer/lib/features/vouchers/data/voucher_source.dart), [VoucherPage](../apps/customer/lib/features/vouchers/presentation/voucher_page.dart), [CartVoucher](../apps/customer/lib/features/cart/presentation/widgets/cart_voucher.dart) |
| Không có voucher create/publish | [percentage source](../apps/admin/lib/features/coupons/data/admin_percentage_coupon_source.dart), [fixed source](../apps/admin/lib/features/coupons/data/admin_fixed_coupon_source.dart), [footer actions](../apps/admin/lib/features/coupons/presentation/widgets/coupon_header_footer.dart) |
| Hai nguồn order chưa nối | [COD source](../packages/lenlab_shared/lib/src/data/cod_order_data.dart), [AdminOrdersSource](../apps/admin/lib/features/orders/data/admin_orders_source.dart) |
| Bank chỉ preview, không payment provider | [bank_transfer_data.dart](../packages/lenlab_shared/lib/src/data/bank_transfer_data.dart), [PaymentMethodPage](../apps/customer/lib/features/checkout/presentation/payment_method_page.dart) |
| Không có RBAC thật | [AdminUser/AuthSource](../apps/admin/lib/features/auth/data/admin_auth_source.dart), [AdminSession](../apps/admin/lib/app/admin_session.dart) |
| Hội thoại/scenario chỉ đọc, không Custom/Gemini workflow | [conversation source](../apps/admin/lib/features/conversations/data/admin_conversations_source.dart), [SelectedConversation](../apps/admin/lib/features/conversations/presentation/widgets/selected_conversation.dart), [chatbot page](../apps/admin/lib/features/conversations/presentation/admin_chatbot_page.dart) |

## 5. Quyết định và contract còn thiếu

| Nhóm | Đã chốt - không hỏi lại | Phần còn thiếu cần nhóm/Backend thống nhất |
| --- | --- | --- |
| Scope/stack | Flutter cả hai FE; NestJS/Supabase/Gemini; loại Blog/digital/abandoned/biên lai/thống kê nâng cao | Cập nhật các docs dự thảo cũ có stack/feature khác; không dùng chúng để mở scope |
| Guest/session | Guest sửa giỏ, Auth trước đặt, owner theo user ID; không auto merge; P0-04 dừng 4A | Giữ/xóa legacy pending Guest data sau login như thế nào theo hướng mới; đây không phải lời mời tiếp tục merge |
| Voucher | Admin tạo/công khai; Customer tự dùng, không phát riêng; V01 đã xong | Campaign schema/publication, guest visibility, evaluation context, min/cap/expiry/timezone/rounding/stack/quota/consume. Trạng thái used cá nhân phải tách khỏi public campaign |
| Catalog | Physical IDs chuẩn P0-02; không mua sản phẩm không khả dụng | Variant IDs, stock cấp SKU, field validation, archive/delete semantics, media contract |
| Orders/payment/inventory | Selected lines, lỗi giữ dữ liệu, snapshot, auth guard, không tự paid | State vocabulary, transition/permissions, COD collection, reserve/deduct/release; pending online/create timing; recovery/idempotency bền vững |
| Shipping/address | Sổ và order snapshot tách; default delete rule đã chốt | Address IDs/version, vùng chuẩn, shipping provider/fee; 30.000đ không là giá vận hành đã chốt |
| Custom | Giữ trong MVP, ảnh mẫu khác biên lai | Request fields/attachments, quote version/expiry, full/deposit, accept/reject/production trigger; không tự chọn |
| Chatbot | Gemini qua NestJS | FAQ approved, fallback/handoff/privacy/rate limit và công thức nguyên liệu; không cho model tự thực thi tài chính |
| Auth/media | Mock identity/stamp, review mua đúng đơn/đã giao/một lần; ảnh review 5 JPG/PNG ×5 MiB | Auth provider/session/reset, media/storage/retention; server authorize/validate mọi request |
| Admin Customer/review | Read UI còn giữ trong cleanup/SRS | Mức write tối thiểu MVP, lock/hide permissions và tác động; không tự đưa quản trị nâng cao vào scope |

## 6. Kiểm chứng và giới hạn

Lượt audit này đã chạy analyzer qua Dart MCP cả ba project: **không diagnostics**. Chạy toàn bộ tests hiện tại: **658 PASS - Customer 377, Shared 100, Admin 181**. Kết quả JSON ở `build/remaining-mvp-audit.json` của từng project. Không thêm/xóa/sửa test hoặc cập nhật golden.

Các tests chứng minh nhiều interaction mock/error/stale/ownership, nhưng nhiều test Admin/voucher chủ động kiểm tra action readonly/notice. Test xanh không đồng nghĩa CRUD, public voucher hoặc API E2E đã hoàn thiện. Không có tỷ lệ coverage đo bằng công cụ trong lượt này; không suy ra coverage từ số test.

Không chạy APK/browser/Gemini/VNPay sandbox thật hoặc đối chiếu pixel mới với Figma trong audit này. Native picker, auth/payment return/resume, browser history và tích hợp đa app cần smoke/E2E riêng sau khi có các contract/môi trường phù hợp.

Đã phát hiện lệch tài liệu lịch sử, không sửa source để tự giải quyết: `_pendingGuestCarts` chưa bị xóa và không merge; wallet vẫn A-only; backend-design còn digital/merge/open decisions cũ. Hai tài liệu audit/roadmap này ghi nhận chính sách mới, không tự sửa hoặc thay thế mọi tài liệu gốc.

Chỉ tạo [audit này](REMAINING-MVP-WORKFLOWS-AUDIT.md) và [roadmap](REMAINING-MVP-IMPLEMENTATION-ROADMAP.md). Không triển khai bất kỳ task được đề xuất nào.
