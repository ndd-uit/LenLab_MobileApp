import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.file, this.bytes, this.size = 112});
  final String? file;
  final Uint8List? bytes;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black12, offset: Offset(0, 12), blurRadius: 20),
      ],
    ),
    child: bytes != null
        ? ClipOval(
            child: Image.memory(
              bytes!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                  .ceil(),
              gaplessPlayback: true,
              semanticLabel: 'Ảnh đại diện',
              errorBuilder: (_, error, stack) =>
                  const Icon(Icons.person_outline, color: P2.brown),
            ),
          )
        : file == null
        ? P2Asset.node(
            '2026:244',
            'imgContainer',
            width: 42.667,
            height: 42.667,
          )
        : ClipOval(
            child: P2Asset(
              file!,
              width: size,
              height: size,
              label: 'Ảnh đại diện mẫu',
            ),
          ),
  );
}
