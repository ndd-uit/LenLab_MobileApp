import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

import '../../../../shared/widgets/admin_list_styles.dart';

const productInk = adminListInk;
const productMuted = adminListMuted;
const productBorder = adminListBorder;
const productAccent = Color(0xFFD1A272);

Widget productAsset(String alias, double width, double height) =>
    P2Asset.node('2026:6669', alias, width: width, height: height);

String productMoney(int value) => adminListMoney(value);

BoxDecoration productSurface() => adminListSurface();
