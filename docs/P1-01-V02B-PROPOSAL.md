# P1-01 / V02b - Voucher Eligibility & Checkout Quote Proposal

Cập nhật: 05/11/2026, sau review MVP. **DRAFT - FOR APPROVAL. Chỉ thiết kế tài liệu.**

> Superseded một phần bởi [V03b](P1-01-V03B.md): Guest nay được đọc campaign public/xem preview; một voucher/đơn, không stacking đã được chốt cho task mock. Ghi chú cũ về Ví bắt buộc Auth hoặc một voucher còn PROPOSED bên dưới là lịch sử V02b. Usage vẫn private; công thức mock không phê duyệt giá trị thương mại P2, lifecycle Backend hoặc quote TTL.

Hướng kiến trúc tách public campaign, usage cá nhân, eligibility và checkout quote đã được chấp nhận. Điều đó **không phê duyệt toàn bộ VBR-01–16**. Bản rút gọn này thay thế các đề xuất cũ về mặc định một lượt/user, miễn ship có trần, trigger consume COD và TTL 5 phút.

## A. Ràng buộc đã xác nhận và đối chiếu

| Nội dung đã xác nhận | Ranh giới |
| --- | --- |
| Admin tạo/quản lý/công khai campaign; Customer tự xem/chọn | Không phát hoặc sao chép campaign riêng từng account |
| Campaign ID ổn định; usage riêng theo user ID | Không ghép tên/ảnh/index hoặc chia sẻ usage A/B |
| Ví cần đăng nhập; checkout chỉ tính dòng chọn | Không mở Guest wallet, tự tick hàng hoặc auto merge Guest/account |
| Backend xác minh eligibility và tổng tiền | Không tin giá, discount, totals hoặc userId do Flutter khai |
| Apply không tiêu thụ lượt | FE không điều khiển lifecycle quota có thẩm quyền; logout không mặc định hủy đơn |
| Dùng ngay bằng campaignId khi không code; nhập tay khi có code | Không sinh code thiếu hoặc bắt nhập lại mã sau Dùng ngay |
| Dùng ngay đủ context và eligible thì áp dụng | Chưa có dòng chọn: về Cart, giữ candidate đúng phiên, không tự chọn hàng/tạo đơn |
| Quota theo cấu hình campaign | Không mặc định mỗi Customer chỉ dùng một lần |
| Miễn ship hoàn toàn khác giảm ship có trần | Khách còn trả phí thì không hiển thị như miễn phí hoàn toàn |
| Backend chốt lifecycle usage, COD trigger và quote expiry | Xác nhận đơn COD khác xác nhận đã thu tiền; không tự chọn trigger hoặc TTL |
| Gift/first-order giữ hiển thị mock | Thiếu rule thì evaluator không được trả áp dụng thành công |
| UI P2, V01, P0-03 giữ nguyên | LEN50 là pricing fixture; không sửa formula hoặc triển khai V03 |

| Nguồn / nội dung | Phân loại | Cách sử dụng |
| --- | --- | --- |
| SRS FR_US_05, UC_US_05, BR-01: voucher/điều kiện/lỗi | Có trong tài liệu, chưa đủ công thức/quota/usage | Căn cứ cần eligibility; không suy giá trị thiếu |
| SRS UC_AD_05: lưu voucher có hiệu lực | Tài liệu cũ gộp lưu/công khai/thời gian | Đề xuất tách publication và validity, flow Admin chưa duyệt |
| UI/UX: voucher sai giữ tổng hợp lệ trước | Có trong tài liệu | Chỉ giữ kết quả trước nếu context còn hợp lệ; không submit quote stale |
| LEN20, card 50K/freeship/gift/first-order, ngày/minimum | Mock/fixture | Không parse copy thành rule, tự cấp code hoặc eligibility |
| LEN50 và ship 30.000đ | Pricing fixture | Không làm default API/chính sách thương mại |
| V02a public campaign + private usage | Mock read đã nghiệm thu | Cùng campaign A/B, usage riêng; display không phải eligibility |
| Backend design Phase 1 | Draft contract | Không coi endpoint/state draft là policy đã duyệt |
| Stacking/rounding/quota/consume/TTL chi tiết | Chưa thống nhất đủ | Đề xuất nhóm duyệt ở B1, điều kiện Backend ở B2 |

