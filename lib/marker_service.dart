import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'package:sample_flutter_project/fetch_fastapi_data.dart';
import 'package:sample_flutter_project/global_value_controller.dart';
import 'coordinate_service.dart';

class MarkerService {
  kakao.KakaoMapController mapController;
  var valueController = Get.find<GlobalValueController>();
  List<String> places = []; // 추가된 장소 이름을 저장하는 리스트
  List<double?> aiScores = []; // 추가된 장소의 AIScore를 저장하는 리스트
  List<kakao.Poi> pois = []; // poi를 저장하는 리스트
  List<kakao.LatLng> poiLat = []; // poi의 좌표 리스트
  Map<String, String> uturnPoiConnected = {}; // 유턴 poi id, 이와 연결된 poi id
  List<kakao.Poi> uturnPois = []; // 유턴 poi 리스트
  List<kakao.Route> myRoute = []; // 경로에 포함된 poi 리스트
  List<kakao.LatLng> visitedPosition = []; // 날짜별 방문 리스트
  String selectedPoiId = "";
  kakao.LatLng? recentPosition; // 해당하는 날짜의 최근 위치
  int selectedDay;
  final List<Color> routeColor = [
    Colors.grey.shade400,   // 회색
    Colors.green.shade400,  // 초록색
    Colors.amber.shade400,  // 겨자색
    Colors.orange.shade400, // 주황색
  ];

  MarkerService({
    required this.mapController,
    required this.selectedDay,
    List<kakao.Poi>? initialPois,
    List<kakao.LatLng>? initialPoiLat,
    List<kakao.Route>? initialRoute,
    List<kakao.LatLng>? initialVisitedPosition,
    kakao.LatLng? initialRecentPosition,
  }) : pois = initialPois ?? [],
  poiLat = initialPoiLat ?? [],
  myRoute = initialRoute ?? [],
  visitedPosition = initialVisitedPosition ?? [],
  recentPosition = initialRecentPosition;

  // 위도, 경도 비교
  bool isSameLatLng(kakao.LatLng pos1, kakao.LatLng pos2) {
    return pos1.latitude == pos2.latitude && pos1.longitude == pos2.longitude;
  }

  // 지도에서 기존 경로와 유턴 poi만 제거
  Future<void> removeRouteFromMap() async {
    for (var route in myRoute) {
      await mapController.routeLayer.removeRoute(route);
    }
    myRoute.clear();

    for (var poi in uturnPois) {
      await poi.remove();
    }
    uturnPois.clear();
    uturnPoiConnected.clear();
  }

  // 최단 경로 그리기
  Future<void> drawRoute() async {
    await removeRouteFromMap();
    if (poiLat.length < 2) return;

    final shortestRoute = await RestApiService().findRoute(poiLat);
    if (shortestRoute == null) return;

    final sections = shortestRoute["routes"][0]["sections"]; // 구간별 경로 정보
    int colorIndex = 0;

    for (var section in sections) {
      final roads = section["roads"]; // 도로 정보
      List<kakao.LatLng> polylines = []; // 각 구간의 경로를 위한 좌표

      for (var road in roads) {
        final List<dynamic> vertices = road["vertexes"]; // x, y로 구성된 배열
        for (int i = 0; i < vertices.length; i += 2) {
          polylines.add(
            kakao.LatLng(
              vertices[i + 1], // y 위도
              vertices[i], // x 경도
            ), // 경도, 위도 순서로 되어있어서 바꿔야 함
          );
        }
      }

      final guides = section["guides"]; // 유턴 정보
      for (var guide in guides) {
        // 유턴 지점에 UI 아이콘 추가
        if (guide["guidance"]?.contains("유턴") == true) {
          final uturnPosition = kakao.LatLng(guide["y"], guide["x"]);
          kakao.Poi uturnPoi = await mapController.labelLayer.addPoi(
            uturnPosition,
            style: kakao.PoiStyle(
              icon: kakao.KImage.fromAsset('assets/images/uturn.png', 20, 20),
            ),
          );
          uturnPois.add(uturnPoi);
          if (pois.isNotEmpty) {
            // 유턴 poi와 가장 최근에 추가된 경로 poi를 연결
            uturnPoiConnected[uturnPoi.id] = pois.last.id;
          }
        }
      }

      if (polylines.isNotEmpty) {
        Color myColor = routeColor[colorIndex % routeColor.length];
        kakao.Route route = await mapController.routeLayer.addRoute(
          polylines,
          kakao.RouteStyle(myColor, 15),
        );
        myRoute.add(route);
        colorIndex++;
      } else {
        print("경로를 표시할 수 없습니다");
      }
    }
  }

  // 경로 추가 - aiScore 추가함
  Future<void> addRoute(kakao.LatLng recentPosition, String? poiName, double? aiScore) async {
    if (poiLat.contains(recentPosition)) {
      print("이미 추가된 위치입니다");
      return;
    }
    try {
      // POI 생성
      kakao.Poi poi = await mapController.labelLayer.addPoi(
        recentPosition,
        style: kakao.PoiStyle(
          icon: kakao.KImage.fromAsset('assets/images/marker.png', 30, 30),
        ),
        text: poiName ?? "경로",
      );
      places.add(poiName ?? "경로");
      aiScores.add(aiScore);
      pois.add(poi);
      poiLat.add(recentPosition);

      if (poiLat.length >= 2) await drawRoute();
      // POI 클릭 이벤트는 MethodChannel을 통해 처리됨
    } catch (e) {
      print("마커 추가 실패: $e");
    }
  }

