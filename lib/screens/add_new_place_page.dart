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
  List<dynamic> filteredList = [];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.grey.withAlpha(128),
        elevation: 2.0,
        title: isSearching ? TextField(
          onChanged: (value){
            filteredList = valueController.placeList
                .where((item) => item[0].toLowerCase().contains(value.toLowerCase()))
                .toList();
            setState((){});
          },
          decoration: InputDecoration(
            hintText: "장소를 입력해 주세요...",
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.black),
        ) : Text("여행지 추가"),
        actions:[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: (){
              isSearching = !isSearching;
              setState((){});
            },
          ),
        ],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Positioned(
              child: Center(
                child:Container(
                  margin: EdgeInsets.only(top: 10),
                  width: screenWidth * 0.88,
                  height: screenHeight,
                  child: Obx(() => isSearching
                      ? RouteListBuilder(controller: widget.controller, routeContents: filteredList..sort((a, b) => (a[0]).compareTo(b[0])), addNewRoute: true,)
                      : RouteListBuilder(controller: widget.controller, routeContents: valueController.placeList..sort((a, b) => (a[0]).compareTo(b[0])), addNewRoute: true,)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
