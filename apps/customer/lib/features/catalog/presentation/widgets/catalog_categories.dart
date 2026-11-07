import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../catalog_styles.dart';

class CatalogCategories extends StatelessWidget {
  const CatalogCategories({
    super.key,
    this.labels = catalogCategoryLabels,
    required this.value,
    required this.onChanged,
    required this.onFilter,
  });
  final List<String> labels;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 2),
    child: Row(
      children: [
        const SizedBox(width: 16),
        InkWell(
          onTap: onFilter,
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 44,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: P2.rose, width: 2),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  children: [
                    P2Asset.node(
                      catalogNode,
                      'imgContainer4',
                      width: 15,
                      height: 15,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Lọc',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          width: 1,
          height: 24,
          color: P2.rose,
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final category in labels)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Semantics(
                      selected: value == category,
                      button: true,
                      child: InkWell(
                        onTap: () => onChanged(category),
                        borderRadius: BorderRadius.circular(99),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: value == category
                                  ? P2.rose
                                  : [
                                      'Thời trang',
                                      'Decor',
                                      'Combo tiết kiệm',
                                    ].contains(category)
                                  ? P2.productCardButton
                                  : P2.categoryButton,
                              borderRadius: BorderRadius.circular(99),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x30000000),
                                  offset: Offset(0, 4),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 14,
                                height: 20 / 14,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                                color: value == category
                                    ? const Color(0xFF523A30)
                                    : const Color(0xFFD1D5DB),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
