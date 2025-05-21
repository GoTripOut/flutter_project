import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:sample_flutter_project/global_value_controller.dart';

Future<String> sendRequest(String action, {List<String>? newPlace, List<String>? placeInfo, String? userID, String? userPW}) async{
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
    urlStr = '${urlStr}list/${placeInfo![0]}?x=${placeInfo[1]}&y=${placeInfo[2]}';
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
  }else{
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