Căn cứ: SRS (`docs/LENLAB_SRS.docx`; local-only; not distributed with this repository), UI/UX (`docs/LENLAB_UI_UX.docx`; local-only; not distributed with this repository), Mobile (`docs/Mobile.docx`; local-only; not distributed with this repository), [V01](P1-01-V01.md), [V02a](P1-01-V02A.md), [audit](REMAINING-MVP-WORKFLOWS-AUDIT.md), [roadmap](REMAINING-MVP-IMPLEMENTATION-ROADMAP.md), [API draft](backend-design/API-CONTRACT.md).

Source tham chiếu: [model](../apps/customer/lib/features/vouchers/data/voucher_models.dart), [fixture](../apps/customer/lib/features/vouchers/data/voucher_fixtures.dart), [source](../apps/customer/lib/features/vouchers/data/voucher_source.dart), [Store](../packages/lenlab_shared/lib/src/state/lenlab_store.dart), [OrderReviewSource](../packages/lenlab_shared/lib/src/data/order_review_data.dart). Hành vi code không phải bằng chứng phê duyệt nghiệp vụ.

## B. Những quyết định cần chốt

### B1. Phương án đơn giản để nhóm phê duyệt

**Các phương án dưới đây vẫn PROPOSED**, không được tự triển khai thành mặc định. S = tiền các dòng chọn trước voucher, không gồm ship; F = phí ship đủ điều kiện do Backend xác định; Di = giảm hàng; Ds = giảm ship.

| Mã tham chiếu | Phương án đề nghị | Lý do / rủi ro |
| --- | --- | --- |
| VBR-01 | Fixed: Di=min(fixedAmountVnd,S), amount dương | Không âm tiền hàng; thực giảm có thể thấp hơn quảng cáo |
| VBR-02 | Percent: Di=min(floor(S×rateBps/10000),maxDiscountVnd,S); cap dương bắt buộc cho MVP đề xuất | Tránh float; cap bắt buộc vẫn cần nhóm duyệt |
| VBR-03 | SHIPPING_FREE_FULL: Ds=F, không có cap làm khách còn trả F. SHIPPING_DISCOUNT_CAPPED: Ds=min(configuredAmountVnd,maxShippingDiscountVnd,F) | Loại capped phải ghi giảm phí/tối đa, không gọi miễn phí hoàn toàn; phụ phí/phạm vi F chờ Backend |
| VBR-04/15 | Gift/first-order chỉ read mock; chưa evaluate thành công | Không tự định nghĩa SKU quà hoặc đơn đầu; thiếu rule trả unsupported/config incomplete |
| VBR-05 | Minimum so với S trước voucher, không ship; MVP all-selected-physical scope | Đơn giản; product/category scope và Custom cần đặc tả riêng |
| VBR-06 | Một voucher tổng cộng/đơn, item hoặc shipping; chưa stacking/auto-best | Giảm xung đột; **chưa được duyệt**, DTO cũ có array không phải quyết định |
| VBR-07 | Backend clock, startsAt≤now<endsAt; Admin/display Asia/Ho_Chi_Minh, instant UTC | Biên hết hạn rõ; cách nhập ngày cuối/trường bắt buộc cần duyệt |
| VBR-08 | Global/perCustomer cấu hình LIMITED(n>0) hoặc UNLIMITED tường minh | Không default một lần hoặc null=vô hạn; không tự chọn quota thương mại |
| VBR-09 | VND nguyên đồng, percent floor một lần trên S rồi cap; allocation largest remainder nếu cần | Tổng line khớp Di; thuật toán/tie-break stable ID cần Backend thống nhất |
| VBR-13 | ID/code union; đề xuất trim/ASCII case-insensitive, unique khi có code | Không nhập lại sau Dùng ngay; charset/length/đổi code chưa chốt |
| Flow V03 | Candidate mới chỉ thay applied sau kết quả hợp lệ; mã sai giữ applied cũ nếu context vẫn hợp lệ. Bỏ mã chủ động requote không voucher | Không âm thầm bỏ mã hoặc giữ tổng stale; feedback/thay/bỏ cần duyệt |
| VBR-16 | Chưa tạo đơn tổng 0đ tới khi có policy; trả lỗi rõ, không tự coi paid | Có thể chặn đơn giảm hết; nhóm cần chọn hỗ trợ hay hoãn trước V04 |

Không có minimum/rate/cap/quota mặc định được phê duyệt bởi bảng này. Không minimum hoặc unlimited phải là cấu hình tường minh theo contract.

