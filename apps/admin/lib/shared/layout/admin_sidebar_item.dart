import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const sidebarInk = Color(0xFF475469);
const sidebarActiveInk = Color(0xFF663D1F);
const sidebarSelection = Color(0xFFF7EBDE);
const sidebarIconInk = Color(0xFF9CA3AF);
const sidebarSubitemText = TextStyle(
  fontFamily: 'packages/lenlab_shared/Inter',
  fontSize: 14,
  height: 20 / 14,
  letterSpacing: 0,
  fontWeight: FontWeight.w400,
);

/// All navigation icons come from the same P2 sidebar and occupy one 24px slot.
class AdminSidebarIcon extends StatelessWidget {
  const AdminSidebarIcon(this.asset, {super.key, this.active = false});
  final String asset;
  final bool active;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 24,
    height: 24,
    child: Center(
      child: ExcludeSemantics(
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            active ? sidebarActiveInk : sidebarIconInk,
            BlendMode.srcIn,
          ),
          child: P2Asset.node('2038:9', asset, width: 20, height: 20),
        ),
      ),
    ),
  );
}

class AdminSidebarSubitem extends StatelessWidget {
  const AdminSidebarSubitem({
    super.key,
    required this.label,
    required this.active,
    required this.onPressed,
    this.buttonKey,
    this.tooltip,
  });
  final String label;
  final bool active;
  final VoidCallback? onPressed;
  final Key? buttonKey;
  final String? tooltip;
  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      selected: active,
      child: TextButton(
        key: buttonKey,
        onPressed: onPressed,
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          foregroundColor: active ? sidebarActiveInk : sidebarInk,
          disabledForegroundColor: const Color(0xFF6B7280),
          backgroundColor: Colors.transparent,
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          visualDensity: VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          strutStyle: StrutStyle.fromTextStyle(
            sidebarSubitemText,
            forceStrutHeight: true,
          ),
          style: sidebarSubitemText.copyWith(
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