  // 선택된 poi를 삭제
  Future<void> deleteRoute() async {
    if (selectedPoiId.isEmpty) return;

    int index = pois.indexWhere((poi) => poi.id == selectedPoiId);
    if (index != -1) {
      kakao.Poi selectedPoi = pois.removeAt(index);
      poiLat.removeAt(index);
      await selectedPoi.remove();

      List<String> uturnsRemove = []; // 삭제할 경로와 연결된 여러 개의 유턴 poi 리스트
      uturnPoiConnected.forEach((uturnId, connectedPoiId) {
        if (connectedPoiId == selectedPoiId) {
          uturnsRemove.add(uturnId);
        }
      });

      for (var uturnId in uturnsRemove) {
        final uturnRemove = uturnPois.firstWhere((poi) => poi.id == uturnId);
        await uturnRemove.remove();
        uturnPois.remove(uturnRemove);
        uturnPoiConnected.remove(uturnId);
      }

      await redrawRoute(); // 경로를 다시 그림
      selectedPoiId = "";
    }
  }

  // 경로 초기화
  Future<void> resetRoute() async {
    // poi 삭제
    for (kakao.Poi poi in pois) {
      await poi.remove();
    }
    // 유턴 poi 삭제
    for (kakao.Poi poi in uturnPois) {
      await poi.remove();
    }
    // 지도에 그려진 선도 삭제
    for (kakao.Route route in myRoute) {
      mapController.routeLayer.removeRoute(route);
    }
    // 리스트 초기화
    places.clear();
    aiScores.clear();
    pois.clear();
    poiLat.clear();
    uturnPois.clear();
    uturnPoiConnected.clear();
    myRoute.clear();
    selectedPoiId = "";
  }

  // 경로 리스트에서 삭제 버튼을 눌러서 삭제
  Future<void> deleteList(String poiId) async {
    int index = pois.indexWhere((poi) => poi.id == poiId);
    if (index != -1) {
      kakao.Poi selectedPoi = pois[index];
      pois.removeAt(index);
      aiScores.removeAt(index);
      places.removeAt(index);
      poiLat.removeAt(index);
      await selectedPoi.remove();

      List<String> uturnsRemove = []; // 삭제할 경로와 연결된 여러 개의 유턴 poi 리스트
      uturnPoiConnected.forEach((uturnId, connectedPoiId) {
        if (connectedPoiId == poiId) {
          uturnsRemove.add(uturnId);
        }
      });

      for (var uturnId in uturnsRemove) {
        final uturnRemovePoi = uturnPois.firstWhere((poi) => poi.id == uturnId);
        await uturnRemovePoi.remove();
        uturnPois.remove(uturnRemovePoi);
        uturnPoiConnected.remove(uturnId);
      }

      await redrawRoute(); // 경로를 다시 그림
    }
  }

  // Poi 리스트 순서 변경
  Future<void> reorderList(int oldIndex, int newIndex) async {
    kakao.Poi prePoi = pois.removeAt(oldIndex);
    kakao.LatLng preLat = poiLat.removeAt(oldIndex);
    String place = places.removeAt(oldIndex);
    double? aiScore = aiScores.removeAt(oldIndex);
    aiScores.insert(newIndex, aiScore);
    places.insert(newIndex, place);
    pois.insert(newIndex, prePoi);
    poiLat.insert(newIndex, preLat);
    await redrawRoute(); // 경로를 다시 그림
  }

  // Poi text 변경
  Future<void> renamePoi(kakao.Poi poi, String newName) async {
    await poi.changeText(newName);
    int index = pois.indexWhere((p) => p.id == poi.id);
    if (index != -1) {
      pois[index] = poi; // 리스트 업데이트
      places[index] = newName;
    }
  }

  // 기존 경로와 유턴 poi를 지도에서 지우고 다시 경로를 그림
  Future<void> redrawRoute() async {
    await removeRouteFromMap(); // 기존 경로 및 유턴 POI 제거
    if (poiLat.length >= 2) await drawRoute();
  }

  // 모든 poi와 경로를 지도에 숨김
  Future<void> hideFromMap() async {
    for (kakao.Poi poi in pois) {
      if (poi.visible) {
        await poi.hide();
      }
    }
    for (kakao.Poi poi in uturnPois) {
      if (poi.visible) {
        await poi.hide();
      }
    }
    for (kakao.Route route in myRoute) {
      if (route.visible) {
        await route.hide();
      }
    }
  }

  // 추가/변경 된 추천 경로 정보를 백엔드 서버로 전송 및 업데이트
  Future<void> updatePlan() async{
    if(selectedDay > 1) {
      await sendRequest(
          'init_place_info', placeInfo: [valueController.selectedPlaceListID]);
    }
    for(int i = 0; i < places.length; i++) {
      await sendRequest(
        'insert_place_info',
        placeInfo: [
          valueController.selectedPlaceListID.value,
          places[i],
          poiLat[i].longitude,
          poiLat[i].latitude,
          aiScores[i],
          null,
          i,
          selectedDay,
        ]
      );
    }
  }
  // 모든 poi와 경로를 지도에서 보여줌
  Future<void> showFromMap() async {
    for (kakao.Poi poi in pois) {
      if (!poi.visible) {
        await poi.show();
      }
    }
    for (kakao.Poi poi in uturnPois) {
      if (!poi.visible) {
        await poi.show();
      }
    }
    for (kakao.Route route in myRoute) {
      if (!route.visible) {
        await route.show();
      }
    }
    await drawRoute();
  }
}
