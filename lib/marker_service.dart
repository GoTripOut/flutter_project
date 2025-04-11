import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'dart:developer';

class MarkerService {
  kakao.KakaoMapController mapController;
  List<kakao.Poi> pois = []; // poi를 저장하는 리스트
  String selectedPoiId = "";
  List<kakao.LatLng> poiLat = []; // poi의 좌표 리스트
  List<kakao.Route> myRoute = []; // 경로에 포함된 poi 리스트

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
  Future<void> addRoute(kakao.LatLng recentPostion) async {
    if (recentPostion == null) return;
    if (poiLat.contains(recentPostion)) {
      print("이미 추가된 위치입니다");
      return;
    }

    try {
      // POI 생성
      kakao.Poi poi = await mapController!.labelLayer.addPoi(
        recentPostion,
        style: kakao.PoiStyle(
          icon: kakao.KImage.fromAsset('assets/images/marker.png', 70, 70),
        ),
      );

      pois.add(poi);
      poiLat.add(recentPostion);
      drawPolyline();

      // POI 클릭 이벤트는 MethodChannel을 통해 처리됨
    } catch (e) {
      print("마커 추가 실패: $e");
    }
  }


  // 경로 삭제
  Future<void> deleteRoute() async {
    kakao.Poi selectedPoi;
    if (pois.isNotEmpty) {
      for(int i = 0; i < pois.length; i++){
        if(pois[i].id == selectedPoiId){
          selectedPoi = pois.removeAt(i);
          poiLat.removeAt(i);
          await selectedPoi.remove();
          break;
        }
      }
      log("deleteRoute", name: 'log_poi');

      // 기존 선 삭제하고 다시 그림
      for (kakao.Route route in myRoute) {
        mapController!.routeLayer.removeRoute(route);
      }
      myRoute.removeLast();
      drawPolyline();
    }
  }

  // 경로 초기화
  Future<void> resetRoute() async {
    for (kakao.Poi poi in pois) {
      await poi.remove();
    }
    pois.clear();
    poiLat.clear();

    // 지도에 그려진 선도 삭제
    for (kakao.Route route in myRoute) {
      mapController!.routeLayer.removeRoute(route);
    }
    myRoute.clear();
  }
}
