import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'package:sample_flutter_project/marker_service.dart';
import 'package:sample_flutter_project/position_service.dart';
import 'package:sample_flutter_project/coordinate_service.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widgets is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widgets) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  kakao.LatLng? myPosition;
  // 최근에 클릭한 위치를 저장하는 변수 recentPostion
  kakao.LatLng? recentPosition;
  kakao.KakaoMapController? mapController;
  kakao.LabelController? labelController;
  late TextEditingController textController; // 검색어 입력
  bool mapLoading = false; // 맵 로딩 상태
  int selectedIndex = 0;
  MarkerService? markerService;

  @override
  void initState() {
    super.initState();
    _initializePosition();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // 위치 초기화
  void _initializePosition() async {
    bool permission = await PositionService().getPermission();
    if (!permission) {
      return;
    }
    kakao.LatLng? position = await PositionService().getPosition();
    if (position != null) {
      setState(() {
        myPosition = position;
        recentPosition = position;
      });
    }
  }

  // 아래 하단 버튼 눌렀을 때의 동작
  void _itemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    switch (index) {
      case 0:
        markerService!.addRoute(recentPosition!);
        break;
      case 1:
        markerService!.deleteRoute();
        break;
      case 2:
        markerService!.resetRoute();

        // 경로를 초기화하였으므로, 최근 위치를 현재 위치로 설정한다.
        recentPosition = myPosition;

        // 경로를 초기화하였으므로, 다시 현재 위치로 카메라를 돌아오게 한다.
        mapController!.moveCamera(
          kakao.CameraUpdate.newCenterPosition(myPosition!),
        );
        break;
    }
  }

  // 검색 버튼 클릭시 그 지역을 띄우는 화면으로 넘어감
  void _searchPosition() async {
    String query = textController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      mapLoading = true;
    });

    kakao.LatLng? result = await RestApiService().getCoordinates(query);
    if (result != null) {
      setState(() {
        recentPosition = result;
      });
      mapController!.moveCamera(
        kakao.CameraUpdate.newCenterPosition(recentPosition!),
      );
    }
    setState(() {
      mapLoading = false;
    });
  }

  // 현재 위치를 flask 서버로 전송
  Future<void> _sendPosition() async{
    print("현재 위치를 전송합니다 ");
    final url = Uri.parse("http://192.168.0.33:5000");
    final response = await http.post(
      url,
      headers: {"content-type": "application/json"},
      body: jsonEncode({
        "latitude": myPosition!.latitude,
        "longitude": myPosition!.longitude
      }),
    );
    if (response.statusCode == 200) {
      print("${response.body}");
    } else {
      print("전송 실패: ${response.statusCode}");
    }
  }

  // 커스텀 함수
  void _handlePoiClick(kakao.Poi poi) {
    print('POI ID: ${poi.id}');
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          myPosition != null ? kakao.KakaoMap(
            option: kakao.KakaoMapOption(
              position: kakao.LatLng(myPosition!.latitude, myPosition!.longitude),
            ),
            onMapReady: (kakao.KakaoMapController controller) {
              mapController = controller;
              markerService = MarkerService(
                mapController: mapController!,
                pois: [],
                poiLat: [],
                myRoute: [],
              );
              print("카카오 지도가 정상적으로 불러와졌습니다.");
              _sendPosition();
            },
            onPoiClick: (kakao.LabelController controller, kakao.Poi poi){    //poi click 시 실행되는 코드
              labelController = controller;
              markerService?.selectedPoiId = poi.id;                          //선택된 poi의 id를 markerService로 전송
              print("poi clicked");
            }
          ) : const Center(child: CircularProgressIndicator()),
          // 검색창을 지도 위에 겹침
          Positioned(
            top: 30, left: 10, right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: InputDecoration(border: InputBorder.none,
                          hintText: "지역을 입력하세요",
                          contentPadding: EdgeInsets.all(10),
                          hintStyle: TextStyle(fontSize: 13)
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: mapLoading ? null : _searchPosition,
                      icon: mapLoading ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ): Icon(Icons.search))
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        onTap: _itemTapped,
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.add_location_alt), label: "경로 추가"),
          BottomNavigationBarItem(
              icon: Icon(Icons.delete_forever), label: "경로 삭제"),
          BottomNavigationBarItem(
              icon: Icon(Icons.refresh), label: "경로 초기화"),
        ],
      ),
    );
  }
}