# P0-04 - Đợt 3: Data ownership và session isolation

Ngày bàn giao: 05/11/2026. Chỉ đợt 3, dừng chờ nghiệm thu trước đợt 4. Dữ liệu và identity đều trong RAM; không Backend/API/database/persistence. Giữ ChangeNotifier, CustomerScope và routing hiện có.

## 3A - Dữ liệu tài khoản đã lưu

| Dữ liệu | Ownership và hành vi |
| --- | --- |
| Profile/avatar | Account map theo user ID. Fixture cũ thuộc `customer-demo-a`. B/người đăng ký mới dùng danh tính riêng, không nhận avatar, ngày sinh hoặc thông tin A. |
| Saved addresses | Mỗi record có owner ID; create gán người thực hiện, update/delete/default kiểm tra owner và membership. Không nhận record lưu không rõ owner hoặc thuộc tài khoản khác. |
| Orders/detail/receipt | Fixture khai báo owner A tường minh. Source gắn owner, Store chỉ tìm đơn hiện tại theo ID trong account; truyền ID hoặc Order A vào B không mở được dữ liệu A. |
| Guest | Không có saved orders/addresses/favorites/Custom hoặc profile fixture riêng. Các private source vẫn yêu cầu đăng nhập. |

Account map không lấy người đăng nhập đầu tiên làm chủ fixture. B đăng nhập trước cũng không kế thừa A. Logout/chuyển tài khoản giữ dữ liệu tài khoản đã lưu, A quay lại vẫn đọc đúng dữ liệu A. List/set riêng được trả qua view gắn user ID và generation; giữ view A rồi chuyển B hoặc đăng nhập lại A không thể dùng view cũ để thay đổi collection. Record owner sai/không xác định bị từ chối khi chèn vào collection riêng.

Source guards bao gồm order list/detail, profile load/save, checkout address load/save, address book load/create/update/delete/default và buy-again. Mua lại tiếp tục mở detail catalog để chọn lại, không tự thêm giỏ.

## 3B - Review, draft và dữ liệu riêng còn lại

- Review dùng `authorId = userId`, quyền từ đơn đã giao thuộc account hiện tại, sản phẩm thuộc đơn, một lần/đơn/sản phẩm. Sửa email không thay quyền hoặc mở lại lượt đánh giá. Guest vẫn đọc review công khai; review lịch sử không rõ author ID không tự gán cho người đăng nhập.
- Favorites và các fixture Custom nằm trong account riêng. Guest bấm favorite được yêu cầu Auth, không replay thao tác. Return intent dùng ID sản phẩm chuẩn qua route `/product` hiện có, không tạo route hoặc sản phẩm giả.
- Checkout draft chứa owner/generation, địa chỉ chọn, ghi chú, phương thức và mã tham chiếu tạm; reset khi đổi phiên/logout. Saved address và snapshot đơn không bị xóa theo draft. Không mang object địa chỉ hoặc receipt A vào B.
- Ví voucher cá nhân chỉ đọc: fixture cũ được scope tường minh cho A; B/người đăng ký mới không nhận trạng thái used/available của A. Không triển khai hoặc thay quy tắc áp mã/CRUD voucher. Coupon mẫu của giỏ vẫn giữ hành vi hiện có, chưa chuyển ownership của giỏ.
- Avatar và ảnh review chưa upload. Kết quả picker cũ bị bỏ qua nếu user ID/generation đổi. Ảnh recovery native sau app restart không có owner RAM xác minh được nên không tự gán cho người đăng nhập đầu tiên; recovery adapter được inject cho một phiên vẫn kiểm tra stamp. Không thêm persistence.

## 3C - Cache, request cũ và COD detached

Private page subtree có key theo user ID + generation: controller, cached source, form và ảnh tạm được tạo lại khi đổi phiên, kể cả A → logout → B xảy ra trước một frame mới. Dialog/sheet nằm trên route riêng dùng session-bound overlay: hết phiên thì ẩn nội dung và đóng khi đang ở trên cùng. Back vào route cũ vẫn đi qua guard và kiểm tra owner.

Private async operations kiểm tra stamp trước/sau await, kể cả ở điểm tiếp tục đọc/ghi sau helper operation. UI callback load/save/picker/navigation kiểm tra mounted và stamp trước khi áp kết quả, lỗi hoặc trạng thái busy. Profile, address, review và checkout không nhận kết quả phiên cũ dù email trùng hoặc A đăng nhập lại cùng ID nhưng generation khác.

