import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_flutter_project/global_value_controller.dart';
import '../widgets/route_list_builder.dart';

class AddNewPlacePage extends StatefulWidget {
  const AddNewPlacePage({
    super.key,
    this.controller,
  });
  final PageController? controller;
  @override
  createState() => _AddNewPlacePageState();
}
class _AddNewPlacePageState extends State<AddNewPlacePage>{
  var valueController = Get.find<GlobalValueController>();
  bool isSearching = false;
  List<List<String>> placeList = [["강릉"], ["인천"], ["제주"], ["속초"], ["원주"], ["부산"], ["서울"]];
  List<List<String>> filteredList = [];
  DateTime? lastPressedTime;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: isSearching ? TextField(
            onChanged: (value){
              filteredList = placeList
                  .where((item) => item[0].toLowerCase().contains(value.toLowerCase()))
                  .toList();
              setState((){});
            },
            decoration: InputDecoration(
              hintText: "장소를 입력해 주세요...",
              border: InputBorder.none,
            ),
            style: TextStyle(color: Colors.black),
          ) : Text("여행지 선택"),
          actions:[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: (){
                isSearching = !isSearching;
                setState((){});
              },
            ),
          ]
        ),
        body: Container(
          width: screenWidth, // 동적 너비
          height: screenHeight, // 동적 높이
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: const Color(0xFFF0F0F0)),
          child: Stack(
            children: [
              Positioned(
                child: Center(
                  child:Container(
                    padding: EdgeInsets.only(top: 10),
                    width: screenWidth * 0.88,
                    height: screenHeight,
                    child: isSearching
                        ? RouteListBuilder(controller: widget.controller, routeContent: filteredList..sort((a, b) => (a[0]).compareTo(b[0])), addNewRoute: true,)
                        : RouteListBuilder(controller: widget.controller, routeContent: placeList..sort((a, b) => a[0].compareTo(b[0])), addNewRoute: true,),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
