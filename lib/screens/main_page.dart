import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sample_flutter_project/fetch_fastapi_data.dart';
import 'package:sample_flutter_project/global_value_controller.dart';
import '../widgets/route_list_builder.dart';
import 'intro_page_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });
  @override
  createState() => _MainPageState();
}
class _MainPageState extends State<MainPage>{
  bool isSearching = false;
  var valueController = Get.find<GlobalValueController>();
  String? userID;
  List<dynamic> placeList = [];
  List<dynamic> filteredList = [];
  DateTime? lastPressedTime;
  @override
  void initState(){
    super.initState();
    userID = valueController.userID.value;
    _initPlaceList();
  }

  Future<void> _initPlaceList() async {
    await valueController.updatePlaceList();
    placeList = valueController.placeList;
  }

  Future<bool> handleDoubleBackPressed() async {
    DateTime now = DateTime.now();
    if(lastPressedTime == null || now.difference(lastPressedTime!) > Duration(seconds: 2)){
      lastPressedTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("뒤로 가기 버튼을 한 번 더 누르면 종료됩니다.")),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if(isSearching){
                isSearching = !isSearching;
                setState((){});
              } else {
                bool isDoubleBackPressed = await handleDoubleBackPressed();
                if(isDoubleBackPressed){
                  SystemNavigator.pop();
                }
              }
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                shadowColor: Colors.grey.withAlpha(128),
                elevation: 2.0,
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
                ) : Text("나의 여행"),
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
              body: Obx(() => valueController.placeList.value != placeList ? Container(
                width: screenWidth,
                height: screenHeight,
                margin: EdgeInsets.only(top: 10),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      child: Center(
                        child:SizedBox(
                          width: screenWidth * 0.88,
                          height: screenHeight,
                          child: isSearching        //검색 중일 경우 검색한 내용만, 아닐 경우 모든 내용을 내림차순 출력
                            ? RouteListBuilder(routeContents: filteredList, addNewRoute: false,)
                            : RouteListBuilder(routeContents: placeList, addNewRoute: false,)
                        ),
                      ),
                    ),
                  ],
                ),
              ) : Center(child: CircularProgressIndicator()),
              ),
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: (){
                    Get.to(IntroPageView())?.then((value){valueController.isGetPlaceList.value = false;});
                  }
              ),
            )
        )
    );
  }
}
