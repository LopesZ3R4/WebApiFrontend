// lib/utils/utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/warning.dart';
import 'icon_utils.dart';

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

Map<String, int> countWarningsByMachineType(List<Warning> warnings) {
  return warnings.fold<Map<String, int>>({}, (map, warning) {
    map[warning.machineType] = (map[warning.machineType] ?? 0) + 1;
    return map;
  });
}

Widget buildFilterChip(
    String label, String? value, Function() onRemove, Function() onDeleted) {
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

Widget buildMachineTypeFilter(
    Set<String> machineTypeItems,
    Map<String, int> countWarningsByMachineType,
    Function(String) onMachineTypeSelected) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: machineTypeItems.map((machineType) {
        return InkWell(
          child: Stack(
            children: <Widget>[
              IconUtils.getIconForMachineType(machineType),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    '${countWarningsByMachineType[machineType] ?? 0}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onTap: () => onMachineTypeSelected(machineType),
        );
      }).toList(),
    ),
  );
}

Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  required DateTime initialDate,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
}

Widget buildDatePickerButton({
  required String label,
  required DateTime date,
  required VoidCallback onPressed,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
    onPressed: onPressed,
    child: Text(
      '$label: ${DateFormat('dd/MM/yyyy').format(date)}',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
  );
}