COD giữ owner và snapshot của request ban đầu. Logout không hủy request đã gửi. Kết quả phiên cũ vào `_detachedCodResults`, không mở confirmation, sửa draft hoặc lịch sử B. Khi A trở lại, kết quả đúng owner được insert vào lịch sử A nếu chưa có ID, sau đó lấy khỏi queue. Trường hợp A trở lại trước khi request xong cũng được xử lý. Đăng nhập lại nhiều lần không nhân bản đơn.

**Chưa reconcile giỏ cho detached COD:** không xóa dòng giỏ khi kết quả thuộc phiên cũ hoàn tất. Giỏ riêng và xử lý các dòng đã mua của A thuộc đợt 4. COD thành công ngay trong phiên hiện tại vẫn xử lý dòng được chọn theo hành vi P0-03 hiện có. RAM không bảo đảm giữ đơn khi store/app bị hủy.

## Kiểm chứng

Triển khai theo 3A → 3B → 3C và chạy các nhóm test liên quan sau mỗi nhóm, sau đó chạy toàn bộ hồi quy. Bộ test mới bao phủ:

- A/B/người đăng ký mới, B đăng nhập đầu tiên, Guest không có dữ liệu riêng; owner không xác định không được tự gán.
- ID đơn/địa chỉ/receipt A trong B, source A giữ lại và các mutation view cũ bị từ chối.
- Quyền review theo user ID, email thay đổi/trùng không đổi quyền; public review vẫn đọc được.
- Draft reset nhưng saved account data giữ lại; favorites/Custom riêng, giỏ hiện có không đổi ngoài phạm vi.
- Profile load/editor/save, address book/editor/checkout source, save/delete/default đang chờ khi chuyển A → A generation mới hoặc A → B.
- Widget profile/controller, pending avatar/review picker, dialog xóa địa chỉ, receipt cũ khi đổi phiên.
- Detached COD hoàn tất trước/sau A quay lại; đúng owner, đúng một bản ghi, không đưa đơn vào B hoặc tự sửa giỏ.

**638 PASS**: Shared **90**, Customer **367**, Admin **181**; tăng **40 test** so với 598 của đợt 2 (12 Shared, 28 Customer). Analyzer sạch cả ba project. Kết quả JSON nằm trong `build/p0-04-batch3-verified.json` của từng project. P0-01, P0-02, P0-03, route guards đợt 2 và golden tiếp tục đạt. So sánh byte PNG với bản sao trước thay đổi: **0 golden thay đổi**. Fixture tests cũ được bổ sung owner A tường minh hoặc kỳ vọng Guest không đọc private data, không bỏ test để che regression.

Năm file test mới: `customer_ownership_test.dart` (10), `account_cod_isolation_test.dart` (2), `account_sources_ownership_test.dart` (3), `account_async_isolation_test.dart` (20), `account_widget_isolation_test.dart` (5).

Runtime: đã kết nối Dart MCP với DTD của VS Code và thử hot restart; không có app kết nối. Chưa xác minh APK/thiết bị hoặc browser thật. Widget/Navigator tests không thay kiểm thử native picker hoặc Back trên browser thật.

## Giới hạn và Backend

- Không tách/merge/lưu giỏ Guest/A/B, không sửa popup Guest, không reconcile giỏ detached COD; cần đợt 4 đã được phê duyệt sau nghiệm thu này.
- Không triển khai nghiệp vụ Custom mới, voucher, VNPay hoặc Admin CRUD; chỉ scope dữ liệu riêng đang có. Không sửa Figma, theme, layout hay golden.
- Frontend RAM guards không phải ranh giới bảo mật Backend. Các model DTO vẫn là object trong bộ nhớ; API cần tự suy ra owner từ principal và kiểm tra mọi endpoint/mutation, ID đơn/địa chỉ, quyền review và uniqueness.
- Backend phải xác minh lại stock/giá/totals, idempotency tạo đơn và lưu kết quả lâu dài. Không tin owner ID/generation hoặc dữ liệu tiền do Flutter gửi.

Bản sao trước thay đổi: `.design/p0-04-batch-3/before.zip`. Không chỉnh source Admin hoặc dependency.

## File thay đổi

Danh sách dưới đây bao gồm code production, test fixture/hồi quy và tài liệu của riêng đợt 3.

### File Dart m?i

- `apps/customer/lib/app/session_bound_overlay.dart`
- `apps/customer/test/account_async_isolation_test.dart`
- `apps/customer/test/account_sources_ownership_test.dart`
- `apps/customer/test/account_widget_isolation_test.dart`
- `packages/lenlab_shared/lib/src/state/customer_account_data.dart`
- `packages/lenlab_shared/lib/src/state/customer_checkout_draft.dart`
- `packages/lenlab_shared/lib/src/state/session_owned_list.dart`
- `packages/lenlab_shared/test/account_cod_isolation_test.dart`
- `packages/lenlab_shared/test/customer_ownership_test.dart`

