import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'package:sample_flutter_project/global_value_controller.dart';
import 'package:sample_flutter_project/marker_service.dart';
import 'package:sample_flutter_project/position_service.dart';
import 'package:sample_flutter_project/coordinate_service.dart';
import 'package:sample_flutter_project/fetch_fastapi_data.dart';
import '../widgets/category_selector_sheet.dart';
import 'category_place_page.dart';
import 'package:get/get.dart';

import 'main_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final globalValueController = Get.find<GlobalValueController>();
  final draggableSheetController = DraggableScrollableController();
  final PageController pageController = PageController(); // 날짜 PageView 컨트롤러

  kakao.KakaoMapController? mapController;
  kakao.LabelController? labelController;
  late TextEditingController textController; // 검색어 입력
  kakao.LatLng? myPosition;

  bool mapLoading = false; // 맵 로딩 상태
  bool locateLoading = false; // 위치 정보 로딩 상태
  int selectedIndex = 0;
  kakao.LatLng? tappedPosition; // 지도 클릭 시 좌표 저장
  String? tappedPlaceName; // poi 이름
  int? tappedPlaceAIScore; // ai 점수

  Map<String, String> categoryMap = {
    "음식점": "FD6",
    "카페": "CE7",
    "편의점": "CS2",
    "관광명소": "AT4",
    "문화시설": "CT1",
    "숙박": "AD5",
    "주차장": "PK6",
    "주유소,충전소": "OL7",
    "지하철역": "SW8",
  };

  // 캐시 : 가져왔던 장소 리스트를 새로 요청하지 않고 사용
  Map<String, List<dynamic>> cachedPlaceList = {};

  Map<DateTime, MarkerService> tripDatesMarkerServices = {}; // 날짜별 MarkerService
  MarkerService? currentMarkerService; // 현재 선택된 날짜의 MarkerService
  List<DateTime> tripDates = []; // 여행 날짜 리스트
  DateTime? selectedDate; // 현재 선택된 날짜

  // 위도, 경도 비교
  bool _isSameLatLng(kakao.LatLng pos1, kakao.LatLng pos2) {
    return pos1.latitude == pos2.latitude && pos1.longitude == pos2.longitude;
  }

  Future<void> _updateDate() async {

    // 직접 날짜 문자열을 파싱
    DateTime startDate = globalValueController.startDate.value;
    DateTime endDate = globalValueController.endDate.value;

    if (startDate != DateTime(0) && endDate != DateTime(0)) {
      for (var markerservice in tripDatesMarkerServices.values) {
        await markerservice.resetRoute(); // 각 서비스의 모든 데이터 초기화
      }
      tripDatesMarkerServices.clear();
      tripDates.clear(); // 날짜 리스트 초기화

      // 시작 날짜부터 종료 날짜까지 모든 날짜에 대해 생성
      for (var d = startDate; d.isBefore(endDate.add(const Duration(days: 1)));
      d = d.add(const Duration(days: 1))
      ) {
        final day = DateTime(d.year, d.month, d.day);
        tripDates.add(day);
        tripDatesMarkerServices[day] = MarkerService(
          mapController: mapController!,
          initialRecentPosition: myPosition,
          initialVisitedPosition: [myPosition!],
          selectedDay: day.difference(startDate).inDays + 1,
        );
      }
      await _initMarkerInfo();
      setState(() {
        selectedDate = DateTime(startDate.year, startDate.month, startDate.day,); // 초기 선택 날짜는 여행의 첫 날짜로 설정
        currentMarkerService = tripDatesMarkerServices[selectedDate]; // 현재 MarkerService 설정
        if (pageController.hasClients) {
          pageController.jumpToPage(0); // PageView를 첫 페이지로 이동
        }
      });
      print("여행의 첫 날짜는 ${selectedDate}");
      if (currentMarkerService != null) {
        await currentMarkerService!.showFromMap();
      }
    }
  }

  // 현재 보고있는 화면의 날짜를 설정
  void _selectDate(DateTime date) async {
    // 1. 현재 보여지고 있는 날짜의 MarkerService 요소를 지도에서 숨김
    if (currentMarkerService != null && selectedDate != null) {
      await currentMarkerService!.hideFromMap();
    }

    setState(() {
      selectedDate = date; // 선택된 날짜 업데이트
      currentMarkerService = tripDatesMarkerServices[selectedDate]; // 새 날짜에 해당하는 MarkerService 활성화
    });

    // 2. 새롭게 선택된 날짜의 MarkerService 요소를 지도에 표시
    if (currentMarkerService != null) {
      await currentMarkerService!.showFromMap();
    }
  }

  // 선택된 여행지의 좌표
  Future<void> _selectedPlacePosition() async {
    String query = globalValueController.selectedPlace.value;
    kakao.LatLng? position = await RestApiService().getCoordinates(query);
    if (position != null) {
      setState(() {
        myPosition = position;
      });
      if (mapController != null && selectedDate != null && currentMarkerService == null) {
        currentMarkerService = tripDatesMarkerServices[selectedDate];
      }
    }
  }
  //페이지 활성화 시 기존 추천 경로 데이터를 불러와 지도에 적용하는 함수
  Future<void> _initMarkerInfo() async {
    String? response = await sendRequest('get_place_info', placeInfo: [globalValueController.selectedPlaceListID.value]);
    final decodeResponse = jsonDecode(response);
    for(var markerData in decodeResponse){
      kakao.LatLng markerPos = kakao.LatLng(double.parse(markerData[4]), double.parse(markerData[3]));    //x, y값
      myPosition = markerPos;
      for(MarkerService service in tripDatesMarkerServices.values){
        if(service.selectedDay != 1){
          await service.hideFromMap();
        }
        if(service.selectedDay == markerData[8]){
          service.recentPosition = markerPos;
          await service.addRoute(markerPos, markerData[2], markerData[5]);
          service.visitedPosition.add(markerPos);
        }
      }
    }
    mapController!.moveCamera(
      kakao.CameraUpdate.newCenterPosition(myPosition!),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedPlacePosition();
    textController = TextEditingController();
    _updateDate();
  }

  @override
  void dispose() {
    textController.dispose();
    draggableSheetController.dispose();
    pageController.dispose();
    tripDatesMarkerServices.values.forEach((service) async {
      await service.resetRoute(); // 각 서비스의 데이터 초기화
    });
    super.dispose();
  }

  // 실제 내 위치 초기화
  Future<void> _initializePosition() async {
    bool permission = await PositionService().getPermission();
    if (!permission) {
      return;
    }
    kakao.LatLng? position = await PositionService().getPosition();
    if (position != null) {
      setState(() {
        myPosition = position;
        currentMarkerService!.recentPosition = myPosition;
      });
    }
  }

  // 아래 하단 버튼 눌렀을 때의 동작
  void _itemTapped(int index) async {
    setState(() {
      selectedIndex = index;
    });

    // 현재 선택된 날짜의 MarkerService가 없으면 동작하지 않음
    if (currentMarkerService == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("날짜를 먼저 선택해주세요.")));
      return;
    }

    switch (index) {
      case 0:
        kakao.LatLng targetPosition;
        if (tappedPosition != null) {
          targetPosition = tappedPosition!;
          if (currentMarkerService!.visitedPosition.isEmpty ||
              !currentMarkerService!.isSameLatLng(currentMarkerService!.visitedPosition.last, targetPosition)) {
            currentMarkerService!.visitedPosition.add(targetPosition);
          }
        } else {
          // 지도 위의 poi를 클릭하지 않을 경우, 검색한 위치를 기반으로 경로 추가
          targetPosition = currentMarkerService!.recentPosition!;
        }

        setState(() {
          currentMarkerService!.recentPosition = targetPosition; // 새로운 위치로 업데이트
        }); // UI 갱신

        await currentMarkerService!.addRoute(targetPosition, tappedPlaceName, tappedPlaceAIScore);
        setState(() {
          tappedPosition = null;
          tappedPlaceName = null;
          tappedPlaceAIScore = null;
        });
        break;
      case 1:
        await currentMarkerService!.deleteRoute();
        setState(() {});
        break;
      case 2:
        await currentMarkerService!.resetRoute();

        // 경로를 초기화하였으므로, 다시 여행지 위치로 카메라를 돌아오게 한다.
        await _selectedPlacePosition();
        if (myPosition != null) {
          mapController!.moveCamera(
            kakao.CameraUpdate.newCenterPosition(myPosition!),
          );
          setState(() {
            currentMarkerService!.recentPosition = myPosition; // 최근 위치를 현재 위치로 설정
            currentMarkerService!.visitedPosition.clear();
            currentMarkerService!.visitedPosition.add(myPosition!);
            tappedPlaceName = null;
            tappedPosition = null;
            tappedPlaceAIScore = null;
          }); // UI 갱신
        }
        break;
      case 3:
        currentMarkerService?.updatePlan();
        Get.to(MainPage());
        break;  //추천 경로 정보 DB 업데이트 및 메인 페이지 이동
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
        if (currentMarkerService!.visitedPosition.isNotEmpty &&
            !currentMarkerService!.isSameLatLng(currentMarkerService!.visitedPosition.last, currentMarkerService!.recentPosition!)) {
          currentMarkerService!.visitedPosition.add(currentMarkerService!.recentPosition!);
        }
        currentMarkerService!.recentPosition = result;
      });
      mapController!.moveCamera(
        kakao.CameraUpdate.newCenterPosition(currentMarkerService!.recentPosition!),
      );
    }
    setState(() {
      mapLoading = false;
    });
  }

  // 커스텀 함수
  void _handlePoiClick(kakao.Poi poi) {
    print('POI ID: ${poi.id}');
  }

  // 다이얼로그
  Future<void> _showDialog(kakao.Poi poi) async {
    final TextEditingController textController = TextEditingController(
      text: poi.text,
    );
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("장소 이름 변경"),
          content: TextField(controller: textController),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () async {
                String newName = textController.text.trim();
                if (newName.isNotEmpty) {
                  await currentMarkerService!.renamePoi(poi, newName); // poi 이름 변경
                  setState(() {}); // UI 갱신
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // 카테고리 장소 리스트 화면으로 이동하고 결과를 처리
  Future<void> _moveCategoryPlacePage(
    String categoryName,
    String placesJson,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafeArea(   //SafeArea추가
          child: CategoryPlaceListPage(
            categoryName: categoryName,
            placesJson: placesJson,
          ),
        )
      ),
    );

    if (result != null) {
      final placeName = result['name'];
      final placePosition = kakao.LatLng(
        result['latitude'],
        result['longitude'],
      );
      //CategoryPlaceListPage 반환 값에 aiScore 추가
      final aiScore = result['aiScore'];
      mapController!.moveCamera(
        kakao.CameraUpdate.newCenterPosition(placePosition),
      );
      setState(() {
        if (currentMarkerService!.visitedPosition.isEmpty ||
            !currentMarkerService!.isSameLatLng(currentMarkerService!.visitedPosition.last, placePosition)) {
          currentMarkerService!.visitedPosition.add(placePosition);
        }
        tappedPlaceName = placeName;
        tappedPlaceAIScore = aiScore;
        currentMarkerService!.recentPosition = placePosition;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      extendBodyBehindAppBar: true, //appBar가 body부분과 겹쳐지도록 설정
      appBar: AppBar(   //검색창 부분이 상단바 영역을 침범하지 않도록 appBar로 분리
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "지역을 입력하세요",
                    contentPadding: EdgeInsets.all(10),
                    hintStyle: TextStyle(fontSize: 13),
                  ),
                  onSubmitted: (value) {
                    // 키보드의 입력을 완료했을 때
                    if (!mapLoading) {
                      _searchPosition();
                    }
                  },
                ),
              ),
              IconButton(
                onPressed: mapLoading ? null : _searchPosition,
                // 검색 버튼을 눌렀을 때
                icon: mapLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Icon(Icons.search),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          myPosition != null
              ? kakao.KakaoMap(
            option: kakao.KakaoMapOption(
              position: kakao.LatLng(
                myPosition!.latitude,
                myPosition!.longitude,
              ),
            ),
            onMapReady: (kakao.KakaoMapController controller) {
              mapController = controller;
              _updateDate();
              print("카카오 지도가 정상적으로 불러와졌습니다.");
            },
            onMapClick: (kakao.KPoint point, kakao.LatLng position) {
              setState(() {
                tappedPosition = position;
                tappedPlaceName = null;
                tappedPlaceAIScore = null;
              });
            },
            onPoiClick: (kakao.LabelController controller, kakao.Poi poi) {
              labelController = controller;
              currentMarkerService?.selectedPoiId = poi.id;
              setState(() {
                tappedPlaceName = null;
                tappedPlaceAIScore = null;
              });
              print("poi clicked");
            },
          )
              : const Center(child: CircularProgressIndicator()),
          Obx(() => globalValueController.isLoading.isTrue ? Container( // 카테고리 요청 상태
            width: screenWidth,
            height: screenHeight,
            color: Colors.white.withAlpha(128),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 5,
                children: [
                  CircularProgressIndicator(),    //요청 중일 경우 로딩 인디케이터 센터에 표시
                  Text(
                      "추천 장소 검색 중...",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      )
                  ),
                ],
              )
            )
          ) : const SizedBox.shrink()), // 로딩 중이 아니면 아무것도 표시하지 않음
          Positioned(
            top: kToolbarHeight + topPadding, // 검색창 아래에 배치
            left: 10,
            right: 10,
            child: SingleChildScrollView(
              // 화면 크기를 초과할 경우 스크롤 기능
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    categoryMap.keys.map((categoryName) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            // 요청이 진행 중이면 새로 요청 x
                            if (globalValueController.isLoading.isTrue) {
                              print("요청이 진행 중입니다");
                              return;
                            }

                            final currentLat = currentMarkerService!.recentPosition!.latitude
                                .toStringAsFixed(6); // 소수점 6자리까지
                            final currentLon = currentMarkerService!.recentPosition!.longitude
                                .toStringAsFixed(6); // 소수점 6자리까지
                            final cacheKey =
                                '$categoryName-$currentLat-$currentLon';

                            // 이미 한 번 요청되었으면 캐시된 것을 사용
                            if (cachedPlaceList.containsKey(cacheKey)) {
                              print("이미 요청된 카테고리입니다");
                              _moveCategoryPlacePage(
                                categoryName,
                                jsonEncode(cachedPlaceList[cacheKey]),
                              );
                              return;
                            }

                            globalValueController.isLoading.value =
                                true; // 요청 시작
                            try {
                              final String? categoryCode =
                                  categoryMap[categoryName];
                              final response = await sendRequest(
                                'getPlaceList',
                                curPlaceInfo: [   //변수 이름 placeInfo  -> curPlaceInfo로 변경
                                  categoryCode!,
                                  currentMarkerService!.recentPosition!.longitude.toString(),
                                  currentMarkerService!.recentPosition!.latitude.toString(),
                                ],
                              );
                              if (response.isNotEmpty) {
                                cachedPlaceList[cacheKey] = jsonDecode(
                                  response,
                                );
                                _moveCategoryPlacePage(categoryName, response);
                              }
                            } catch (e) {
                              print("장소 요청 실패");
                            } finally {
                              globalValueController.isLoading.value =
                                  false; // 요청 완료
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            categoryName,
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          if (locateLoading)  // 위치 정보 로딩중인 경우
            Positioned.fill( // Stack의 모든 공간을 채움
              child: Container(
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          Positioned(
            // 처음 위치로 돌아오는 버튼
            width: 40,
            height: 40,
            bottom: 150.0,
            right: 16.0,
            child: FloatingActionButton(
              heroTag: 'myLocation',
              onPressed: () async {
                setState(() {
                  locateLoading = true; // 로딩 시작
                });
                await _initializePosition();

                setState(() {
                  locateLoading = false; // 로딩 완료
                });

                if (myPosition != null) {
                  mapController!.moveCamera(
                    kakao.CameraUpdate.newCenterPosition(myPosition!),
                  );
                  setState(() {
                    currentMarkerService!.recentPosition = myPosition;
                    if (currentMarkerService!.visitedPosition.isEmpty ||
                        !currentMarkerService!.isSameLatLng(currentMarkerService!.visitedPosition.last, myPosition!)) {
                      currentMarkerService!.visitedPosition.add(myPosition!);
                    }
                    tappedPosition = null;
                    tappedPlaceName = null;
                  });
                }
                setState(() {
                  currentMarkerService!.recentPosition = myPosition;
                  currentMarkerService!.visitedPosition.clear();
                  currentMarkerService!.visitedPosition.add(myPosition!);
                  tappedPosition = null;
                  tappedPlaceName = null;
                  tappedPlaceAIScore = null;
                });
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            // AI 경로 추천 버튼
            width: 40,
            height: 40,
            bottom: 150.0,
            left: MediaQuery.of(context).size.width / 2 - 20, // 버튼 너비가 40이므로 반 나눈 값
            child: Center(
              child: FloatingActionButton(
                heroTag: 'aiRoute',
                backgroundColor: Colors.white,
                child: const Icon(Icons.auto_fix_high),
                onPressed: () async {
                  // 1. 카테고리 우선순위 선택
                  final orderedCategories = await showModalBottomSheet<List<String>>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return CategorySelectorSheet(
                        categoryMap: categoryMap, // Map<String, String
                      );
                    }
                  );
                },
              ),
            ),
          ),
          Positioned(
            // 이전 장소로 돌아오는 버튼 (왼쪽 아래)
            width: 40,
            height: 40,
            bottom: 150.0,
            left: 16.0,
            child: FloatingActionButton(
              heroTag: 'back',
              child: const Icon(Icons.arrow_back),
              backgroundColor: Colors.white,
              onPressed: () {
                setState(() {
                  if (currentMarkerService!.visitedPosition.length > 1) {
                    currentMarkerService!.visitedPosition.removeLast(); // 현재 위치를 스택에서 제거
                    currentMarkerService!.recentPosition =
                        currentMarkerService!.visitedPosition.last; // 스택의 마지막 (이전 위치)로 업데이트
                    mapController!.moveCamera(
                      kakao.CameraUpdate.newCenterPosition(currentMarkerService!.recentPosition!),
                    );
                    tappedPosition = null; // 뒤로 갈 때는 클릭 위치 초기화
                    tappedPlaceName = null; // 뒤로 갈 때는 클릭 이름 초기화
                    tappedPlaceAIScore = null;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("여행지 초기 위치입니다")),
                    );
                  }
                });
              },
            ),
          ),
          DraggableScrollableSheet(
            // Poi 리스트를 보여주고 스크롤되는 하단 모달 시트
            initialChildSize: 0.2,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            controller: draggableSheetController,
            builder: (BuildContext context, ScrollController scrollController) {
              // 현재 선택된 날짜의 MarkerService
              final currentDayMarkerService = currentMarkerService;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Column( // 상단바 추가
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0), // 상단바 위아래 여백
                      child: Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300], // 연한 회색
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    // 날짜 선택 PageView
                    if (tripDates.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 10.0,
                        ),
                        child: SizedBox(
                          height: 30,
                          child: Row( // Row 위젯 추가
                            children: [
                              // 왼쪽 화살표 버튼
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios),
                                iconSize: 15,
                                onPressed: () {
                                  if (pageController.hasClients && pageController.page! > 0) {
                                    pageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                },
                              ),
                              Expanded( // PageView가 남은 공간을 차지하도록 Expanded 추가
                                child: PageView.builder(
                                  controller: pageController,
                                  itemCount: tripDates.length,
                                  onPageChanged: (index) {
                                    _selectDate(tripDates[index]); // 페이지 변경 시 날짜 선택
                                  },
                                  itemBuilder: (context, index) {
                                    final date = tripDates[index];
                                    final startDate = tripDates.first;
                                    final dayDiff = date.difference(startDate).inDays;
                                    final tripDay = dayDiff + 1; // 여행 몇일차인지 계산
                                    return Center(
                                      child: Text(
                                        "여행 ${tripDay}일차",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color:
                                          selectedDate == date ? Colors.blue : Colors.black,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // 오른쪽 화살표 버튼
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                iconSize: 15, // 아이콘 크기 조절
                                onPressed: () {
                                  if (pageController.hasClients && pageController.page! < tripDates.length - 1) {
                                    pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    Divider( // 구분선
                      height: 5,
                      thickness: 1, // 구분선의 실제 두께
                      indent: 15, // 왼쪽 여백
                      endIndent: 15, // 오른쪽 여백
                      color: Colors.grey.shade400,
                    ),
                    // POI 목록 (ReorderableListView)
                    Expanded(
                      child:
                          (currentDayMarkerService != null &&
                                  currentDayMarkerService.pois.isNotEmpty)
                              ? ReorderableListView.builder(
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    if (oldIndex < newIndex) {
                                      newIndex -= 1;
                                    }
                                    currentDayMarkerService.reorderList(
                                      oldIndex, newIndex,
                                    );
                                  });
                                },
                                scrollController: scrollController,
                                itemCount: currentDayMarkerService.pois.length,
                                itemBuilder: (context, index) {
                                  if (index >= currentDayMarkerService.pois.length) {
                                    return const SizedBox.shrink(key: ValueKey('deleted_index')); // 삭제할 때 에러 방지
                                  }
                                  final poi = currentDayMarkerService.pois[index];
                                  return ListTile(
                                    key: ValueKey(poi.id),
                                    // ReorderableListView를 위한 고유 키
                                    title: Text(poi.text!),
                                    contentPadding: EdgeInsets.only(left: 16.0, right: 5.0),
                                    trailing: IconButton(
                                      onPressed: () async {
                                        await currentDayMarkerService.deleteList(poi.id); // 목록에서 POI 삭제
                                        setState(() {}); // UI 업데이트
                                        if (currentDayMarkerService.pois.isEmpty) {
                                          draggableSheetController.jumpTo(0.2,); // 목록이 비면 시트 높이 줄임
                                        }
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                                    onTap: () {
                                      _showDialog(poi); // POI 이름 변경 다이얼로그 표시
                                    },
                                  );
                                },
                              )
                              : Center(
                                child: Text(
                                  selectedDate == null
                                      ? "여행 날짜를 설정해주세요"
                                      : "경로 리스트가 비어있습니다.",
                                ),
                              ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        onTap: _itemTapped,
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location_alt),
            label: "경로 추가",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete_forever),
            label: "경로 삭제",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.refresh), label: "경로 초기화"),
          BottomNavigationBarItem(icon: Icon(Icons.check, color: Colors.green), label: "여행 추가 하기")    //여행 추가 버튼 추가
        ],
      ),
    );
  }
}
