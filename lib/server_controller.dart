import 'package:get/get.dart';

class ServerController extends GetxController{
  var serverUrl = "".obs;

  void updateServerUrl(String url){
    serverUrl.value = url;
  }
}