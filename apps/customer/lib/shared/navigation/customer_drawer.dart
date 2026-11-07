import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../app/customer_scope.dart';
import '../../app/navigation.dart';
import 'widgets/drawer_identity.dart';
import 'widgets/drawer_footer.dart';
import 'widgets/drawer_entry.dart';

class CustomerDrawer extends StatelessWidget {
  const CustomerDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final store = CustomerScope.of(context);
    final node = store.signedIn ? '2026:338' : '2026:413';
    void open(String route) {
      Navigator.pop(context);
      if (route == '/') {
        home(context);
      } else {
        go(context, route);
      }
    }

    return Drawer(
      width: (MediaQuery.sizeOf(context).width * .85).clamp(0, 390).toDouble(),
      backgroundColor: P2.cream,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -128,
            top: -128,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                child: Container(
                  width: 256,
                  height: 256,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEE8C2B).withValues(alpha: .1),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          'Menu',
                          style: P2
                              .serif(18, weight: FontWeight.w700)
                              .copyWith(height: 1.25, letterSpacing: -.27),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 4,
                        child: IconButton(
                          tooltip: 'Đóng menu',
                          onPressed: () => Navigator.pop(context),
                          constraints: const BoxConstraints.tightFor(
                            width: 48,
                            height: 48,
                          ),
                          icon: P2Asset.node(
                            node,
                            store.signedIn ? 'imgContainer8' : 'imgContainer7',
                            width: 16.333,
                            height: 16.333,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    key: const ValueKey('drawer-scroll'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DrawerIdentity(store: store, open: open),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          child: Column(
                            children: [
                              for (
                                var index = 0;
                                index < drawerEntries.length;
                                index++
                              ) ...[
                                if (index > 0) const SizedBox(height: 8),
                                DrawerEntry(
                                  index: index,
                                  open: open,
                                  node: node,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DrawerFooter(
                  signedIn: store.signedIn,
                  open: open,
                  logout: () {
                    store.logout();
                    Navigator.pop(context);
                    home(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