### B2. Điều kiện vẫn phải chờ Backend

| Chủ đề | Cần thống nhất | Ranh giới FE |
| --- | --- | --- |
| VBR-10/11: usage/quota | Thời điểm ghi nhận/giữ/tiêu thụ/hoàn lượt; rollback/timeout/cancel/refund; reservation/deadline nếu có | Không đưa HELD/CONSUMED/RELEASED vào FE như state machine có thẩm quyền; hiển thị status/reason server trả |
| COD | ORDER_CONFIRMED khác COD_PAYMENT_COLLECTED; event ảnh hưởng usage phải do nhóm/Backend thống nhất | Không tự chọn confirm đơn hoặc thu tiền làm consume trigger; tạo COD không đồng nghĩa paid |
| Payment online | Verified result, callback/retry trùng, timeout/late-paid/đối soát | FE đọc server, không tự paid hoặc hoàn lượt |
| VBR-14: quote expiry | TTL/version/revalidation và guarantee nếu có | Không cố định 5 phút, tự gia hạn hoặc mặc định giữ tồn/quota; dùng expiresAt server |
| Quota configurable | Atomic count, giới hạn user, đơn đang xử lý và reason codes | Không đếm đơn local hoặc dùng badge Đã dùng làm authority |
| Cart/context | CartItem/Variant IDs/version, quantity, address/shipping/payment requirements | Không suy ID production từ label/index; giá client không có thẩm quyền |
| Shipping full/capped | Phạm vi F, phụ phí/vùng/dịch vụ bị loại | Full giảm toàn F trong phạm vi công khai; nếu còn phí khách trả phải ghi rõ, không quảng cáo miễn phí toàn bộ |
| Publication/config | Draft/published/hidden, rule version, publish validation | Published không đồng nghĩa eligible; thiếu config không parse card hoặc fallback LEN50 |

Backend có thể dùng ledger/reservation nội bộ; tài liệu này không khóa enum hoặc transition nội bộ. Đơn thất bại/unknown phải giải quyết qua contract/idempotency, không suy từ FE.

## C. Contract đề xuất tối thiểu

**DTO, enum và endpoint vẫn là draft để Backend review. Không có API triển khai trong lượt này.**

### C1. Campaign và usage riêng

PublicVoucherCampaign minh họa:

~~~json
{
  "id": "campaign-demo-fixed",
  "version": 3,
  "publication": "PUBLISHED",
  "type": "ITEMS_FIXED",
  "title": "Ưu đãi minh họa",
  "code": null,
  "validity": {
    "startsAt": "2026-12-01T00:00:00+07:00",
    "endsAt": "2027-01-01T00:00:00+07:00",
    "displayTimeZone": "Asia/Ho_Chi_Minh"
  },
  "rule": {
    "currency": "VND",
    "scope": "ALL_PHYSICAL_SELECTED_ITEMS",
    "minItemsSubtotalVnd": 300000,
    "fixedAmountVnd": 40000
  },
  "limits": {
    "global": {"mode": "LIMITED", "maxUses": 1000},
    "perCustomer": {"mode": "LIMITED", "maxUses": 3}
  }
}
~~~

Mọi số là **DEMO**, không là policy P2/LEN50. perCustomer=3 minh họa cấu hình, không default. UNLIMITED không có maxUses; missing config không tự unlimited.

Typed rules đề xuất: ITEMS_FIXED, ITEMS_PERCENTAGE, SHIPPING_FREE_FULL, SHIPPING_DISCOUNT_CAPPED. Full không có cap làm mất nghĩa miễn toàn F; capped có amount/cap rõ. Gift/first-order giữ projection đọc mock, evaluator không trả thành công khi thiếu rule.

CustomerVoucherUsage - principal hiện tại:

~~~json
{
  "subjectId": "customer-server-id-a",
  "items": [
    {
      "campaignId": "campaign-demo-fixed",
      "usageVersion": 4,
      "usedCount": 1,
      "remainingUses": 2,
      "availability": "AVAILABLE",
      "reasonCodes": [],
      "asOf": "2026-12-05T03:00:00Z"
    }
  ]
}
~~~

Counts/availability do Backend trả; ví dụ không chốt trigger tăng usedCount hoặc cách tính reservation. UNLIMITED có remainingUses=null kèm limit mode rõ; missing khác unlimited. usedCount>0 không đồng nghĩa hết quyền nếu còn lượt. Mapping card “đã dùng nhưng vẫn còn lượt” phải duyệt trước V03b, giữ UI P2; không dùng badge cũ để xét quyền.

