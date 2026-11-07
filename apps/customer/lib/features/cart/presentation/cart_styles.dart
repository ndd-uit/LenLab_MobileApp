import 'package:lenlab_shared/lenlab_shared.dart';
import 'package:flutter/material.dart';

const cartNode = '2026:1325';
const cartDark = Color(0xFF523419);
Widget cartAsset(String name, double width, double height) =>
    P2Asset.node(cartNode, name, width: width, height: height);
