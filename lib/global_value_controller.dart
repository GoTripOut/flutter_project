import 'dart:convert';

import 'package:get/get.dart';

import 'fetch_fastapi_data.dart';
import 'widgets/day.dart';

class GlobalValueController extends GetxController{
  var serverUrl = "".obs;
  var isLoading = false.obs; // 요청 진행중
  var isGetPlaceList = false.obs;
  var userID = "".obs;
  var placeList = [].obs;
  var introPageIndex = 0.obs;
  var selectedPlace = "".obs;
  var isFirstSelect = false.obs;
  var isSecondSelect = false.obs;
  var selectedPlaceListID = 0.obs;
  var firstSelectedDate = Day(
    day: DateTime(0),
    isInMonth: false,
    isVisible: false,
    isInRange: false,
    isSelected: false,
  ).obs;
  var startDate = DateTime(0).obs;
  var secondSelectedDate = Day(
    day: DateTime(0),
    isInMonth: false,
    isVisible: false,
    isInRange: false,
    isSelected: false,
  ).obs;
  var endDate = DateTime(0).obs;
  var validWeeks = <bool>[false, false, false, false, false, false].obs;

  void updateServerUrl(String url){
    serverUrl.value = url;
    update();
  }

  Future<bool> updatePlaceList() async {
    isGetPlaceList.value = false;
    String response = await sendRequest('get_user_place', userID: userID.value);
    print("upate_place_list");
    if(response != "failed"){
      placeList.value = jsonDecode(await sendRequest('get_user_place', userID: userID.value));
      update();
      isGetPlaceList.value = true;
      return true;
    } else {
      isGetPlaceList.value = false;
      return true;
    }

  }

  void updateUserID(String id){
    userID.value = id;
    update();
  }

  void updateSelectedPlace(String name){
    selectedPlace.value = name;
    update();
  }

  void updateFirstSelected(Day firstDate){
    firstSelectedDate.value = firstDate;
    startDate.value = firstDate.day;
    isFirstSelect.value = true;
    update();
  }

  void updateSecondSelected(Day secondDate){
    secondSelectedDate.value = secondDate;
    endDate.value = secondDate.day;
    isSecondSelect.value = true;
    update();
  }

  void updateDate(DateTime start, DateTime end){
    startDate.value = start;
    endDate.value = end;
    update();
  }

  void initFirstSelected(){
    isFirstSelect.value = false;
    update();
  }

  void initSecondSelected(){
    isSecondSelect.value = false;
    secondSelectedDate.value = Day(
      day: DateTime(0),
      isInMonth: false,
      isVisible: false,
      isInRange: false,
      isSelected: false,
    );
    endDate.value = DateTime(0);
    update();
  }

  void updateValidWeeks(int i, bool valid){
    validWeeks[i] = valid;
    update();
  }

  void updateSelectedPlaceListID(int id){
    selectedPlaceListID.value = id;
    update();
  }

  void updateIntroPageIndex(int i){
    introPageIndex.value = i;
    print(i);
    update();
  }
}