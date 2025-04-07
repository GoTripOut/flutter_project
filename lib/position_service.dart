import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:geolocator/geolocator.dart';

class PositionService {
  // 위치 권한 요청
  Future<bool> getPermission() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      print("위치 서비스가 꺼져있습니다");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("위치 권한이 거부되었습니다.");
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print("위치 권한이 거부되었습니다.");
      return false;
    }
    return true;
  }

  // 현재 위치 가져오기
  Future<LatLng?> getPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("현재 위치를 가져오지 못했습니다 $e");
    }
    return null;
  }
}