### C2. Eligibility

POST /api/v1/voucher-eligibility dự kiến:

~~~json
{
  "cartId": "cart-demo-a",
  "cartVersion": 12,
  "selectedLines": [
    {"cartItemId": "line-demo-1", "itemVersion": 5, "quantity": 2}
  ],
  "voucherSelection": {
    "kind": "CAMPAIGN_ID",
    "campaignId": "campaign-demo-fixed",
    "expectedVersion": 3
  },
  "checkoutContext": {
    "addressId": "address-demo-a",
    "addressVersion": 2,
    "shippingServiceId": "shipping-demo-standard",
    "paymentMethod": "COD"
  }
}
~~~

Nhập tay dùng voucherSelection={"kind":"CODE","code":"DEMO40"} chỉ khi campaign tương ứng có code thật. Không gán DEMO40 cho campaign code=null ở C1. Hai cách resolve cùng campaign khi campaign thực sự có code; không nhận đồng thời ID/code. Một-voucher/đơn vẫn PROPOSED.

Server lấy principal từ auth, kiểm cart/address owner, versions, catalog, quantities và chỉ selected lines. Không nhận userId/price/subtotal/discount/total làm authority; cách reject field dư cần Backend thống nhất. Cart hiện chưa có server CartItem/Variant IDs; mock sau này cần identities tường minh, không dùng tên/index làm production ID.

~~~json
{
  "evaluationId": "evaluation-demo-1",
  "status": "ELIGIBLE",
  "campaign": {"id": "campaign-demo-fixed", "version": 3},
  "cartVersion": 12,
  "contextFingerprint": "opaque-server-context",
  "evaluatedAt": "2026-12-05T03:00:00Z",
  "totals": {
    "currency": "VND",
    "itemsSubtotalVnd": 500000,
    "itemsDiscountVnd": 40000,
    "shippingFeeVnd": 30000,
    "shippingDiscountVnd": 0,
    "grandTotalVnd": 490000
  },
  "reasons": [],
  "quoteRequiredBeforeOrder": true
}
~~~

ELIGIBLE là kết quả tại evaluatedAt/context, không giữ lượt/tồn. Apply không consume quota.

Item preview đủ context hàng nhưng chưa đủ ship có thể trả tiền hàng/giảm hàng và ship/grandTotal=null; FE không biến null thành 0 hoặc tổng cuối. Shipping thiếu address/service trả NEEDS_CONTEXT + missingFields; INELIGIBLE có reasons và totals=null, không ghi applied thành công. Quota còn không tự chứng minh đủ mọi điều kiện.

### C3. Quote và order snapshot

POST /api/v1/checkout/quotes nhận cùng selected identities/versions/context và voucherSelection nullable, không nhận tiền client. Voucher mới sai không được âm thầm trả quote bỏ voucher.

CheckoutQuoteResponse tối thiểu:

- quoteId/quoteVersion, contextFingerprint, cart/item/address/campaign versions; owner kiểm tại server.
- READY khi đủ context; serverTime/expiresAt do Backend trả, **không TTL mặc định**.
- Items: productId/variantId, quantity, unitPriceVnd, lineSubtotalVnd, lineDiscountVnd.
- Totals: itemsSubtotalVnd − itemsDiscountVnd + shippingFeeVnd − shippingDiscountVnd = grandTotalVnd.
- appliedVoucher: campaignId/version, type/code nullable và actual discounts.
- Guarantee/reservation nếu có phải được mô tả rõ; FE không mặc định giữ tồn/quota/giá.

Bất biến đề xuất: 0≤Di≤S, 0≤Ds≤F, tiền không âm, tổng line discount=Di. Full ship có Ds=F; capped không mặc định như vậy. Context đổi/hết hạn thì quote không submit-ready; Backend revalidate tại tạo đơn và trả conflict khi cần khách xem lại, không âm thầm đổi tiền.

POST /api/v1/orders dự kiến nhận quoteId/version, paymentMethod, note và Idempotency-Key. Retry cùng intent trả cùng order; payload đổi dưới cùng key bị conflict. Timeout không tự hoàn lượt hoặc tạo đơn mới; replay đơn đã tạo không thành đơn mới vì quote giờ hết hạn.

