import 'package:flutter/material.dart';
import 'package:sample_flutter_project/widgets/widgets.dart';

class FavoriteSelectionPage1 extends StatefulWidget {
  const FavoriteSelectionPage1({super.key});

  @override
  State<StatefulWidget> createState() => _FavoriteSelectionPage1State();
}

class _FavoriteSelectionPage1State extends State<FavoriteSelectionPage1> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    int color = 0xFF808080;
    return Scaffold(
      body: Container(
        width: screenWidth, // 동적 너비
        height: screenHeight, // 동적 높이
        padding: const EdgeInsets.only(
          top: 15,
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
          spacing: 140,
          children: [
            Container(  //Title
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(   //main title
                    width: screenWidth * 0.9, // 화면 너비의 비율로 설정
                    child: Text(
                      '풍경',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 48,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ),
                  SizedBox(   //sub title
                    width: screenWidth * 0.9, // 화면 너비의 비율로 설정
                    child: Text(
                      '선호하는 항목을 선택해주세요.',
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
            ),
            Container(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.start,
                runSpacing: 30,
                children: [
                  ToggleButton(text: "산"),
                  ToggleButton(text: "바다"),
                  ToggleButton(text: "평야"),
                  ToggleButton(text: "도심"),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 11),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}