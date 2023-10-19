// lib/utils/icon_utils.dart
import 'package:flutter/widgets.dart';

class IconUtils {
  static const Map<String, String> machineTypeIcons = {
    'Combine': 'assets/icons/Combine.png',
    'Tractor': 'assets/icons/Tractor.png',
    'Gator Utility Vehicle': 'assets/icons/Gator Utility Vehicle.png',
    'Rotary Cutter': 'assets/icons/Rotary Cutter.png',
    'Lawn Mower': 'assets/icons/Lawn Mower.png',
    'Crawler Dozer': 'assets/icons/Crawler Dozer.png',
    'Excavator': 'assets/icons/Excavator.png',
    'Backhoe Loader': 'assets/icons/Backhoe Loader.png',
  };

  static Image getIconForMachineType(String machineType) {
    String iconPath = machineTypeIcons[machineType] ?? 'assets/icons/broken.png';
    return Image.asset(iconPath);
  }
}
// usage: Image icon = IconUtils.getIconForMachineType('Tractor');