OrderVoucherSnapshot bất biến đề xuất: campaignId/version/ruleVersion, type/title/codeAtOrder nullable, ruleAtOrder/baseAmountVnd, actual items/shippingDiscountVnd, line allocations, quoteId/version, thời điểm snapshot và tham chiếu server nếu cần. Không tính lại đơn cũ khi Admin sửa campaign. Usage/payment state tách khỏi snapshot, do Backend cung cấp.

Đọc dữ liệu dự kiến qua GET /api/v1/voucher-campaigns (authenticated, published only) và GET /api/v1/me/voucher-usage. Không cho client chọn userId khác. Public metadata và private usage có thể chung response nếu vẫn tách rõ scope.

## D. Flow, errors và acceptance criteria

### D1. Dùng ngay và nhập mã

1. Dùng ngay giữ campaignId, không yêu cầu nhập lại code.
2. Chưa có dòng chọn: về Cart, giữ candidate gắn userId + session generation; không tick hàng, apply thành công hoặc tạo đơn.
3. Có dòng chọn và đủ context cần thiết: gọi eligibility; ELIGIBLE đúng phiên/context thì áp lựa chọn và hiển thị actual discount. Item-only preview chưa có ship không được gọi grand total là cuối cùng.
4. Thiếu context bắt buộc: giữ candidate, báo cần bổ sung; chưa thông báo áp thành công. Chi tiết chuyển tới bước bổ sung theo navigation hiện có cần duyệt trước code.
5. Nhập tay code thật resolve qua cùng eligibility path, không có công thức riêng.
6. Mã sai/response cũ không thay applied hợp lệ. Context đổi thì giữ input/candidate nhưng vô hiệu readiness của kết quả cũ.
7. Logout/account switch clear transient candidate/request/quote cũ; không xóa saved account cart hoặc tự hủy đơn server. Không persistence.

FE kiểm userId + generation + request sequence + checkout revision trước/sau await; server fingerprint chỉ bổ sung, không thay session guard. Đây là thiết kế flow, chưa triển khai V03.

### D2. Errors đề xuất

| Nhóm | Mã minh họa | Hành vi |
| --- | --- | --- |
| Auth/owner | AUTH_REQUIRED, SESSION_EXPIRED, CART_NOT_FOUND, QUOTE_NOT_FOUND | Return intent hợp lệ, không lộ account khác |
| Config/selection | INVALID_VOUCHER_SELECTION, VOUCHER_NOT_AVAILABLE, VOUCHER_CONFIG_INCOMPLETE, VOUCHER_TYPE_UNSUPPORTED | Không suy rule/code; draft/hidden/unknown không lộ metadata |
| Eligibility | MINIMUM_NOT_MET, VOUCHER_NOT_STARTED, VOUCHER_EXPIRED, GLOBAL_QUOTA_EXHAUSTED, CUSTOMER_LIMIT_REACHED | Reason server, không dùng usedCount>0 để tự chặn |
| Context | EMPTY_SELECTION, SHIPPING_CONTEXT_REQUIRED, ADDRESS_REQUIRED | NEEDS_CONTEXT, giữ candidate, không auto chọn hàng |
| Stale | CART_CHANGED, PRICE_CHANGED, VOUCHER_CHANGED, QUOTE_STALE, QUOTE_EXPIRED | Re-evaluate/requote, khách xem lại; không tự đổi lượng/giá |
| Stock | PRODUCT_UNAVAILABLE, VARIANT_UNAVAILABLE, OUT_OF_STOCK, QUANTITY_INVALID | Giữ P0-03, chỉ dòng chọn chặn checkout |
| Create/network | IDEMPOTENCY_CONFLICT, SERVICE_UNAVAILABLE, RATE_LIMITED, NETWORK_ERROR | Giữ draft; unknown timeout xử lý theo contract, không tự sửa usage |

HTTP/envelope/retry fields cần Backend review. Safe reasons/message keys không chứa private data hoặc HTML tùy ý; unknown code có fallback.

### D3. Tests cần có sau phê duyệt

