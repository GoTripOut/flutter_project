import 'package:flutter/material.dart';
import 'package:sample_flutter_project/screens/MyHomePage.dart';
import 'package:sample_flutter_project/screens/favorite_selection_page_1.dart';
import 'package:sample_flutter_project/screens/favorite_selection_page_3.dart';
import 'package:sample_flutter_project/screens/intro_page.dart';

import 'favorite_selection_page_2.dart';

class IntroPageView extends StatefulWidget{
  const IntroPageView({super.key});

  @override
  createState() => _IntroPageViewState();
}

class _IntroPageViewState extends State<IntroPageView>{
  late final PageController _pageController;
  int pageIndex = 0;    //현재 페이지 인덱스

  @override
  void initState(){
    super.initState();
    _pageController = PageController();
  }
  //페이지들을 관리할 리스트
  List<Widget> pages = [IntroPage(), FavoriteSelectionPage1(), FavoriteSelectionPage2(), FavoriteSelectionPage3(), MyHomePage(title: 'flutterdemo')];
  Widget prevButton(){    //이전 버튼 생성
    return  Positioned(
      bottom: 10, // 버튼 위치 조정
      left: 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () {
              setState((){    //레이아웃 업데이트
                if (pageIndex > 0) {
                  pageIndex--;
                }
                print(pageIndex);
              });
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
            onPressed: () {
              setState((){
                if (pageIndex < 4) {
                  pageIndex++;
                } else if(pageIndex == 4){
                  pages.removeAt(0);
                  pages.removeAt(1);
                  pages.removeAt(2);
                  pages.removeAt(3);
                }
                print(pageIndex);
              });
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
    return Scaffold(
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
          if(pageIndex == 0) nextButton()
          else if(pageIndex != 4) ...[prevButton(), nextButton()]
          else Container()
        ],
      )
    );
  }
}