import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../../app/navigation.dart';
import '../../../../app/auth_return_intent.dart';
import '../../../../app/customer_scope.dart';

/// Compact light variant approved by the project owner after the P2 preview.
class GuestCartPrompt extends StatelessWidget {
  const GuestCartPrompt({super.key, required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          namesRoute: true,
          label: 'Đăng nhập giỏ hàng',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Container(
              decoration: BoxDecoration(
                color: P2.cream,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: P2.rose),
                boxShadow: [
                  BoxShadow(
                    color: P2.brown.withValues(alpha: .14),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: P2.rose.withValues(alpha: .5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: P2.brown,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Bạn chưa đăng nhập?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                            color: P2.ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Đăng nhập hoặc tạo tài khoản để tiếp tục mua sắm cùng LENLAB.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: P2.brown,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => go(
                            context,
                            '/login',
                            AuthReturnIntent.forRoute(
                              CustomerScope.of(context),
                              '/checkout',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: P2.checkoutButton,
                            foregroundColor: P2.ink,
                            minimumSize: const Size.fromHeight(48),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Đăng nhập / Đăng ký',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: onDismiss,
                          style: TextButton.styleFrom(
                            foregroundColor: P2.brown,
                            minimumSize: const Size.fromHeight(44),
                          ),
                          child: const Text(
                            'Để sau',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: IconButton(
                      tooltip: 'Đóng nhắc đăng nhập',
                      onPressed: onDismiss,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: P2.brown,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
