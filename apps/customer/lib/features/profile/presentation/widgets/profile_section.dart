import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class ProfileEntry {
  const ProfileEntry(
    this.title,
    this.asset,
    this.width,
    this.onTap, {
    this.white = false,
  });
  final String title, asset;
  final double width;
  final VoidCallback onTap;
  final bool white;
}

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key, required this.title, required this.entries});
  final String title;
  final List<ProfileEntry> entries;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            height: 20 / 18,
            letterSpacing: .7,
            fontWeight: FontWeight.w600,
            color: Color(0xFF523A30),
          ),
        ),
      ),
      Material(
        color: P2.rose,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, thickness: 1, color: Colors.white),
              InkWell(
                onTap: entries[i].onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: entries[i].white
                              ? (i == 0
                                    ? Colors.white.withValues(alpha: .59)
                                    : Colors.white)
                              : const Color(0xFFEFE2DB),
                        ),
                        child: P2Asset.node(
                          '2026:244',
                          entries[i].asset,
                          width: entries[i].width,
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          entries[i].title,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF523A30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      P2Asset.node(
                        '2026:244',
                        'imgContainer2',
                        width: 9.813,
                        height: 16.667,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}
