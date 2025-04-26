import 'package:flutter/material.dart';

class BNBIcon{    //Icon을 Enabled와 Disabled로 나누어 동적으로 할당하기 위한 클래스
  final IconData enabledIcon;
  final IconData disabledIcon;
  final String label;
  final int index;

  const BNBIcon({
    required this.enabledIcon,
    required this.disabledIcon,
    required this.label,
    required this.index,
  });
}