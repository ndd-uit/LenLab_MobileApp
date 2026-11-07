import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const profileEditorNode = '2026:3961';
InputDecoration profileEditorDecoration({
  String? hint,
  String? icon,
  double width = 15,
  double height = 15,
  bool filled = false,
  Widget? suffix,
}) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF523A30)),
  filled: true,
  fillColor: filled
      ? P2.rose.withValues(alpha: .65)
      : Colors.white.withValues(alpha: .05),
  contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),
    borderSide: BorderSide(color: filled ? Colors.transparent : P2.brown),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),
    borderSide: BorderSide(color: filled ? Colors.transparent : P2.brown),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(24),
    borderSide: const BorderSide(color: P2.ink),
  ),
  suffixIcon:
      suffix ??
      (icon == null
          ? null
          : SizedBox(
              width: 44,
              child: Center(
                child: P2Asset.node(
                  profileEditorNode,
                  icon,
                  width: width,
                  height: height,
                ),
              ),
            )),
  suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
);

class ProfileEditorField extends StatelessWidget {
  const ProfileEditorField({
    super.key,
    required this.label,
    required this.child,
  });
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: P2.brown,
          ),
        ),
      ),
      child,
    ],
  );
}

class ProfilePasswordPlaceholder extends StatelessWidget {
  const ProfilePasswordPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Đổi mật khẩu',
              style: TextStyle(fontSize: 14, color: P2.brown),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: P2.rose.withValues(alpha: .65),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'Bảo mật',
              style: TextStyle(fontSize: 12, color: P2.brown),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: P2.rose.withValues(alpha: .65),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            for (final item in <(String, String, double, double)>[
              ('Mật khẩu hiện tại', 'imgContainer2', 18.333, 12.5),
              ('Mật khẩu mới', 'imgContainer3', 18.333, 16.5),
              ('Nhập lại mật khẩu mới', 'imgIcon3', 16.667, 16.667),
            ])
              Padding(
                padding: EdgeInsets.only(
                  bottom: item.$1 == 'Nhập lại mật khẩu mới' ? 0 : 12,
                ),
                child: Semantics(
                  button: true,
                  child: InkWell(
                    onTap: () => missingSpec(context, 'Đổi mật khẩu'),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: P2.cream.withValues(alpha: .9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.$1,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF523A30),
                              ),
                            ),
                          ),
                          P2Asset.node(
                            profileEditorNode,
                            item.$2,
                            width: item.$3,
                            height: item.$4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
