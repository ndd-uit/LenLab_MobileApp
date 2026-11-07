import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'asset_files.dart';
import 'theme.dart';

const gap = SizedBox(height: 16);
const smallGap = SizedBox(height: 8);

class P2Asset extends StatelessWidget {
  const P2Asset(
    this.file, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.label,
  });
  factory P2Asset.node(
    String node,
    String name, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    String? label,
  }) => P2Asset(
    p2AssetFiles[node]![name]!,
    width: width,
    height: height,
    fit: fit,
    label: label,
  );
  final String file;
  final double? width, height;
  final double radius;
  final BoxFit fit;
  final String? label;
  @override
  Widget build(BuildContext context) {
    final path = 'assets/figma/$file';
    final child = file.endsWith('.svg')
        ? SvgPicture.asset(
            path,
            package: 'lenlab_shared',
            width: width,
            height: height,
            fit: fit,
            semanticsLabel: label,
          )
        : Image.asset(
            path,
            package: 'lenlab_shared',
            width: width,
            height: height,
            fit: fit,
            semanticLabel: label,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
          );
    return radius == 0
        ? child
        : ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }
}

class P2Button extends StatelessWidget {
  const P2Button(
    this.label, {
    super.key,
    required this.onPressed,
    this.busy = false,
    this.outline = false,
    this.color,
    this.icon,
    this.full = true,
    this.leading,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool busy, outline, full;
  final Color? color;
  final IconData? icon;
  final Widget? leading;
  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (busy)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (leading != null)
          leading!
        else if (icon != null)
          Icon(icon, size: 18),
        if (busy || icon != null || leading != null) const SizedBox(width: 8),
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    final button = outline
        ? OutlinedButton(onPressed: busy ? null : onPressed, child: content)
        : ElevatedButton(
            style: color == null
                ? null
                : ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: busy ? null : onPressed,
            child: content,
          );
    return full ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.color = P2.green});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

class Notice extends StatelessWidget {
  const Notice(this.text, {super.key, this.error = false, this.action});
  final String text;
  final bool error;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: error ? const Color(0xFFFFE8E5) : const Color(0xFFEAF2E5),
      border: Border.all(color: error ? const Color(0xFFB44735) : P2.green),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(color: error ? const Color(0xFF8A3027) : P2.green),
        ),
        ?action,
      ],
    ),
  );
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel(
    this.title, {
    super.key,
    this.description,
    this.action,
    this.icon = Icons.inventory_2_outlined,
  });
  final String title;
  final String? description;
  final Widget? action;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 56),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: P2.brown),
        gap,
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(description!, textAlign: TextAlign.center),
          ),
        if (action != null)
          Padding(padding: const EdgeInsets.only(top: 20), child: action),
      ],
    ),
  );
}

void toast(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
Future<void> missingSpec(BuildContext context, String feature) =>
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(feature),
        content: const Text(
          'Luồng này chưa có đủ đặc tả hoặc dịch vụ tích hợp. Cần bổ sung trước khi sử dụng thực tế.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
