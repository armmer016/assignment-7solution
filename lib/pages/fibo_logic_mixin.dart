import 'package:flutter/material.dart';
import 'package:git7assignment/enum/fibo_type.dart';

mixin FiboLogicMixin {
  FiboType getType(int n) {
    switch (n % 3) {
      case 0:
        return FiboType.circle;
      case 1:
        return FiboType.cross;
      default:
        return FiboType.square;
    }
  }

  IconData iconFor(FiboType t) {
    switch (t) {
      case FiboType.cross:
        return Icons.close;
      case FiboType.square:
        return Icons.crop_square;
      case FiboType.circle:
        return Icons.circle_outlined;
    }
  }

  List<int> generateFib(int count) {
    final list = <int>[0, 1];
    while (list.length < count) {
      list.add(list[list.length - 1] + list[list.length - 2]);
    }
    return list.take(count).toList();
  }
}
