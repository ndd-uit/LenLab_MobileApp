import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../features/profile/presentation/widgets/profile_avatar.dart';

class DrawerIdentity extends StatelessWidget {
  const DrawerIdentity({super.key, required this.store, required this.open});
  final LenlabStore store;
  final ValueChanged<String> open;
  @override
  Widget build(BuildContext context) {
    if (store.signedIn) {
      final name = store.profile.name.trim();
      return InkWell(
        onTap: () => open('/profile'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0x80EE8C2B),
                        width: 2,
                      ),
                    ),
                    child: ProfileAvatar(
                      file: store.profile.avatar,
                      bytes: store.profile.avatarBytes,
                      size: 48,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF22C55E),
                        border: Border.all(color: P2.rose, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty
                          ? 'Xin chào!'
                          : 'Xin chào, ${name.split(RegExp(r'\s+')).last}',
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF251D13),
                      ),
                    ),
                    const Text(
                      'Khách hàng thân thiết',
                      style: TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w500,
                        color: P2.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(32, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào mừng bạn!',
                style: TextStyle(
                  fontSize: 20,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF251D13),
                ),
              ),
              Text(
                'Khám phá thế giới thủ công ấm áp và bền vững',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: P2.ink,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 27),
          child: Row(
            children: [
              for (final (index, item) in [
                ('Đăng nhập', '/login'),
                ('Đăng ký', '/register'),
              ].indexed) ...[
                if (index > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => open(item.$2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: index == 0
                          ? const Color(0xFF615ECF)
                          : const Color(0xFFD0C8B5),
                      foregroundColor: index == 0
                          ? Colors.white
                          : const Color(0xFF523A30),
                      minimumSize: const Size.fromHeight(44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      elevation: 4,
                      shadowColor: Colors.black26,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      item.$1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: index == 0 ? 12 : 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
