import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_flutter_project/fetch_fastapi_data.dart';
import 'package:sample_flutter_project/global_value_controller.dart';
import 'package:sample_flutter_project/screens/MyHomePage.dart';
import 'package:sample_flutter_project/screens/add_new_place_page.dart';
import 'package:sample_flutter_project/screens/favorite_selection_page_1.dart';
import 'package:sample_flutter_project/screens/favorite_selection_page_3.dart';
import 'package:intl/intl.dart';
import 'favorite_selection_page_2.dart';

class IntroPageView extends StatefulWidget{
  const IntroPageView({super.key});

  @override
  createState() => _IntroPageViewState();
}

class _IntroPageViewState extends State<IntroPageView>{
  var valueController = Get.find<GlobalValueController>();
  late final PageController _pageController;
  late final List<Widget> pages;
  @override
  void initState(){
    super.initState();
    _pageController = PageController();
    valueController.updateIntroPageIndex(0);
    pages = [AddNewPlacePage(controller: _pageController,), FavoriteSelectionPage1(), FavoriteSelectionPage2(), FavoriteSelectionPage3(), MyHomePage(title: 'flutterdemo')];
  }
  //페이지들을 관리할 리스트

  Widget prevButton(){    //이전 버튼 생성
    return  Positioned(
      bottom: 10, // 버튼 위치 조정
      left: 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () {
              int pageIndex = valueController.introPageIndex.value;
              if (pageIndex > 0) {
                valueController.updateIntroPageIndex(--pageIndex);
              }
              print(pageIndex);
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF0000FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 11),
            ),
            child: const Text(
              "이전",
              style: TextStyle(
                leadingDistribution: TextLeadingDistribution.even,
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget nextButton(){    //이전 버튼과 동일
    return  Positioned(
      bottom: 10, // 버튼 위치 조정
      right: 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () async {
              int pageIndex = valueController.introPageIndex.value;
              valueController.updateIntroPageIndex(++pageIndex);
              if(pageIndex == 4){
                DateTime startDate = valueController.firstSelectedDate.value.day;
                DateTime endDate = valueController.secondSelectedDate.value.day;
                String result = await sendRequest('insert_new_place', newPlace: [valueController.selectedPlace.value, DateFormat('yyyy-MM-dd').format(startDate), DateFormat('yyyy-MM-dd').format(endDate)], userID: valueController.userID.value);
                final decodeResult = jsonDecode(result);
                valueController.updateSelectedPlaceListID(decodeResult[0][0]);
              }
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF0000FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 11),
            ),
            child: const Text(
              "다음",
              style: TextStyle(
                leadingDistribution: TextLeadingDistribution.even,
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {    //페이지뷰 빌드
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child:Scaffold(
        body: Stack(
          children:[
            PageView(
              physics: const NeverScrollableScrollPhysics(),    //터치로 스크롤 방지
              controller: _pageController,
              children: pages,
              ),
            //처음 페이지:nextButton만
            //마지막 페이지:버튼 없음. 이전 페이지들 리스트에서 삭제
            //이외:이전, 다음 버튼
            Obx(() => valueController.introPageIndex.value == 1
                ? nextButton() : valueController.introPageIndex.value < 4 && valueController.introPageIndex.value > 1
                ? Stack(children: [prevButton(), nextButton()]) : SizedBox.shrink())
          ],
        )
      )
    );
  }
}