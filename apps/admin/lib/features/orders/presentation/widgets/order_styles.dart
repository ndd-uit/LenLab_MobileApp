import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

export '../../../../shared/widgets/admin_list_styles.dart';

const orderAccent = Color(0xFFE09F56);
Widget orderAsset(String alias, double width, double height) =>
    P2Asset.node('2026:7027', alias, width: width, height: height);

String orderDate(DateTime? date) => date == null
    ? 'Chưa có ngày đặt'
    : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
