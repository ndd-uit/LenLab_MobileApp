import 'package:lenlab_customer/shared/widgets/selection_mark.dart';
import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class AddressBookCard extends StatelessWidget {
  const AddressBookCard({
    super.key,
    required this.address,
    this.alternateDeleteIcon = false,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });
  final Address address;
  final bool alternateDeleteIcon;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete, onSetDefault;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
    decoration: BoxDecoration(
      color: P2.rose,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        width: address.isDefault ? 2 : 1,
        color: address.isDefault
            ? P2.checkoutButton.withValues(alpha: .2)
            : Colors.transparent,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          offset: Offset(0, address.isDefault ? 4 : 1),
          blurRadius: address.isDefault ? 20 : 2,
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE8DDD0).withValues(alpha: .45),
          ),
          child: P2Asset.node(
            '2026:4234',
            address.isDefault ? 'imgContainer1' : 'imgContainer4',
            width: 16,
            height: address.isDefault ? 18 : 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          address.name,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.25,
                            color: P2.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8DDD0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'MẶC ĐỊNH',
                              style: TextStyle(
                                fontSize: 10,
                                height: 1.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF171411),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    selected: address.isDefault,
                    label: address.isDefault
                        ? 'Địa chỉ mặc định'
                        : 'Địa chỉ đã lưu',
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: OverflowBox(
                        minWidth: 44,
                        maxWidth: 44,
                        minHeight: 44,
                        maxHeight: 44,
                        child: IconButton(
                          tooltip: address.isDefault
                              ? 'Địa chỉ mặc định'
                              : 'Đặt ${address.name} làm mặc định',
                          onPressed: onSetDefault,
                          padding: EdgeInsets.zero,
                          icon: CustomerSelectionMark(
                            selected: address.isDefault,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                address.phone,
                style: const TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                address.full,
                style: const TextStyle(
                  fontSize: 14,
                  height: 22.75 / 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 20,
                children: [
                  _Action('Sửa', 'imgContainer3', 13.5, P2.ink, onTap: onEdit),
                  if (!address.isDefault)
                    _Action(
                      'Xóa',
                      alternateDeleteIcon ? 'imgContainer6' : 'imgContainer5',
                      12,
                      const Color(0xFF7A2929),
                      onTap: onDelete,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Action extends StatelessWidget {
  const _Action(this.label, this.asset, this.width, this.color, {this.onTap});
  final VoidCallback? onTap;
  final String label, asset;
  final double width;
  final Color color;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          P2Asset.node('2026:4234', asset, width: width, height: 13.5),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}
