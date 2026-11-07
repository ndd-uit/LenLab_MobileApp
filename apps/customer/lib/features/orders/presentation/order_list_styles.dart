import 'package:flutter/material.dart';
import 'package:lenlab_shared/lenlab_shared.dart';

const orderListNode = '2026:1852';
const orderListText = Color(0xFF523A30);
const orderListRed = Color(0xFF7A2929);

TextStyle orderListType(
  double size, {
  Color color = orderListText,
  FontWeight weight = FontWeight.w400,
  bool serif = false,
  double height = 1.333,
}) => TextStyle(
  fontFamily:
      'packages/lenlab_shared/${serif ? 'PlayfairDisplay' : 'BeVietnamPro'}',
  fontSize: size,
  color: color,
  fontWeight: weight,
  height: height,
);

Color orderListStatusColor(OrderState state) => switch (state) {
  OrderState.shipping => P2.green,
  OrderState.cancelled => orderListRed,
  OrderState.pending || OrderState.processing => P2.ink,
  OrderState.delivered => P2.brown,
};
