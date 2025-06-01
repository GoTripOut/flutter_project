import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sample_flutter_project/global_value_controller.dart';

import 'day.dart';

class DayCell extends StatefulWidget{
  const DayCell({
    super.key,
    required this.day,
    this.cellColor,
    this.borderRadius,
    this.textStyle,
    required this.isVisible,
  });
  final Day day;
  final Color? cellColor;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final bool isVisible;
  @override
  createState() => _DayCellState();
}

class _DayCellState extends State<DayCell>{
  var valueController = Get.find<GlobalValueController>();
  Color? _cellColor;
  BorderRadius? _borderRadius;
  TextStyle? _textStyle;

  @override
  void initState(){
    super.initState();
    updateDecorationProperties();
  }

  void updateDecorationProperties(){
    _cellColor = Colors.transparent;
    _borderRadius = BorderRadius.zero;
    _textStyle = TextStyle(
      color: widget.day.isVisible ? Colors.black : Colors.transparent,
    );
  }


  @override
  Widget build(BuildContext context) {
    Widget? cell = AnimatedContainer(
      duration: Duration(milliseconds: 50),
      decoration: BoxDecoration(
        color: widget.day.isVisible ? widget.cellColor ?? _cellColor : _cellColor,
        borderRadius: widget.borderRadius ?? _borderRadius,
      ),
      child: valueController.firstSelectedDate.value == widget.day || valueController.secondSelectedDate.value == widget.day
      ? Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
        DateFormat('d').format(widget.day.day).toString(),
        textAlign: TextAlign.center,
        style: widget.day.isVisible ? widget.textStyle ?? _textStyle : _textStyle,
        )
      )
      : Text(
        DateFormat('d').format(widget.day.day).toString(),
        textAlign: TextAlign.center,
        style: widget.day.isVisible ? widget.textStyle ?? _textStyle : _textStyle
      )
    );
    return cell;
  }
}