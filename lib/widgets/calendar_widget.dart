import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'day.dart';
import 'day_cell.dart';
import '../global_value_controller.dart';

class CalendarWidget extends StatefulWidget{
  CalendarWidget({
    super.key,
    required this.year,
    required this.month,
  });
  final int year;
  final int month;
  final List<String> daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"];

  @override
  createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget>{
  var valueController = Get.find<GlobalValueController>();
  List<Day> days = [];
  List<bool> validWeeks = [false, false, false, false, false, false];
  bool isFirstSelect = false;
  bool isSecondSelect = false;
  dynamic firstSelectedDate;
  dynamic secondSelectedDate;
  @override
  void initState(){
    super.initState();
    valueController.initFirstSelected();
    valueController.initSecondSelected();
    isFirstSelect = valueController.isFirstSelect.value;
    isSecondSelect = valueController.isSecondSelect.value;
    firstSelectedDate = valueController.firstSelectedDate.value;
    secondSelectedDate = valueController.secondSelectedDate.value;
    DateTime curDate = DateTime.now();
    int curYear = curDate.year;
    int curMonth = curDate.month;
    int lastDay = DateTime(widget.year, widget.month + 1, 0).day;
    int startDay = curDate.day;
    if(DateTime(widget.year, widget.month, 1).weekday != 7){
      int prevLastDay = DateTime(widget.year, widget.month, 0).day;
      for(int i = DateTime(widget.year, widget.month, 1).weekday - 1; i >= 0; i--){
        days.add(Day(
          day: DateTime(widget.year, widget.month - 1, prevLastDay - i),
          isInMonth: false,
          isVisible: false,
          isInRange: false,
          isSelected: false,
        ));
      }
    }
    if(curYear != widget.year || curMonth != widget.month) {
      startDay = 1;
    }
    for (int i = 1; i <= lastDay; i++) {
      if (i < startDay) {
        days.add(Day(
          day: DateTime(widget.year, widget.month, i),
          isInMonth: true,
          isVisible: false,
          isInRange: false,
          isSelected: false,
        ));
      } else {
        days.add(Day(
          day: DateTime(widget.year, widget.month, i),
          isInMonth: true,
          isVisible: true,
          isInRange: false,
          isSelected: false,
        ));
      }
    }
    if(DateTime(widget.year, widget.month + 1, 0).weekday != 6){
      int lastIndex = 7 - DateTime(widget.year, widget.month + 1, 0).weekday;
      if(DateTime(widget.year, widget.month + 1, 0).weekday == 7) {
         lastIndex = 6;
      }
      for (int i = 1; i <= lastIndex; i++) {
        days.add(Day(
          day: DateTime(widget.year, widget.month - 1, i),
          isInMonth: false,
          isVisible: false,
          isInRange: false,
          isSelected: false,
        ));
      }
    }
  }
  void updateDayProperties(int index){
    if(!valueController.isFirstSelect.value){
      valueController.updateFirstSelected(days[index]);
    } else if(!valueController.isSecondSelect.value){
      if(days[index].day.compareTo(valueController.firstSelectedDate.value.day) < 0){
        valueController.updateFirstSelected(days[index]);
      } else {
        valueController.updateSecondSelected(days[index]);
      }
    } else{
      valueController.initSecondSelected();
      valueController.updateFirstSelected(days[index]);
    }
  }
  Color cellColor(int index) {
    return (valueController.isFirstSelect.value &&
        valueController.firstSelectedDate.value == days[index]) ||
        (valueController.isSecondSelect.value &&
            valueController.secondSelectedDate.value == days[index])
        ? Colors.grey
        : valueController.isFirstSelect.value &&
        valueController.isSecondSelect.value
        && valueController.firstSelectedDate.value.day
            .compareTo(days[index].day) < 0
        && valueController.secondSelectedDate.value.day
            .compareTo(days[index].day) > 0
        ? Colors.grey
        : Colors.transparent;
  }
  BorderRadius cellBorder(int index){
    return valueController.isFirstSelect.value && valueController.isSecondSelect.value
        && valueController.firstSelectedDate.value.day
        .compareTo(days[index].day) < 0
        && valueController.secondSelectedDate.value.day
        .compareTo(days[index].day) > 0
        ? BorderRadius.zero
        : valueController.firstSelectedDate.value == days[index] &&
        !valueController.isSecondSelect.value
        ? BorderRadius.circular(50)
        : valueController.secondSelectedDate.value == days[index]
        ? BorderRadius.only(
        topRight: Radius.circular(50), bottomRight: Radius.circular(50))
        : BorderRadius.only(
        topLeft: Radius.circular(50), bottomLeft: Radius.circular(50));
  }
  TextStyle cellTextStyle(int index) {
    return TextStyle(
      height: 2,
      color: (valueController.isFirstSelect.value &&
          valueController.firstSelectedDate.value == days[index]) ||
          (valueController.isSecondSelect.value &&
              valueController.secondSelectedDate.value == days[index])
          ? Colors.white : days[index].isVisible ? Colors.black : Colors
          .transparent,
    );
  }
  bool validWeek(int week){
    int startIndex = week * 7;
    int endIndex = (week + 1) * 7;
    for(int i = startIndex; i < endIndex; i++){
      if(days.length > i && days[i].isVisible){
        validWeeks[week] = true;
        valueController.updateValidWeeks(week, true);
        return true;
      }
    }
    return false;
  }
  Widget drawWeek(int week){
    int startIndex = week * 7;
    int endIndex = (week + 1) * 7;
    return validWeeks[week] ?
      Row(
        children: [
          for(int i = startIndex; i < endIndex; i++)
            if(days.length > i)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    updateDayProperties(i);
                  },
                  child: Obx(() => DayCell(
                    key: ValueKey("${days[i].day.year}-${days[i].day.month}-${days[i].day.day}"),
                    day: days[i],
                    cellColor: cellColor(i),
                    textStyle: cellTextStyle(i),
                    borderRadius: cellBorder(i),
                    isVisible: days[i].isVisible,
                  ))
                )
              )
        ],
      ) : SizedBox.shrink();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Center(
          child: Text("${widget.year}년 ${widget.month}월"),
        ),
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for(String dayOfWeek in widget.daysOfWeek)
              Expanded(
                child: Text(
                  dayOfWeek,
                  style: TextStyle(
                    color: dayOfWeek == "일" ? Colors.red : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        for(int i = 0; i < 6; i++)
          if(validWeek(i))drawWeek(i),
      ],
    );
  }

}