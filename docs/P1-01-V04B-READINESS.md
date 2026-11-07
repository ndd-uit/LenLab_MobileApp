# P1-01 / V04b Preparation - Voucher Exit Flow & Demo Readiness

Ngày rà soát: 05/11/2026. **READINESS REPORT - chưa triển khai.** Chỉ tạo tài liệu này. Không sửa source/test/presentation/Figma/Backend/Database/Admin; không mở COD mới hoặc Cart Merge.

V04a được nghiệm thu kỹ thuật quote, **chưa phải voucher checkout end-to-end**. Baseline đã bàn giao: 737 PASS; không chạy lại tests/analyzer cho lượt tài liệu.

## 1. Kết luận readiness

**Chưa đủ điều kiện mở COD với voucher mới.** Có thể tách các đợt nhỏ, nhưng không chỉ gỡ safety gate sau khi thêm nút bỏ mã.

| Hạng mục | Hiện có | Phần còn thiếu |
| --- | --- | --- |
| Quote shared Cart/Review | Snapshot/cache, owner/context guards, nullable grand total | PaymentMethodPage/COD còn pricing legacy, chưa quote snapshot |
| Bỏ voucher | Helper reset transient dùng trong đổi phiên | Chưa command exit có target, chống callback cùng phiên khôi phục; chưa UI được duyệt |
| LEN50 | Fixture cũ và conflict guard | Quyền xóa phải do thao tác nêu rõ mã; không auto replace |
| Campaign app mặc định | 5 card public P2, usage riêng | Không có typed rules; chưa campaign nào mặc định apply thành công |
| Shipping | Callback quote và shipping snapshot evaluator inject được | Chưa provider demo chung/được duyệt, chưa wiring vào app |
| Hiển thị giảm ship | Quote tách Di/Ds/F; Review có net ship | Cart label giảm chung, Review chưa tách gross/discount/net cho khách |
| COD safety | Store vẫn chặn applied mới kể cả quote READY; P0-03 còn nguyên | Giữ gate cho tới khi tất cả acceptance ở mục 8 đạt |

### Hai điểm cần xử lý trước khi nối exit UI

1. **Bỏ applied làm UI quay về legacy.** Cart/Review chọn nhánh quote bằng hasUnquotedVoucherSelection; khi applied=null, chúng dùng legacy. Requote không voucher với F=17k có thể tồn tại trong Store, nhưng Payment/COD legacy vẫn dùng 30k. Không được lấy quote 17k hiển thị rồi đặt theo 30k, hoặc bỏ validator để ép chạy.
2. **Shipping phải dùng chung provider từ trước lúc apply.** Wallet mặc định tạo evaluator không có shippingPreview; QuoteSource có callback riêng nhưng chỉ đi vào quote UI khi đã có applied. Chỉ cấu hình QuoteSource chưa đủ để áp voucher ship lúc đầu. Cần inject cùng provider và context vào Wallet evaluator lẫn QuoteSource, không thêm default fee ngầm.

Đây là khoảng trống readiness trong phạm vi chuẩn bị, không phải thay đổi đã được triển khai.

## 2. Kiểm tra Figma và vị trí UI đề xuất

Đã đọc lại metadata Figma thành công, đối chiếu presentation hiện tại:

