import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  late var valueController;
  List<dynamic> days = [];
  List<bool> validWeeks = [false, false, false, false, false, false];
  bool isFirstSelect = false;
  bool isSecondSelect = false;
  dynamic firstSelectedDate;
  dynamic secondSelectedDate;
  @override
  void initState(){
    super.initState();
    valueController = Get.find<GlobalValueController>();
    valueController.updateFirstSelected(false, {
      "year": 0,
      "month": 0,
      "day":0,
      "isInMonth": false,
      "isNextDay": false,
    });
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
        days.add({
          "year": widget.year,
          "month": widget.month - 1,
          "day": prevLastDay - i,
          "isInMonth": false,
          "isNextDay": false,
        });
      }
    }
    if(curYear != widget.year || curMonth != widget.month) {
      startDay = 1;
    }
    for (int i = 1; i <= lastDay; i++) {
      if (i < startDay) {
        days.add({
          "year": widget.year,
          "month": widget.month,
          "day": i,
          "isInMonth": true,
          "isNextDay": false,
        });
      } else {
        days.add({
          "year": widget.year,
          "month": widget.month,
          "day": i,
          "isInMonth": true,
          "isNextDay": true,
        });
      }
    }
    if(DateTime(widget.year, widget.month + 1, 0).weekday != 6){
      int lastIndex = 7 - DateTime(widget.year, widget.month + 1, 0).weekday;
      if(DateTime(widget.year, widget.month + 1, 0).weekday == 7) {
         lastIndex = 6;
      }
      for (int i = 1; i <= lastIndex; i++) {
        days.add({
          "year": widget.year,
          "month": widget.month - 1,
          "day": i,
          "isInMonth": false,
          "isNextDay": false,
        });
      }
    }
  }
  bool validWeek(int week){
    int startIndex = week * 7;
    int endIndex = (week + 1) * 7;
    for(int i = startIndex; i < endIndex; i++){
      if(days.length > i && days[i]["isNextDay"]){
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
            if(days.length > i && days[i]["isNextDay"])
              Expanded(
                child: Obx(() => TextButton(
                  onPressed: (){
                    isFirstSelect = valueController.isFirstSelect.value;
                    isSecondSelect = valueController.isSecondSelect.value;
                    firstSelectedDate = valueController.firstSelectedDate.value;
                    secondSelectedDate = valueController.secondSelectedDate.value;
                    if(!isFirstSelect){
                      isFirstSelect = true;
                      valueController.updateFirstSelected(isFirstSelect, days[i]);
                      firstSelectedDate = days[i];
                    } else if(!isSecondSelect){
                      isSecondSelect = true;
                      valueController.updateSecondSelected(isSecondSelect, days[i]);
                      secondSelectedDate = days[i];
                    } else{
                      isSecondSelect = false;
                      valueController.updateFirstSelected(isFirstSelect, days[i]);
                      valueController.updateSecondSelected(isSecondSelect, days[i]);
                      firstSelectedDate = days[i];
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: (valueController.isFirstSelect.value && valueController.firstSelectedDate.value == days[i]) || (valueController.isSecondSelect.value && valueController.secondSelectedDate.value == days[i])
                        ? WidgetStateProperty.all(Colors.black)
                        : valueController.isFirstSelect.value && valueController.isSecondSelect.value
                        && DateTime(valueController.firstSelectedDate["year"], valueController.firstSelectedDate["month"], valueController.firstSelectedDate["day"])
                        .compareTo(DateTime(days[i]["year"], days[i]["month"], days[i]["day"])) < 0
                        && DateTime(valueController.secondSelectedDate["year"], valueController.secondSelectedDate["month"], valueController.secondSelectedDate["day"])
                        .compareTo(DateTime(days[i]["year"], days[i]["month"], days[i]["day"])) > 0
                        ? WidgetStateProperty.all(Colors.grey)
                        : WidgetStateProperty.all(Colors.transparent),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: valueController.isFirstSelect.value && valueController.isSecondSelect.value
                          && DateTime(valueController.firstSelectedDate["year"], valueController.firstSelectedDate["month"], valueController.firstSelectedDate["day"])
                          .compareTo(DateTime(days[i]["year"], days[i]["month"], days[i]["day"])) < 0
                          && DateTime(valueController.secondSelectedDate["year"], valueController.secondSelectedDate["month"], valueController.secondSelectedDate["day"])
                          .compareTo(DateTime(days[i]["year"], days[i]["month"], days[i]["day"])) > 0
                          ? BorderRadius.circular(0)
                          : valueController.firstSelectedDate.value == days[i]
                          ? BorderRadius.only(topLeft: Radius.circular(50), bottomLeft: Radius.circular(50))
                          : valueController.secondSelectedDate == days[i] ? BorderRadius.only(topRight: Radius.circular(50), bottomRight: Radius.circular(50))
                          : BorderRadius.zero,
                        side: BorderSide.none,
                      )
                    ),
                  ),
                  child: Obx(() => Text(
                    days[i]["day"].toString(),
                    style: TextStyle(
                      color: (valueController.isFirstSelect.value && valueController.firstSelectedDate.value == days[i]) || (valueController.isSecondSelect.value && valueController.secondSelectedDate.value == days[i])
                          ? Colors.white : Colors.black,
                    )
                  )
                )
                )
              )
              )
            else if(days.length > i)
              Expanded(
                child: TextButton(
                  onPressed: null,
                  child: Text(
                      days[i]["day"].toString(),
                      style: TextStyle(
                          color: Colors.transparent
                      )
                  )
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