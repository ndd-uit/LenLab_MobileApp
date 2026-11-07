import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../app/admin_destination.dart';
import '../../app/admin_scope.dart';
import 'admin_styles.dart';
import 'admin_sidebar_item.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.selected,
    required this.onSelect,
  });
  final AdminDestination selected;
  final ValueChanged<AdminDestination> onSelect;

  Widget item(
    AdminDestination destination,
    String label,
    String asset, {
    bool group = false,
    Widget? trailing,
  }) {
    final active = group
        ? selected == AdminDestination.dashboard ||
              selected == AdminDestination.appearance
        : destination == AdminDestination.products
        ? productGroup
        : destination == AdminDestination.conversations
        ? conversationGroup
        : destination == AdminDestination.percentageCoupon
        ? couponGroup
        : selected == destination;
    return Semantics(
      key: ValueKey('admin-nav-${destination.name}'),
      selected: active,
      button: true,
      child: Material(
        color: active ? sidebarSelection : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => onSelect(destination),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                AdminSidebarIcon(asset, active: active),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: active ? sidebarActiveInk : sidebarInk,
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget subitem(
    AdminDestination destination,
    String label, {
    String? keyName,
  }) => AdminSidebarSubitem(
    buttonKey: keyName == null ? null : ValueKey(keyName),
    label: label,
    active: selected == destination,
    onPressed: () => onSelect(destination),
  );

  Widget group(List<Widget> children) => Padding(
    padding: const EdgeInsets.only(left: 36, top: 4, bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(height: 4),
          children[index],
        ],
      ],
    ),
  );

  bool get productGroup =>
      [AdminDestination.products, AdminDestination.reviews].contains(selected);
  bool get couponGroup =>
      selected == AdminDestination.percentageCoupon ||
      selected == AdminDestination.fixedCoupon;
  bool get conversationGroup =>
      selected == AdminDestination.conversations ||
      selected == AdminDestination.chatbot;

  @override
  Widget build(BuildContext context) => Container(
    width: 256,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: P2.border)),
    ),
    child: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: InkWell(
              onTap: () => onSelect(AdminDestination.dashboard),
              borderRadius: BorderRadius.circular(8),
              child: Semantics(
                button: true,
                label: 'LENLAB, về tổng quan',
                child: ExcludeSemantics(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: P2.terracotta,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: adminAsset('imgContainer', 13.395, 13.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'LENLAB',
                          style: TextStyle(
                            color: adminActive,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                item(
                  AdminDestination.dashboard,
                  'Tổng quan',
                  'imgContainer1',
                  group: true,
                ),
                group([
                  subitem(AdminDestination.dashboard, 'Bảng điều khiển'),
                  subitem(AdminDestination.appearance, 'Giao diện'),
                ]),
                item(AdminDestination.products, 'Sản phẩm', 'imgContainer2'),
                if (productGroup)
                  group([
                    subitem(
                      AdminDestination.reviews,
                      'Đánh giá',
                      keyName: 'admin-nav-reviews',
                    ),
                  ]),
                const SizedBox(height: 4),
                item(
                  AdminDestination.orders,
                  'Đơn hàng',
                  'imgContainer3',
                  trailing: Tooltip(
                    message: '3 đơn hàng — số minh họa P2',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Color(0xFF1C1510),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                item(
                  AdminDestination.conversations,
                  'Hội thoại',
                  'imgContainer4',
                ),
                if (conversationGroup)
                  group([
                    subitem(
                      AdminDestination.conversations,
                      'Tin nhắn khách hàng',
                    ),
                    subitem(
                      AdminDestination.chatbot,
                      'Kịch bản Chatbot',
                      keyName: 'admin-nav-chatbot',
                    ),
                  ]),
                const SizedBox(height: 4),
                item(AdminDestination.customers, 'Khách hàng', 'imgContainer5'),
                const SizedBox(height: 4),
                item(
                  AdminDestination.percentageCoupon,
                  'Mã giảm giá',
                  'imgContainer6',
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 24, 12, 12),
                  child: Text(
                    'HỆ THỐNG',
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      letterSpacing: .6,
                      fontWeight: FontWeight.w600,
                      color: adminText,
                    ),
                  ),
                ),
                item(
                  AdminDestination.settings,
                  'Cấu hình chung',
                  'imgContainer7',
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: P2.border)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
            child: Tooltip(
              message: 'Phiên tài khoản admin mock',
              child: Row(
                children: [
                  ClipOval(child: adminAsset('imgAdminUser', 32, 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AdminScope.of(context).user?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: adminHeading,
                          ),
                        ),
                        Text(
                          AdminScope.of(context).user?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: adminText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đăng xuất',
                    onPressed: () {
                      final navigator = Navigator.of(context);
                      AdminScope.of(context).signOut();
                      navigator.pushNamedAndRemoveUntil('/login', (_) => false);
                    },
                    icon: const AdminSidebarIcon('imgContainer8'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