| Frame | Bằng chứng | Kết luận giới hạn |
| --- | --- | --- |
| [Cart 2026:1325](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-1325) | Voucher text 2026:1405; Options 2026:1402; rows Tiền hàng/Tiền giảm giá/Tạm tính | Có entry chọn/thay; chưa thấy option bỏ mã trong frame |
| [Ví 2026:4081](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-4081) | Input 2026:4094, Áp dụng 2026:4097, card list 2026:4099; Dùng ngay/Sao chép/used/expired | Chưa có “Không dùng voucher” trong các text/component được đọc |
| [Review 2026:1520](https://www.figma.com/design/D9NBXODlcmLSQkgHrJF8WC?node-id=2026-1520) | Section 2026:1595; shipping row 2026:1604; Giảm giá 2026:1609 | Có breakdown, chưa có exit control; chưa tách shipping discount row |

Metadata không chứng minh mọi prototype interaction; không coi label Options là bằng chứng đã có option none. Không chỉnh Figma hoặc dựng mockup mới.

### UI-E1 - Phương án tối thiểu, CHƯA DUYỆT

**Vị trí:** trong Ví, dưới container nhập mã/Áp dụng của vùng Padding 16 hiện có, trước Expanded/FutureBuilder danh sách. Nằm ngoài loading/error/empty của campaign để vẫn thoát được khi source lỗi.

~~~text
Voucher của tôi
[ Nhập mã voucher               Áp dụng ]
[ Không dùng voucher                    ]  ← action mới đề xuất
  Bỏ mã LEN50 đang áp dụng                  ← copy theo target, nếu có
[các card P2 hiện tại, giữ nguyên]
~~~

- Một hàng action rộng vùng nội dung, cao tối thiểu 44px; đề xuất reserve 56px và gap 8px, text dài được nở/cuộn theo font scale. Danh sách card bị đẩy xuống khoảng 64px; viewport đầu hiển thị ít card hơn. Đây là thay đổi hình ảnh phải duyệt, không chỉ wiring callback.
- Tái sử dụng typography/token brown/cream và button component hiện có; không thêm màu, icon, checkbox/radio, appbar hoặc màn hình mới. Việc dùng VoucherButton/TextButton và cách căn chính xác cần nhóm chọn trước code.
- Tên action: “Không dùng voucher”. Khi có LEN50, dòng mô tả phải nêu **“Bỏ mã LEN50 đang áp dụng”**; không dùng câu mơ hồ rồi âm thầm xóa legacy.
- Nếu có applied mới thì copy nêu đúng ưu đãi đang bỏ; candidate lỗi chưa applied không được mô tả như đã giảm tiền.
- Back/đóng Ví không thay state. Chọn action mới mới thực hiện exit, về Cart, dùng feedback hiện có. Không tự checkout.
- None đã là trạng thái hiện tại: idempotent, không tạo side effect hoặc Order. Không yêu cầu tải feed thành công để bỏ state local.
- Khi account A đang gửi COD, đề xuất không thay promotion của request A; báo đang xử lý bằng component hiện có. Guest/B không bị khóa theo A. Không coi bỏ mã là hủy đơn đang gửi.

**Không có interaction này được tự đánh dấu approved trong báo cáo.**

## 3. Hợp đồng exit đề xuất, không phải code hiện có

Đề xuất command local nhận session stamp, expected selection revision, target campaign ID và **expected legacy code hoặc null**; không giữ CartLine mutable. Chỉ nhận mục tiêu đã thể hiện rõ trên UI.

Thứ tự atomic đề xuất:

1. Kiểm phiên/generation và target vẫn đúng. Nếu coupon/selection đã đổi sau lúc render, từ chối callback cũ, tải lại lựa chọn; không xóa mã mới chưa được người dùng nhìn thấy.
2. Kiểm lock COD của account hiện tại trước mọi mutation, tránh setter coupon bị bỏ qua nhưng các transient đã bị xóa một phần.
3. Tăng voucher request sequence, quote request sequence và selection revision; vô hiệu mọi pending success/error của **cùng phiên lẫn phiên cũ**.
4. Xóa candidate, evaluation, applied, quote/pending readiness và busy state tương ứng. Không thay identity/generation như logout.
5. Chỉ xóa legacy coupon nếu intent nêu đúng code hiện tại và UI đã nói rõ sẽ bỏ code đó. Nếu intent không xác nhận legacy nhưng legacy bất ngờ xuất hiện, không giả vờ đã về none: yêu cầu người dùng xác nhận lại target.
6. Giữ nguyên lines/checkbox/quantity, note/address, saved data và Order; notify một trạng thái nhất quán. Không dùng logout/reset account để giả thao tác bỏ mã.
7. Yêu cầu quote không voucher theo nhánh pricing đã thống nhất ở dưới; source lỗi giữ nguyên trạng thái **đã bỏ**, cho retry, không rollback khôi phục voucher cũ.
8. Không tự submit, consume usage hoặc thay stock. Sau khi bỏ mã, callback evaluator/quote cũ không thể đưa applied/discount trở lại.

Thay voucher mới dùng Dùng ngay hiện có: chỉ swap sau eligible, rồi requote. Mã mới sai giữ applied trước nếu context còn hợp lệ. Với LEN50, chưa tự gộp “chọn mã mới” thành đồng ý xóa mã cũ; đề xuất bỏ LEN50 rõ ràng trước, rồi chọn campaign mới.

### Quyết định pricing khi bỏ về none - bắt buộc làm rõ

Đề nghị phân biệt **legacy fixture checkout** và **mock quote checkout** bằng binding rõ, không chỉ kiểm applied!=null.

- Trước V04b, checkout legacy không voucher mới vẫn được giữ nguyên và có thể hoạt động theo P0-03. Quote không voucher có phí khác chỉ là preview, không được trình bày như tổng sẽ đặt trong COD legacy.
- Khi nối V04b hoàn chỉnh, nhánh mock quote phải giữ binding qua cả selection=none, Cart → Review → Payment → COD; cùng một quote làm snapshot. Có lỗi/missing fee thì không fallback sang legacy.
- Nếu nhóm muốn một đợt exit nhỏ có COD không voucher ngay trước tích hợp quote, phải xác nhận rõ quay về **legacy fixture** và tất cả màn dùng totals legacy. Không được vừa giữ quote F17k trên màn vừa dùng F30k trong submit.
- Có thể đề xuất provider demo phí 30k để khớp legacy, nhưng đó vẫn là fixture phải duyệt, không default vận hành. Không tự chọn giải pháp này.

Exit command thuần có thể kiểm thử riêng; **binding/requote/UI là gate riêng**, chưa đủ căn cứ tuyên bố thêm action là giải quyết toàn bộ luồng tiền.

## 4. Campaign: dữ liệu P2, phần còn thiếu và demo

| Campaign mặc định | Nội dung P2 hiện có - không phải typed rule | Thiếu để kích hoạt | Trạng thái app |
| --- | --- | --- | --- |
| p2-len20 | LEN20, 20%, min 300k, ngày hiển thị | Xác nhận rate/min/cap, instants, limits/counters/version | Chỉ hiển thị; evaluate CONFIG_INCOMPLETE |
| p2-shipping | FREESHIP, min150k/tối đa30k, display expired | Chọn full/capped, amount/scope, fee source, validity/limits; duyệt copy nếu còn trả phí | Không apply; không tự đổi expired/date |
| p2-cash | 50K/min500k, ngày hiển thị, code=null, nút Sao chép | Typed fixed/min/validity/limits/version và interaction chọn nếu vẫn không code | Không sinh code; chưa default apply |
| p2-first | First-order, used fixture riêng A | Định nghĩa đơn đầu/eligibility; ngoài evaluator hiện tại | Unsupported, giữ read mock |
| p2-gift | Gift copy | SKU quà/tồn/fulfillment/rule; chưa thuộc evaluator | Unsupported, giữ read mock |

**Hiện không campaign P2 nào đủ typed config để chạy apply trong app mặc định.** Giá trị trên card không được copy tự động sang rule. Không chuyển LEN50 thành public campaign.

### Fixture tối thiểu đề xuất - CHỜ DUYỆT trước app demo

Ba campaign fixed/percent/capped ship đủ cho demo tối thiểu; full ship là scenario thứ tư nếu nhóm muốn kiểm chứng miễn toàn bộ. Dùng IDs riêng chỉ trong test/injection; **chưa thêm card/code/campaign vào UI**.

| ID đề xuất | Typed config kỹ thuật đề nghị | Cơ sở và tình trạng |
| --- | --- | --- |
| demo-q-fixed | ITEMS_FIXED, amount=10.000đ, min=0, code=null | Giá trị kiểm thử, không đọc từ card cash P2 |
| demo-q-percent | ITEMS_PERCENTAGE, rateBps=3333, cap=5.000đ, min=0, code=null | Kiểm rounding/cap; không tự map sang LEN20 |
| demo-q-ship-capped | SHIPPING_DISCOUNT_CAPPED, amount=10.000đ, min=0, code=null | Với gross17k/eligible12k: giảm10k, còn7k |
| demo-q-ship-full (optional) | SHIPPING_FREE_FULL, min=0, code=null | Scenario gross=eligible=17k: giảm17k, còn0; có phụ phí thì không gọi miễn toàn bộ |

Chung đề xuất: publication explicit, version1, global/perCustomer UNLIMITED explicit, mock clock T0 và validity [T0,T0+1 ngày). Tất cả **chỉ là giá trị demo/tests chờ duyệt**, không phải default thương mại. Quota LIMITED, first-order, hết hạn và lỗi dùng scenario test riêng; không mặc định mỗi user một lần.

Tests hiện có dùng campaign inject như quote-demo/version7, fee17k/eligible12k và clock 05/11/2026; những con số này chứng minh arithmetic, không chứng minh app demo đã cấu hình xong. Có thể tiếp tục bổ sung fixtures test không publish vào app. Muốn activate campaign hiện hữu phải duyệt riêng config và copy tương ứng; chưa tự seed một bộ card mới để giải quyết thiếu rule.

**Demo readiness sau này:** một composition root demo-only phải truyền cùng campaign source, usage source, clock và shipping provider vào Wallet/evaluator/quote. Tách khỏi dữ liệu vận hành, không fallback từ API lỗi sang demo. Đây là wiring cần duyệt fixture trước khi bật.

## 5. Shipping contract mock đề xuất

Provider phí chỉ cung cấp gross/eligible và trạng thái; evaluator tính discount, quote tính remaining. Không có hai provider tự tính discount riêng.

| Trường | Ý nghĩa |
| --- | --- |
| status | READY / NEEDS_CONTEXT / ERROR |
| contextKey + session stamp | Gắn selected items/address/payment context của đúng Guest/member session |
| grossShippingFeeVnd | Toàn bộ phí giao hàng trước voucher, bao gồm các phần bị loại nếu có |
| eligibleShippingFeeVnd | Phần được voucher tác động, 0≤eligible≤gross |
| reason | ADDRESS_REQUIRED, SHIPPING_CONTEXT_REQUIRED, SHIPPING_UNAVAILABLE, SHIPPING_CONTEXT_CHANGED... |
| sourceVersion / validUntil (nếu cung cấp) | Không gán TTL hoặc version ngầm |

Status không READY: các khoản chưa biết là **null**, không 0/30k. Zero là phí đã được biết rõ bằng 0. Không có address thì NEEDS_CONTEXT; callback/service lỗi là ERROR; dữ liệu context cũ không được dùng lại.

Từ provider và rule đã duyệt:

- Full: Ds=eligible fee. Chỉ nói “Miễn phí vận chuyển” khi remaining=gross−Ds=0 và không còn phí ngoài phạm vi; nếu remaining>0 phải nói giảm/hỗ trợ phí ship và nêu số còn trả.
- Capped: Ds=min(configuredDiscountVnd,eligible fee), remaining=gross−Ds.
- Item voucher: Ds=0, Di từ item evaluator; ship voucher có Di=0. Một voucher/đơn, không cộng LEN50.
- Grand total=S−Di+gross−Ds. gross không phải eligible; không trừ Ds lần hai khỏi net fee.
- Mock shipping source nhận address context và được gọi cả trước apply lẫn khi quote; đổi địa chỉ/quantity/selection làm preview cũ không hợp lệ.
- Member chưa có địa chỉ: giữ candidate, thông báo cần context, dùng bước địa chỉ hiện có. Khi quay lại phải evaluate với context mới; không tự dùng usage Guest hoặc auto submit sau Auth.

### UI-S1 - cần duyệt trước presentation

Hiện Cart bar cộng Di+Ds vào câu “Ước tính giảm…”, Review hiện net shipping; toán đúng nhưng giải thích giảm ship chưa đủ.

Đề xuất nhỏ:

- Cart: item voucher ghi “Ước tính giảm tiền hàng X”; shipping voucher ghi “Ước tính giảm phí ship X”. Không đưa Ds vào row Tiền giảm giá của hàng.
- Review: row Phí vận chuyển hiển thị **gross**; thêm row “Giảm phí vận chuyển” −Ds khi Ds>0; row giảm hàng giữ/đổi rõ “Giảm tiền hàng”. Tổng giữ nguyên từ quote.
- Tái sử dụng _row/style hiện có; thêm một row làm section cao khoảng 30px (20px text +10px gap), không đổi palette/typography/icon. Đây vẫn là thay đổi bố cục/copy phải duyệt; chưa code.
- Không voucher/Di-only: không thêm shipping-discount row thừa. Missing context: không hiển thị giá giả; Cart Tạm tính vẫn chỉ tiền hàng, không gọi là grand total.
- Scope full/capped và phí còn trả phải thấy được khi khách đánh giá ưu đãi, không chỉ nằm trong dữ liệu debug hoặc badge “FREESHIP”.

Ví dụ kiểm chứng: gross17k, eligible12k, capped10k → Review gross17k, giảm ship10k, còn7k; giảm hàng0. Full trên eligible12k vẫn còn5k, không quảng cáo miễn toàn bộ.

## 6. Những phần có thể code riêng và những phần phải chờ

Đây là **kế hoạch**, không phải phần đã sửa trong task này.

| Task nhỏ | Có thể làm độc lập? | Dependency / acceptance chính | File dự kiến |
| --- | --- | --- | --- |
| R1 - Exit command + cancellation tests | Có, ở tầng Store/test, giữ UI/COD gate | Session/expected target/revision; atomic; giữ cart/draft/orders; callback cùng phiên không phục hồi mã | lenlab_store.dart; test exit riêng |
| R2 - Shipping contract/fixtures tests | Có, provider fake/test-only | Gross/eligible/null/error; snapshot context; chung một phép tính Ds | voucher_evaluation.dart; quote/evaluator tests |
| R3 - UI Không dùng voucher | **Chờ UI-E1 + semantics legacy** | Vị trí/target copy; dùng được khi list lỗi; Back/cancel không mutate | voucher_page.dart; navigation/widget tests |
| R4 - Demo provider/wiring | **Chờ config và pricing binding** | App dùng cùng source/rules/clock/fees; không seed unapproved; giải quyết bootstrap shipping | voucher fixtures; eligibility/quote sources; customer composition root |
| R5 - Copy/breakdown ship | **Chờ UI-S1** | Gross/discount/net rõ; không gọi giảm ship là giảm hàng; không nhận full khi còn phí | cart_voucher.dart; order_review_totals.dart; visual tests |
| R6 - Requote none + normal checkout | **Chờ quyết định binding mục 3** | No-voucher quote không bị bỏ qua rồi dùng formula khác; quote lỗi không hồi voucher | Store, Cart/Review, quote adapter |
| R7 - V04b COD/Payment/snapshot | **Chưa được mở trong task chuẩn bị** | Tất cả gate mục 8; không bypass P0-03/P0-04 | payment_method_page.dart, COD draft/source/validation/model và tests |

R1/R2 có thể được giao làm đợt kỹ thuật riêng, không cần chờ đổi hình ảnh; **lượt này vẫn không code**. Không gộp R3–R7 thành một thay đổi lớn.

## 7. Tests cần bổ sung khi được phép triển khai

- Exit candidate-only / applied-ready / applied-stale / legacy-only / conflict; no-op khi none.
- A→B, A generation mới, callback none cũ sau khi đổi coupon/selection: không xóa state phiên mới.
- Pending eligibility success/error và pending quote success/error trả về sau exit **cùng phiên**: không phục hồi applied/quote cũ.
- COD A pending: exit không đổi request/snapshot A; không khóa Guest/B.
- Exit giữ exact selected lines, quantities, note/address, saved data/Orders; quote retry lỗi không hồi voucher.
- Explicit bỏ LEN50 mới xóa; code đã đổi thì reject old intent, không auto replace.
- Member chọn ship thiếu địa chỉ → bổ sung context → evaluator/quote cùng provider, không bootstrap dead-end.
- Quote none, missing fee, source error; không hiển thị F17k rồi submit F30k.
- Gross/eligible khác nhau, capped >eligible, full có phụ phí, zero fee và unknown fee; không trừ ship discount hai lần.
- Widget row none có khi loading/error/empty; Back/cancel; keyboard/text scale; focus/accessibility, golden diff chỉ phần UI được duyệt.
- V04b riêng mới test Order snapshot Di/Ds/gross/net/quote version, revalidation, retry/idempotency và session isolation; toàn bộ hồi quy hiện có tiếp tục đạt.

Không thêm/chạy tests trong lượt readiness này.

## 8. Gate bắt buộc trước mở COD mới

- [ ] Typed campaigns, phí/scope/clock demo và cách bật demo đã được duyệt; không tự parse P2.
- [ ] Exit/replace UI đã duyệt và hoạt động khi lỗi/thiếu context; có đường checkout không voucher không bị khóa vĩnh viễn.
- [ ] Pricing binding rõ cho none/legacy/new campaign; PaymentMethodPage bỏ phép tính riêng trong nhánh quote.
- [ ] Quote READY đúng owner/generation, context/selected snapshots, campaign version, hiệu lực; không chỉ kiểm một bool READY.
- [ ] Snapshot đơn có Di, Ds, gross/net shipping và quote identity/version nhất quán; mapper không làm Ds thành giảm hàng hoặc đếm hai lần.
- [ ] Revalidate catalog/price/stock/voucher/quote khi submit. Validator COD hiện tại chỉ hiểu LEN50 +30k: cần nhánh quote-aware bảo toàn mọi kiểm tra P0-03, **không xóa checks để cho test qua**.
- [ ] Một voucher, không stacking LEN50; không tự đánh dấu paid/consume quota hoặc đổi inventory lifecycle.
- [ ] Retry/double submit dùng cùng ý định tạo đơn, không tạo trùng; mock RAM không được trình bày như idempotency bền vững Backend.
- [ ] Pending/logout/account switching vẫn theo P0-04; không chuyển order/request cũ cho phiên mới.
- [ ] Tests/analyzer/smoke sau triển khai đạt; native/browser E2E báo đúng mức kiểm chứng.

Backend sau này xác minh authoritative quote/fees/eligibility, authorization, inventory transaction, usage/quota, payment và idempotency bền vững. Không tin giá, discount hoặc owner từ Flutter. Chưa cần viết Backend cho các đợt mock/readiness này.

## 9. Các quyết định tối thiểu cần nhóm chấp thuận

1. UI-E1: vị trí/hình ảnh row none và copy nêu đúng legacy code bị bỏ; cách xử lý target đã đổi.
2. Pricing binding sau exit: trở về legacy rõ ràng trong đợt nhỏ, hay đưa none vào nhánh quote cùng kế hoạch Payment/COD? Không cho phép trộn hai totals.
3. Ba fixture demo tối thiểu và optional full; quotas/validity/clock/code optional; cách bật demo và việc có thêm nội dung UI demo hay không.
4. Shared shipping provider, bộ gross/eligible fee demo và flow bổ sung địa chỉ; phí nào nằm ngoài ưu đãi.
5. UI-S1: copy giảm hàng/ship ở Cart và row gross/ship discount của Review.

Không yêu cầu duyệt lại một voucher/đơn, public campaigns, Guest browsing, private usage, Auth trước đặt, không auto merge hoặc các công thức mock đã chốt. Chưa có quyết định mới nào được tự đánh dấu APPROVED ở đây.

## 10. Căn cứ source và phạm vi kiểm chứng

Đã đối chiếu [V04a](P1-01-V04A.md), [V03b](P1-01-V03B.md), Figma nêu trên và:

- [Store](../packages/lenlab_shared/lib/src/state/lenlab_store.dart): reset session, request counters, quote binding, cart lock, COD gate.
- [Campaign fixtures](../apps/customer/lib/features/vouchers/data/voucher_fixtures.dart), [Wallet](../apps/customer/lib/features/vouchers/presentation/voucher_page.dart), [VoucherButton](../apps/customer/lib/features/vouchers/presentation/widgets/voucher_button.dart).
- [Evaluator](../apps/customer/lib/features/vouchers/data/voucher_eligibility_source.dart), [shipping/evaluation model](../packages/lenlab_shared/lib/src/data/voucher_evaluation.dart), [quote source](../apps/customer/lib/features/checkout/data/mock_checkout_quote_source.dart), [quote model](../packages/lenlab_shared/lib/src/data/checkout_quote.dart).
- [Cart voucher](../apps/customer/lib/features/cart/presentation/widgets/cart_voucher.dart), [Cart summary](../apps/customer/lib/features/cart/presentation/widgets/cart_summary.dart), [Review totals](../apps/customer/lib/features/checkout/presentation/widgets/order_review_totals.dart).
- [Payment](../apps/customer/lib/features/checkout/presentation/payment_method_page.dart), [COD source](../packages/lenlab_shared/lib/src/data/cod_order_data.dart), [P0-03 validator](../packages/lenlab_shared/lib/src/data/cod_checkout_validation.dart).

Chỉ tạo docs/P1-01-V04B-READINESS.md. Không rerun analyze/tests hoặc xác minh APK trong lượt này; **737 PASS là baseline V04a**, không phải kết quả chạy mới. Không sửa Figma, source, tests, golden hoặc roadmap đã bàn giao. Dừng sau readiness; COD với voucher mới tiếp tục bị khóa.