### File Dart c?p nh?t

- `apps/customer/lib/app/auth_return_intent.dart`
- `apps/customer/lib/app/customer_app.dart`
- `apps/customer/lib/app/customer_session_gate.dart`
- `apps/customer/lib/features/address_book/data/address_book_actions.dart`
- `apps/customer/lib/features/address_book/data/address_book_source.dart`
- `apps/customer/lib/features/address_book/data/address_editor_source.dart`
- `apps/customer/lib/features/address_book/presentation/address_book_page.dart`
- `apps/customer/lib/features/address_book/presentation/address_editor_page.dart`
- `apps/customer/lib/features/checkout/presentation/address_page.dart`
- `apps/customer/lib/features/checkout/presentation/cod_success_page.dart`
- `apps/customer/lib/features/checkout/presentation/order_review_page.dart`
- `apps/customer/lib/features/checkout/presentation/payment_method_page.dart`
- `apps/customer/lib/features/help/presentation/faq_page.dart`
- `apps/customer/lib/features/help/presentation/widgets/faq_support_card.dart`
- `apps/customer/lib/features/orders/data/buy_again_source.dart`
- `apps/customer/lib/features/orders/presentation/buy_again_dialog.dart`
- `apps/customer/lib/features/products/presentation/product_detail_page.dart`
- `apps/customer/lib/features/profile/data/profile_editor_source.dart`
- `apps/customer/lib/features/profile/presentation/profile_editor_page.dart`
- `apps/customer/lib/features/profile/presentation/profile_page.dart`
- `apps/customer/lib/features/reviews/presentation/post_purchase_review_page.dart`
- `apps/customer/lib/features/vouchers/data/voucher_source.dart`
- `apps/customer/test/about_test.dart`
- `apps/customer/test/address_actions_test.dart`
- `apps/customer/test/address_book_test.dart`
- `apps/customer/test/address_editor_test.dart`
- `apps/customer/test/avatar_test.dart`
- `apps/customer/test/bank_transfer_test.dart`
- `apps/customer/test/buy_again_test.dart`
- `apps/customer/test/cart_selection_test.dart`
- `apps/customer/test/cod_checkout_test.dart`
- `apps/customer/test/cod_validation_test.dart`
- `apps/customer/test/customer_navigation_test.dart`
- `apps/customer/test/customer_route_guards_test.dart`
- `apps/customer/test/drawer_test.dart`
- `apps/customer/test/faq_test.dart`
- `apps/customer/test/guest_cart_test.dart`
- `apps/customer/test/order_detail_test.dart`
- `apps/customer/test/order_list_test.dart`
- `apps/customer/test/order_review_test.dart`
- `apps/customer/test/payment_method_test.dart`
- `apps/customer/test/post_purchase_review_test.dart`
- `apps/customer/test/product_detail_test.dart`
- `apps/customer/test/product_identity_test.dart`
- `apps/customer/test/profile_editor_test.dart`
- `apps/customer/test/profile_test.dart`
- `apps/customer/test/rating_consistency_test.dart`
- `apps/customer/test/reviews_test.dart`
- `apps/customer/test/scope_cleanup_test.dart`
- `apps/customer/test/variant_sheet_test.dart`
- `apps/customer/test/visual_test.dart`
- `packages/lenlab_shared/lib/src/data/address_data.dart`
- `packages/lenlab_shared/lib/src/data/order_detail_data.dart`
- `packages/lenlab_shared/lib/src/data/order_list_data.dart`
- `packages/lenlab_shared/lib/src/domain/models.dart`
- `packages/lenlab_shared/lib/src/state/lenlab_store.dart`
- `packages/lenlab_shared/test/bank_transfer_test.dart`
- `packages/lenlab_shared/test/cart_selection_test.dart`
- `packages/lenlab_shared/test/cod_order_test.dart`
- `packages/lenlab_shared/test/cod_validation_test.dart`
- `packages/lenlab_shared/test/customer_guards_test.dart`
- `packages/lenlab_shared/test/order_detail_test.dart`
- `packages/lenlab_shared/test/order_list_test.dart`
- `packages/lenlab_shared/test/post_purchase_review_test.dart`
- `packages/lenlab_shared/test/product_review_data_test.dart`
- `packages/lenlab_shared/test/repository_test.dart`

### Documentation

- `apps/customer/README.md`
- `docs/P0-04-BATCH-3.md`
