import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_flutter_project/screens/MyHomePage.dart';

import '../global_value_controller.dart';
import '../screens/intro_page_view.dart';
import 'calendar_widget.dart';

class RouteContainer extends StatefulWidget{
  const RouteContainer({
    super.key,
    required this.place,
    this.startDate = "",
    this.endDate = "",
    this.controller,
  });
  final PageController? controller;
  final String place;
  final String startDate;
  final String endDate;
  @override
  createState() => _RouteContainerState();
}

class _RouteContainerState extends State<RouteContainer> with SingleTickerProviderStateMixin{
  var valueController = Get.find<GlobalValueController>();
  late AnimationController animationController;
  late double screenHeight;
  @override
  void initState(){
    super.initState();
    animationController = BottomSheet.createAnimationController(this);
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    void showCalendarBottomSheet(){
      showModalBottomSheet(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (BuildContext context){
          return SafeArea(
            child: Container(
              padding: EdgeInsets.only(top: 20),
              height: screenHeight * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (int i = 0; i < 6; i++)
                            CalendarWidget(
                              year: DateTime.now().month + i < 13
                                  ? DateTime.now().year
                                  : DateTime.now().year + 1,
                              month: DateTime.now().month + i < 13
                                  ? DateTime.now().month + i
                                  : DateTime.now().month + i - 12,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () {
                        if(valueController.isFirstSelect.value && valueController.isSecondSelect.value){
                          Get.back();
                          valueController.updateIntroPageIndex(valueController.introPageIndex.value + 1);
                          widget.controller!.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text("적용"),
                    ),
                  ),
                ],
              ),
            )
          );
        },
      );
    }
    return TextButton(
      onPressed: () {
        valueController.updateSelectedPlace(widget.place);
        widget.startDate != "" ?
        Get.to(MyHomePage(title: 'demo')):showCalendarBottomSheet();
      },
      style: TextButton.styleFrom(
        fixedSize: Size(screenWidth * 0.88, 77),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: widget.startDate != "" ? [
          Text(
            widget.place,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          Text(
            "${widget.startDate}~${widget.endDate}",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              height: 1,
            )
          )
        ] : [
          Text(
            widget.place,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ]
      )
    );
  }
}