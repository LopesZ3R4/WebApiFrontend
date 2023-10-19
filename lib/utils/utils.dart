// lib/utils/utils.dart
import 'package:flutter/material.dart';

import '../model/warning.dart';

Map<String, int> countWarningsByColor(List<Warning> warnings) {
  Map<String, int> warningCounts = {};
  for (var warning in warnings) {
    if (warningCounts.containsKey(warning.color)) {
      warningCounts[warning.color] = warningCounts[warning.color]! + 1;
    } else {
      warningCounts[warning.color] = 1;
    }
  }
  return warningCounts;
}

Widget buildFilterChip(String label, String? value, Function() onRemove, Function() onDeleted) {
  return value != null
      ? Chip(
          label: Text('$label: $value'),
          deleteIcon: const Icon(Icons.close),
          onDeleted: () {
            onRemove();
            onDeleted();
          },
        )
      : Container();
}

  Color getColorFromWarning(String color) {
    switch (color.toUpperCase()) {
      case 'RED':
        return const Color(0xFFF2392D);
      case 'YELLOW':
        return const Color(0xFFFECC1C);
      case 'BLUE':
        return const Color(0xFF3E74FE);
      default:
        return Colors.black;
    }
  }