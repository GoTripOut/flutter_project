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
    _routeList = List.generate(days + 1,(_) => []);
    final decodeResponse = jsonDecode(response);
    for(var markerData in decodeResponse){
      _routeList[markerData[8] - 1].add([markerData[7], markerData[2]]);
    }
    if(mounted){
      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    void showCalendarBottomSheet(){
      showModalBottomSheet(
        backgroundColor: Colors.white,
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
    return Card(
      elevation: 2.0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          if (widget.startDate.isEmpty) {
            showCalendarBottomSheet();
          } else {
            valueController.isGetPlaceList.value = false;
            valueController.updateSelectedPlace(widget.place);
            valueController.updateDate(DateTime.parse(widget.startDate), DateTime.parse(widget.endDate));
            valueController.updateSelectedPlaceListID(widget.placeListID);
            Get.to(MyHomePage(title: 'demo'));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            '', // Placeholder for an image
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                child: Icon(Icons.place, color: Colors.grey[600]),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.place,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.startDate.isNotEmpty)
                                Text(
                                  "${widget.startDate} ~ ${widget.endDate}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.startDate.isNotEmpty)
                    IconButton(
                      icon: Icon(_showPlan ? Icons.expand_less : Icons.expand_more),
                      onPressed: () {
                        setState(() {
                          _showPlan = !_showPlan;
                        });
                      },
                    ),
                ],
              ),
              if (_showPlan)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      _buildRouteDetails(),
                      _buildDeleteButton(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteDetails() {
    if (_routeList.every((day) => day.isEmpty)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text("세부 일정이 없습니다.")),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _routeList.asMap().entries.map((dayEntry) {
        int dayIndex = dayEntry.key;
        List<dynamic> places = dayEntry.value;

        if (places.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Day ${dayIndex + 1}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ...places.map((placeData) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 12,
                        child: Center(
                          child: DottedLine(
                            direction: Axis.vertical,
                            dashRadius: 2,
                            dashColor: Colors.grey,
                            lineLength: 24,
                            dashLength: 3,
                            dashGapLength: 3,
                            lineThickness: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          placeData[1],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeleteButton() {
    return Column(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _showDeleteAccept = !_showDeleteAccept;
            });
          },
          icon: Icon(Icons.delete, color: Colors.grey[600]),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showDeleteAccept ? 40 : 0,
          curve: Curves.easeInOut,
          child: _showDeleteAccept
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showDeleteAccept = false;
                        });
                      },
                      child:
                          const Text("취소", style: TextStyle(color: Colors.red)),
                    ),
                    TextButton(
                      onPressed: () async {
                        await sendRequest('delete_place_list',
                            placeInfo: [widget.placeListID]);
                        valueController.updatePlaceList();
                      },
                      child: const Text("확인",
                          style: TextStyle(color: Colors.green)),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
