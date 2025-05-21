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
  List<List<String>> placeList = [["강릉", "2025-04-26", "2025-04-28"], ["인천", "2025-04-30", "2025-04-31"]];
  List<List<String>> filteredList = [];
  DateTime? lastPressedTime;
  @override
  void initState(){
    super.initState();
    userID = valueController.userID.value;
    print(userID);
    var userPlace = sendRequest('get_user_place');
    print(userPlace);
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
    return PopScope(
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
          ) : Text("홈"),
          actions:[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: (){
                isSearching = !isSearching;
                setState((){});
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: (){

              },
            )
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
                    child: isSearching        //검색 중일 경우 검색한 내용만, 아닐 경우 모든 내용을 내림차순 출력
                        ? RouteListBuilder(routeContent: filteredList..sort((a, b) => DateTime.parse(a[1]).compareTo(DateTime.parse(b[1]))), addNewRoute: false, )
                        : RouteListBuilder(routeContent: placeList..sort((a, b) => DateTime.parse(a[1]).compareTo(DateTime.parse(b[1]))), addNewRoute: false,)
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
            Get.to(IntroPageView());
          }
        ),
      )
    );
  }
}
