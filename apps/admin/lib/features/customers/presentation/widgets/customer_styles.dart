import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

export '../../../../shared/widgets/admin_list_styles.dart';

const customerAccent = Color(0xFFD1A272);
Widget customerAsset(String alias, double width, double height) =>
    P2Asset.node('2026:8502', alias, width: width, height: height);
