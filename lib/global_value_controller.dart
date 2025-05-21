import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class GlobalValueController extends GetxController{
  var serverUrl = "".obs;
  var userID = "".obs;
  var placeList = [].obs;
  var introPageIndex = 0.obs;
  var selectedPlace = "".obs;
  var isFirstSelect = false.obs;
  var isSecondSelect = false.obs;
  var firstSelectedDate = {
    "year": 0,
    "month": 0,
    "day":0,
    "isInMonth": false,
    "isNextDay": false,
  }.obs;
  var secondSelectedDate = {
    "year": 0,
    "month": 0,
    "day":0,
    "isInMonth": false,
    "isNextDay": false,
  }.obs;
  var startDate = "".obs;
  var endDate = "".obs;
  var validWeeks = <bool>[false, false, false, false, false, false].obs;

  void updateServerUrl(String url){
    serverUrl.value = url;
    update();
  }

  void updatePlaceList(List<String> list){
    placeList.value = list;
    update();
  }

  void updateUserID(String id){
    userID.value = id;
    update();
  }

  void updateSelectedPlace(String name){
    selectedPlace.value = name;
    update();
  }

  void updateFirstSelected(bool first, var firstDate){
    isFirstSelect.value = first;
    firstSelectedDate.value = firstDate;
    startDate.value = "${firstDate["year"]}-${firstDate["month"]}-${firstDate["day"]}";
    update();
  }

  void updateSecondSelected(bool second, var secondDate){
    isSecondSelect.value = second;
    secondSelectedDate.value = secondDate;
    endDate.value = "${secondDate["year"]}-${secondDate["month"]}-${secondDate["day"]}";
    update();
  }

  void updateValidWeeks(int i, bool valid){
    validWeeks[i] = valid;
    update();
  }

  void updateIntroPageIndex(int i){
    introPageIndex.value = i;
    print(i);
    update();
  }
}