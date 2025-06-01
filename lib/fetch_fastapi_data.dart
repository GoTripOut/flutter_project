import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:sample_flutter_project/global_value_controller.dart';

Future<String> sendRequest(String action, {List<String>? newPlace, List<String>? curPlaceInfo, List<dynamic>? placeInfo, String? userID, String? userPW}) async{
  final serverController = Get.find<GlobalValueController>();    //Getx를 이용한 프로그램 전역 상태 변수 관리
  String? urlStr = serverController.serverUrl.value;        //backend server의 HTTP URL획득

  print(urlStr);
  Uri url;
  http.Response? response;
  if(action == 'signup'){
    urlStr = '${urlStr}insert_user_info?userID=${userID!}&userPW=${userPW!}';
    url = Uri.parse(urlStr);
    response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  } else if(action == 'getPlaceList'){
    urlStr = '${urlStr}list/${curPlaceInfo![0]}?x=${curPlaceInfo[1]}&y=${curPlaceInfo[2]}';
    url = Uri.parse(urlStr);
    response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  } else if(action == 'duplicateCheck'){
    print(userID);
    urlStr = '${urlStr}duplicate_check?userID=${userID!}';
    url = Uri.parse(urlStr);
    response = await http.get(url);
  } else if(action == 'user_validation'){
    urlStr = '${urlStr}user_validation?userID=${userID!}&userPW=${userPW!}';
    url = Uri.parse(urlStr);
    response = await http.get(url);
  }else if(action == 'insert_new_place') {
    urlStr = '${urlStr}insert_new_place?placeName=${newPlace![0]}&userID=${userID!}&startDate=${newPlace[1]}&endDate=${newPlace[2]}';
    url = Uri.parse(urlStr);
    response = await http.post(url);
  } else if(action == 'get_user_place'){
    urlStr = '${urlStr}get_user_place?userID=${userID!}';
    url = Uri.parse(urlStr);
    response = await http.get(url);
  } else if(action == 'insert_place_info'){
    urlStr = '${urlStr}insert_place_info';
    url = Uri.parse(urlStr);
    response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "placeListID": placeInfo![0],
        "placeName": placeInfo[1],
        "x": placeInfo[2],
        "y": placeInfo[3],
        "aiScore": placeInfo[4],
        "phoneNumber": placeInfo[5],
        "order": placeInfo[6],
        "day": placeInfo[7],
      })
    );
  } else if(action == "get_place_info"){
    urlStr = '${urlStr}get_place_info?placeListID=${placeInfo![0]}';
    url = Uri.parse(urlStr);
    response = await http.get(url);
  } else if(action == 'init_place_info'){
    print("place_id: ${placeInfo![0]}");
    urlStr = '${urlStr}init_place_info?placeListID=${placeInfo![0]}';
    url = Uri.parse(urlStr);
    response = await http.post(url);
  }else {
    url = Uri.parse(urlStr);
    response = await http.get(url);
  }


  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('응답 데이터: $data');
  } else {
    print('오류 발생: ${response.statusCode}');
  }
  return response.body;
}