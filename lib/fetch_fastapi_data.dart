import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> sendRequest(String action, {List<String>? placeInfo, String? userID, String? userPW}) async{
  String urlStr = 'http://10.0.2.2:8000/';
  Uri url;
  http.Response? response;
  if(action == 'signup'){
    urlStr += 'insert_user_info?userID=${userID!}&userPW=${userPW!}';
    url = Uri.parse(urlStr);
    response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  } else if(action == 'getPlaceList'){
    urlStr += 'list/${placeInfo![0]}?x=${placeInfo[1]}&y=${placeInfo[2]}';
    url = Uri.parse(urlStr);
    response = await http.post(url);
  } else if(action == 'duplicateCheck'){
    print(userID);
    urlStr += 'duplicate_check?userID=${userID!}';
    url = Uri.parse(urlStr);
    response = await http.get(url);
  } else{
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