| Scenario | Acceptance criteria |
| --- | --- |
| A/B cùng campaign | Metadata chung, usage/request cũ không chuyển account |
| Không code / có code | Dùng ngay bằng ID không nhập lại; nhập code thật resolve cùng evaluator |
| Chưa chọn dòng / đủ context | Lần lượt giữ candidate về Cart hoặc áp actual discount nếu eligible; không tự đặt đơn |
| Context đổi trong lúc chờ | Bỏ response cũ, không apply stale |
| Full/capped shipping | Full giảm toàn F; capped ghi phần còn trả, không gọi miễn phí hoàn toàn |
| Đã dùng nhưng còn lượt | Không disable chỉ vì usedCount>0; dùng availability từ Backend |
| Quota/config chưa rõ, gift/first-order thiếu rule | Không default unlimited/một lần hoặc báo áp thành công |
| Apply/retry/rebuild | Không tạo đơn, consume hoặc điều khiển lifecycle server |
| COD confirmed vs collected | Không tự coi confirm là thu tiền/consume |
| Quote expiry | Dùng expiresAt server, không mặc định 5 phút/tự gia hạn |
| Mã mới sai / bỏ mã | Giữ applied cũ chỉ nếu còn hợp lệ; bỏ mã chủ động requote |
| Timeout/duplicate order | Không nhân đơn, Backend xác định usage qua contract |

Đây là kế hoạch test, **chưa thực thi hoặc ghi PASS**.

## E. Dependency V03/V04/Admin CRUD

| Task | Gate tối thiểu | Phần chưa cần để làm mock riêng |
| --- | --- | --- |
| V03a navigation/candidate | Payload ID/code, candidate đúng phiên, đích Cart, thiếu context/Back/cancel theo P2 | Lifecycle quota/TTL cụ thể không chặn navigation-only mock |
| V03b apply mock | Loại/rule/formula được duyệt; một voucher hay stacking; quota configurable và mapping còn lượt; thay/bỏ; DTO/errors/fixtures | Có thể inject kết quả mock đã duyệt, không tự implement quota engine |
| V04 Cart/Checkout/COD quote | Totals/context/version/expiry/snapshot, P0-03 revalidation | Tích hợp thật cần contract Backend order/idempotency/payment/usage |
| Admin CRUD/publish | Typed config/limits/validity, full/capped copy, publish validation/permission | Backend bảo đảm uniqueness/version/concurrency; không phát từng user |

V03a không giả Apply thành công khi chỉ nối navigation. V03b chưa bắt đầu khi rule/result fixtures chưa được duyệt; mock không đồng nghĩa API integration.

## F. Quyết định tối thiểu cần chốt

### Trước V03a - nhóm nghiệp vụ/FE

- Chốt chi tiết điều hướng khi thiếu context ngoài selected lines, Back/cancel và đích trở về theo UI P2.
- Chốt payload/candidate lifetime theo phiên cho navigation. Trải nghiệm Dùng ngay không nhập lại và chưa chọn dòng về Cart đã xác nhận, không yêu cầu duyệt lại.

### Trước V03b - nhóm nghiệp vụ và contract hiển thị

- Chọn loại evaluate trong đợt đầu, công thức fixed/percent/full-ship/capped-ship; scope/min/cap/rounding.
- Duyệt hoặc điều chỉnh **một voucher tổng cộng/đơn - PROPOSED**.
- Quota cấu hình global/perCustomer và cách render “đã dùng nhưng còn lượt” theo availability server.
- Duyệt thay/bỏ voucher, partial totals, eligibility/errors và fixture outcomes; ID/code normalization.
- Gift/first-order thiếu rule vẫn chỉ hiển thị mock; không cần phục hồi evaluator chưa có đặc tả.

### Trước tích hợp quote/order thực - Backend cùng nhóm

- CartItem/Variant identities/versions, principal/ownership, authoritative totals/shipping scope.
- Usage/availability và trigger ghi nhận/hoàn lượt; **COD confirm tách COD collected, chưa chọn trigger**.
- Atomic quota/order/idempotency/recovery, verified payment/cancel/late-paid.
- Quote storage/version/expiry/guarantees, **không TTL cố định**.
- Snapshot/public-private/error semantics, policy đơn tổng 0đ.

Các phương án mới vẫn chưa được duyệt; kiến trúc được chấp nhận không biến mọi rule thành APPROVED. Chỉ cập nhật proposal và ghi chú roadmap liên quan. Không sửa Flutter/tests/Backend/Database/Figma/LEN50, không triển khai V03 hoặc Cart Merge.

Không chạy analyze/tests cho lượt tài liệu; 669 PASS là baseline V02a đã nghiệm thu, không phải kết quả chạy mới.
