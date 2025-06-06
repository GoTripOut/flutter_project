import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_flutter_project/screens/MyHomePage.dart';
import '../fetch_fastapi_data.dart';
import '../global_value_controller.dart';
import '../screens/main_page.dart';
import 'calendar_widget.dart';
import 'package:dotted_line/dotted_line.dart';

class RouteContainer extends StatefulWidget{
  const RouteContainer({
    super.key,
    required this.place,
    this.placeListID = -1,
    this.startDate = "",
    this.endDate = "",
    this.controller,
  });
  final PageController? controller;
  final int placeListID;
  final String place;
  final String startDate;
  final String endDate;
  @override
  createState() => _RouteContainerState();
}

class _RouteContainerState extends State<RouteContainer> with SingleTickerProviderStateMixin{
  var valueController = Get.find<GlobalValueController>();
  bool _showPlan = false;
  bool _showDeleteAccept = false;
  List<List<dynamic>> _routeList = [];
  late AnimationController animationController;
  late double screenHeight;
  @override
  void initState(){
    super.initState();
    if(widget.placeListID != -1){
      _getRouteList();
    }
    animationController = BottomSheet.createAnimationController(this);
  }
  Future<void> _getRouteList() async {
    String? response = await sendRequest('get_place_info', placeInfo: [widget.placeListID]);
    DateTime startDate = DateTime.parse(widget.startDate);
    DateTime endDate = DateTime.parse(widget.endDate);
    int days = endDate.difference(startDate).inDays;
    _routeList = List.generate(days + 1,(_) => []);;
    final decodeResponse = jsonDecode(response);
    for(var markerData in decodeResponse){
      _routeList[markerData[8] - 1].add([markerData[7], markerData[2]]);
      print("Route_list: ${_routeList}");
    }
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
              padding: EdgeInsets.only(top: 15),
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
                      physics: BouncingScrollPhysics(),
                      child: Column(    //
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
                        if(valueController.isFirstSelect.value || (valueController.isFirstSelect.value && valueController.isSecondSelect.value)){
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
    return SizedBox(
      width: screenWidth * 0.88,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              valueController.isGetPlaceList.value = false;
              valueController.updateSelectedPlace(widget.place);
              if(widget.startDate != ""){
                valueController.updateDate(DateTime.parse(widget.startDate), DateTime.parse(widget.endDate));
                valueController.updateSelectedPlaceListID(widget.placeListID);
                Get.to(MyHomePage(title: 'demo'));
              } else {
                showCalendarBottomSheet();
              }
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              fixedSize: Size(screenWidth * 0.88, 77),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 11),
            ),
            child: Row(
              spacing: 10,
              mainAxisAlignment: widget.startDate != "" ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
              children: widget.startDate != "" ? [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.0
                        )
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          '',
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace){
                            return Icon(Icons.image_not_supported, size: 50);
                          },
                        ),
                      ),
                    ),
                    Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.place,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
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
                      ]
                    ),
                  ]
                ),
                IconButton(
                  onPressed: (){
                    setState((){
                      _showPlan = !_showPlan;
                    });
                  },
                  icon: _showPlan ? Icon(Icons.keyboard_arrow_down, size: 30, color: Colors.grey) : Icon(Icons.keyboard_arrow_up, size: 30 , color: Colors.grey)
                )
              ] : [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: Colors.white,
                        width: 1.0
                    )
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      '',
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace){
                        return Icon(Icons.image_not_supported, size: 50);
                      },
                    ),
                  ),
                ),
                Text(
                  widget.place,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ]
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            height: _showPlan ? 100 : 0,
            width: screenWidth,
            curve: Curves.easeInOut,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for(int i = 0; i < _routeList.length; i++)
                          for(int j = 0; j < _routeList[i].length; j++)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                j == 0 ? Container(
                                    margin: EdgeInsets.only(bottom: 3),
                                    width: 20,
                                    height: 20,
                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(90),
                                      color: Colors.blue,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${i + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          height: 1,
                                        ),
                                      ),
                                    )
                                ) : SizedBox(
                                  width: 20,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                        width: 20,
                                        child: Center(
                                          child: DottedLine(
                                            direction: Axis.vertical,
                                            dashRadius: 90,
                                            dashColor: Colors.grey,
                                            lineLength: 24,
                                            dashLength: 3,
                                            dashGapLength: 3,
                                            lineThickness: 3,
                                          ),
                                        )
                                    ),
                                    Text(
                                      _routeList[i][j][1],
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                      ],
                    )
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _showDeleteAccept = !_showDeleteAccept;
                            });
                          },
                          icon: Icon(Icons.delete, size: 20, color: Colors.grey,),
                      ),

                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: _showDeleteAccept ? 40 : 0,
                        curve: Curves.easeInOut,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: (){

                              },
                              icon: Icon(
                                Icons.close,
                                color: _showDeleteAccept ? Colors.red : Colors.transparent,),
                            ),
                            IconButton(
                              onPressed: () async {
                                await sendRequest('delete_place_list', placeInfo: [widget.placeListID]);
                                valueController.updatePlaceList();
                              },
                              icon: Icon(
                                Icons.check,
                                color: _showDeleteAccept ? Colors.green : Colors.transparent,),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          ),
          Divider(
            thickness: 1.0,
            color: Colors.grey,
          )
        ]
      )
    );
  }
}