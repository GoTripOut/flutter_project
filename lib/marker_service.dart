import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;

class MarkerService {
  kakao.KakaoMapController mapController;
  List<kakao.Poi> pois = []; // poi를 저장하는 리스트
  List<kakao.LatLng> poiLat = []; // poi의 좌표 리스트
  List<kakao.Route> myRoute = []; // 경로에 포함된 poi 리스트
  String selectedPoiId = "";

  MarkerService({
    required this.mapController,
    required this.pois,
    required this.poiLat,
    required this.myRoute,
  });

  // 마커 연결하기
  Future<void> drawPolyline() async {
    if (pois.length < 2) return;
    kakao.Route route = await mapController!.routeLayer.addRoute(
      poiLat,
      kakao.RouteStyle(Colors.yellow, 10),
    );
    myRoute.add(route);
  }

  // 경로 추가
  Future<void> addRoute(kakao.LatLng recentPosition) async {
    if (recentPosition == null) return;
    if (poiLat.contains(recentPosition)) {
      print("이미 추가된 위치입니다");
      return;
    }
    try {
      // POI 생성
      kakao.Poi poi = await mapController!.labelLayer.addPoi(
        recentPosition,
        style: kakao.PoiStyle(
          icon: kakao.KImage.fromAsset('assets/images/marker.png', 30, 30),
        )
        ,text: "경로",
      );
      pois.add(poi);
      poiLat.add(recentPosition);
      drawPolyline();
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

      // 기존 선 삭제하고 다시 그림
      for (kakao.Route route in myRoute) {
        mapController!.routeLayer.removeRoute(route);
      }
      myRoute.clear();
      drawPolyline();
    }
  }

  // 경로 초기화
  Future<void> resetRoute() async {
    // poi 삭제
    for (kakao.Poi poi in pois) {
      await poi.remove();
    }
    // 지도에 그려진 선도 삭제
    for (kakao.Route route in myRoute) {
      mapController!.routeLayer.removeRoute(route);
    }
    // 리스트 초기화
    pois.clear();
    poiLat.clear();
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

    // 기존 선 삭제하고 다시 그림
    for (kakao.Route route in myRoute) {
      mapController!.routeLayer.removeRoute(route);
    }
    myRoute.clear();
    drawPolyline();
  }

  // Poi 리스트 순서 변경
  Future<void> reorderList(int oldIndex, int newIndex) async {
    // 기존 선 삭제하고 다시 그림
    for (kakao.Route route in myRoute) {
      mapController!.routeLayer.removeRoute(route);
    }
    myRoute.clear();

    kakao.Poi prePoi = pois.removeAt(oldIndex);
    kakao.LatLng preLat = poiLat.removeAt(oldIndex);
    pois.insert(newIndex, prePoi);
    poiLat.insert(newIndex, preLat);
    drawPolyline();
  }

  // Poi text 변경
  Future<void> renamePoi(kakao.Poi poi, String newName) async {
    await poi.changeText(newName);
    int index = pois.indexWhere((p) => p.id == poi.id);
    if (index != -1) {
      pois[index] = poi; // 리스트 업데이트
    }
  }
}
