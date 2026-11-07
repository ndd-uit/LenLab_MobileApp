import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class DrawerFooter extends StatelessWidget {
  const DrawerFooter({
    super.key,
    required this.signedIn,
    required this.open,
    required this.logout,
  });
  final bool signedIn;
  final ValueChanged<String> open;
  final VoidCallback logout;
  @override
  Widget build(BuildContext context) => Container(
    color: P2.rose,
    padding: EdgeInsets.fromLTRB(24, signedIn ? 24 : 12, 24, 8),
    child: SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (signedIn) ...[
            ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB4AEA4),
                foregroundColor: const Color(0xFF523A30),
                elevation: 0,
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  P2Asset.node(
                    '2026:338',
                    'imgContainer6',
                    width: 15,
                    height: 15,
                  ),
                  const SizedBox(width: 12),
                  const Flexible(
                    child: Text(
                      'Đăng xuất',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ] else ...[
            const Text(
              'Kết nối với chúng tôi',
              style: TextStyle(
                fontSize: 11,
                color: P2.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                for (final item in [
                  ('Facebook', 'imgSvg'),
                  ('Instagram', 'imgSvg1'),
                ])
                  IconButton(
                    tooltip: item.$1,
                    onPressed: () => missingSpec(context, 'Kênh ${item.$1}'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 44,
                      height: 44,
                    ),
                    icon: Container(
                      width: 30,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: P2.cream,
                        borderRadius: BorderRadius.all(Radius.circular(99)),
                      ),
                      child: P2Asset.node(
                        '2026:413',
                        item.$2,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Phiên bản 1.0.0',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF523A30),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => open('/policies'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF523A30),
                  minimumSize: const Size(56, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  'Điều khoản',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
