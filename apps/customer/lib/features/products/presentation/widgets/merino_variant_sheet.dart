import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const _ink = Color(0xFF523629);
const _border = Color(0xFFDBBAA8);

class MerinoSelection {
  const MerinoSelection(this.color, this.size, this.quantity);
  final String color, size;
  final int quantity;
  String get variant => '$color · $size';
}

/// P2 2034:5. "Be" is the display label for the existing "Kem" cart key.
class MerinoVariantSheet extends StatefulWidget {
  const MerinoVariantSheet({
    super.key,
    required this.product,
    required this.initial,
    required this.existingQuantity,
    required this.onConfirm,
  });
  final Product product;
  final MerinoSelection initial;
  final int Function(String variant) existingQuantity;
  final bool Function(MerinoSelection selection) onConfirm;
  @override
  State<MerinoVariantSheet> createState() => _MerinoVariantSheetState();
}

class _MerinoVariantSheetState extends State<MerinoVariantSheet> {
  late String color = widget.initial.color, size = widget.initial.size;
  late int quantity = widget.initial.quantity;
  String? error;
  String get displayColor => color == 'Kem' ? 'Be tự nhiên' : color;
  String get displaySize => size.replaceAll('cm', ' cm');
  int get available =>
      widget.product.stock - widget.existingQuantity('$color · $size');

  Widget text(String value, double fontSize, {bool bold = false}) => Text(
    value,
    style: TextStyle(
      fontSize: fontSize,
      height: 1.5,
      color: _ink,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    ),
  );

  Widget option(
    String label,
    bool selected,
    VoidCallback onPressed, {
    bool strongBorder = false,
  }) => Semantics(
    selected: selected,
    button: true,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _ink,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        side: BorderSide(color: selected || strongBorder ? _ink : _border),
        shape: const StadiumBorder(),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'packages/lenlab_shared/BeVietnamPro',
                fontSize: 13,
                height: 20 / 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          if (selected)
            const Padding(
              padding: EdgeInsets.only(left: 3),
              child: Icon(Icons.check, size: 13, color: _ink),
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          text('Chọn sản phẩm', 20, bold: true),
          const SizedBox(height: 12),
          text(widget.product.name, 16, bold: true),
          const SizedBox(height: 12),
          text(
            '${money(widget.product.price)} · ${widget.product.stock > 0 ? 'Còn hàng' : 'Hết hàng'}',
            14,
          ),
          const SizedBox(height: 12),
          text('Màu sắc: $displayColor', 14, bold: true),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              final children = [
                for (final entry in [
                  ('Kem', 'Be'),
                  ('Nâu', 'Nâu'),
                  ('Xám', 'Xám'),
                ])
                  option(
                    entry.$2,
                    color == entry.$1,
                    () => setState(() {
                      color = entry.$1;
                      error = null;
                    }),
                  ),
              ];
              return c.maxWidth >= 300 &&
                      MediaQuery.textScalerOf(context).scale(13) <= 15
                  ? Row(
                      children: [
                        for (var i = 0; i < children.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(child: children[i]),
                        ],
                      ],
                    )
                  : Wrap(spacing: 8, runSpacing: 8, children: children);
            },
          ),
          const SizedBox(height: 12),
          text('Kích thước: $displaySize', 14, bold: true),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final value in ['180cm', '200cm']) ...[
                if (value == '200cm') const SizedBox(width: 12),
                Expanded(
                  child: option(
                    value.replaceAll('cm', ' cm'),
                    size == value,
                    () => setState(() {
                      size = value;
                      error = null;
                    }),
                    strongBorder: true,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              text('Số lượng', 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _step(
                    'Giảm số lượng',
                    '−',
                    quantity > 1
                        ? () => setState(() {
                            quantity--;
                            error = null;
                          })
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: _border),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: text('$quantity', 16, bold: true),
                  ),
                  const SizedBox(width: 12),
                  _step(
                    'Tăng số lượng',
                    '+',
                    quantity < available
                        ? () => setState(() {
                            quantity++;
                            error = null;
                          })
                        : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          text('$displayColor · $displaySize · $quantity sản phẩm', 12),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                error!,
                style: const TextStyle(color: Color(0xFF7A2929)),
              ),
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            key: const ValueKey('variant-confirm'),
            onPressed: widget.product.stock <= 0
                ? null
                : () {
                    if (quantity > available) {
                      setState(
                        () =>
                            error = 'Số lượng trong giỏ vượt tồn kho hiện có.',
                      );
                      return;
                    }
                    final selection = MerinoSelection(color, size, quantity);
                    if (widget.onConfirm(selection)) {
                      Navigator.pop(context, selection);
                    } else {
                      setState(
                        () => error = 'Hiện chưa thể thêm sản phẩm. Vui lòng quay lại và thử lại.',
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDBA324),
              foregroundColor: const Color(0xFF4D2B1A),
              minimumSize: const Size.fromHeight(48),
              elevation: 0,
              textStyle: const TextStyle(
                fontFamily: 'packages/lenlab_shared/BeVietnamPro',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Thêm vào giỏ · ${money(widget.product.price * quantity)}',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4D2B1A),
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Color(0xFF4D2B1A)),
              textStyle: const TextStyle(
                fontFamily: 'packages/lenlab_shared/BeVietnamPro',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: const Text('Hủy lựa chọn'),
          ),
        ],
      ),
    ),
  );

  Widget _step(String label, String glyph, VoidCallback? onPressed) => SizedBox(
    width: 48,
    height: 44,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(48, 44),
        foregroundColor: _ink,
        side: const BorderSide(color: _border),
      ),
      child: Semantics(
        label: label,
        excludeSemantics: true,
        child: Text(
          glyph,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    ),
  );
}
