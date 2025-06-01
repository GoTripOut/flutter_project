
class Day{
  Day({
    required this.day,
    required this.isInMonth,
    required this.isVisible,
    this.isSelected = false,
    this.isInRange = false,
    this.isFirstSelect = false,
    this.isSecondSelect = false,
  });
  final DateTime day;
  final bool isInMonth;
  final bool isVisible;
  bool? isSelected;
  bool? isFirstSelect;
  bool? isSecondSelect;
  bool? isInRange;

}