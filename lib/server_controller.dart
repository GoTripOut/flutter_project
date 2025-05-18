import 'package:get/get.dart';

class ServerController extends GetxController{
  var serverUrl = "".obs;
  var isLoading = false.obs; // 요청 진행중

  void updateServerUrl(String url){
    serverUrl.value = url;
  }
}