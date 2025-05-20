import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'coordinate_service.dart';

class MarkerService {
  kakao.KakaoMapController mapController;
  List<kakao.Poi> pois = []; // poi를 저장하는 리스트
  List<kakao.LatLng> poiLat = []; // poi의 좌표 리스트
  Map<String, String> uturnPoiConnected = {}; // 유턴 poi id, 이와 연결된 poi id
  List<kakao.Poi> uturnPois = []; // 유턴 poi 리스트
  List<kakao.Route> myRoute = []; // 경로에 포함된 poi 리스트
  String selectedPoiId = "";

  MarkerService({
    required this.mapController,
    required this.pois,
    required this.poiLat,
    required this.myRoute,
  });

  // 최단 경로 그리기
  Future<void> drawRoute() async {
    final shortestRoute = await RestApiService().findRoute(poiLat);
    if (shortestRoute == null) return;

    final sections = shortestRoute["routes"][0]["sections"]; // 구간별 경로 정보
    List<kakao.LatLng> polylines = []; // Route를 위한 좌표

    for (var section in sections) {
      final roads = section["roads"]; // 도로 정보
      for (var road in roads) {
        final List<dynamic> vertices = road["vertexes"]; // x, y로 구성된 배열
        for (int i = 0; i < vertices.length; i += 2) {
          polylines.add(
            kakao.LatLng(
                vertices[i + 1], vertices[i]), // 경도, 위도 순서로 되어있어서 바꿔야 함
          );
        }
      }
      final guides = section["guides"]; // 유턴 정보
      for (var guide in guides) { // 유턴 지점에 UI 아이콘 추가
        if (guide["guidance"]?.contains("유턴") == true) {
          final uturnPosition = kakao.LatLng(guide["y"], guide["x"]);
          kakao.Poi uturnPoi = await mapController.labelLayer.addPoi(
              uturnPosition,
              style: kakao.PoiStyle(
                icon: kakao.KImage.fromAsset('assets/images/uturn.png', 20, 20),
              )
          );
          uturnPois.add(uturnPoi);
          if (pois.isNotEmpty) { // 유턴 poi와 가장 최근에 추가된 경로 poi를 연결
            uturnPoiConnected[uturnPoi.id] = pois.last.id;
          }
        }
      }
    }

    if (polylines.isNotEmpty) {
      if (myRoute.isNotEmpty) { // 기존 경로를 삭제
        for (var route in myRoute) {
          await mapController.routeLayer.removeRoute(route);
        }
        myRoute.clear();
      }
      kakao.Route route = await mapController.routeLayer.addRoute(
        polylines,
        kakao.RouteStyle(Colors.blue, 15),
      );
      myRoute.add(route);
    } else {
      print("경로를 표시할 수 없습니다");
    }
  }

  // 경로 추가
  Future<void> addRoute(kakao.LatLng recentPosition, poiName) async {
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
      pois.add(poi);
      poiLat.add(recentPosition);
      if (poiLat.length >= 2) drawRoute();
      // POI 클릭 이벤트는 MethodChannel을 통해 처리됨
    } catch (e) {
      print("마커 추가 실패: $e");
    }
  }

  // 경로 삭제
  Future<void> deleteRoute() async {
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

      redrawRoute(); // 경로를 다시 그림
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
    pois.clear();
    poiLat.clear();
    uturnPois.clear();
    uturnPoiConnected.clear();
    myRoute.clear();
  }

  // 경로 리스트에서 삭제 버튼을 눌러서 삭제
  Future<void> deleteList(String poiId) async {
    int index = pois.indexWhere((poi) => poi.id == poiId);
    if (index != -1) {
      kakao.Poi selectedPoi = pois.removeAt(index);
      poiLat.removeAt(index);
      await selectedPoi.remove();
    }

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

    redrawRoute(); // 경로를 다시 그림
  }

  // Poi 리스트 순서 변경
  Future<void> reorderList(int oldIndex, int newIndex) async {
    kakao.Poi prePoi = pois.removeAt(oldIndex);
    kakao.LatLng preLat = poiLat.removeAt(oldIndex);
    pois.insert(newIndex, prePoi);
    poiLat.insert(newIndex, preLat);
    redrawRoute(); // 경로를 다시 그림
  }

  // Poi text 변경
  Future<void> renamePoi(kakao.Poi poi, String newName) async {
    await poi.changeText(newName);
    int index = pois.indexWhere((p) => p.id == poi.id);
    if (index != -1) {
      pois[index] = poi; // 리스트 업데이트
    }
  }

  // 기존 경로와 유턴 poi를 삭제하고 다시 경로를 그림
  Future<void> redrawRoute() async{
    // 기존 경로 삭제
    for (var route in myRoute) {
      await mapController.routeLayer.removeRoute(route);
    }
    myRoute.clear();

    // 기존 유턴 poi 삭제
    for (var poi in uturnPois) {
      await poi.remove();
    }
    uturnPois.clear();
    uturnPoiConnected.clear();

    if (poiLat.length >= 2) {
      await drawRoute();
    }
  }
}