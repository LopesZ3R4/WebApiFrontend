// lib/utils/icon_utils.dart
import 'package:flutter/widgets.dart';
class IconUtils {
  static const Map<String, String> machineTypeIcons = {
    'Combine': 'icons/Combine.png',
    'Tractor': 'icons/Tractor.png',
    'Gator Utility Vehicle': 'icons/Gator Utility Vehicle.png',
    'Rotary Cutter': 'icons/Rotary Cutter.png',
    'Lawn Mower': 'icons/Lawn Mower.png',
    'Crawler Dozer': 'icons/Crawler Dozer.png',
    'Excavator': 'icons/Excavator.png',
    'Backhoe Loader': 'icons/Backhoe_Loader.png',
  };

  static Image getIconForMachineType(String machineType) {
    String iconPath = machineTypeIcons[machineType] ?? 'icons/broken.png';
    return Image.asset(iconPath, width: 62, height: 62);
  }
}