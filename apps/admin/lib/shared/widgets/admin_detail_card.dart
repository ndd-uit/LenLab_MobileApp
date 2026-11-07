import 'package:flutter/material.dart';

import 'admin_list_styles.dart';

class AdminDetailCard extends StatelessWidget {
  const AdminDetailCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });
  final String title;
  final Widget icon, child;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Container(
    decoration: adminListSurface(),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: adminListBorder)),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                    color: adminListInk,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        child,
      ],
    ),
  );
}
