import 'package:flutter/material.dart';
import 'package:sample_flutter_project/screens/favorite_selection_page_1.dart';
class IntroPage extends StatelessWidget {
  const IntroPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _IntroPage();
  }
}

class _IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: screenWidth, // 동적 너비
        height: screenHeight, // 동적 높이
        padding: const EdgeInsets.only(
          top: 40,
          left: 15,
          right: 15,
          bottom: 10,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: screenWidth * 0.9, // 화면 너비의 비율로 설정
                  child: Text(
                    '반갑습니다!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 48,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.9, // 화면 너비의 비율로 설정
                  child: Text(
                    '여러분의 여행 스타일을 알려주세요!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: screenWidth * 0.9, // 화면 너비의 비율로 설정
              child: Text(
                '앞으로 나올 세 가지 질문에 답해주시면 여행 계획 수립에 도움이 됩니다.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1,
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 11),
                child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}