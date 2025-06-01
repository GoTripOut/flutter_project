import 'package:flutter/material.dart';
import 'package:sample_flutter_project/widgets/toggle_button.dart';

class FavoriteSelectionPage1 extends StatefulWidget {
  const FavoriteSelectionPage1({super.key});

  @override
  State<StatefulWidget> createState() => _FavoriteSelectionPage1State();
}

class _FavoriteSelectionPage1State extends State<FavoriteSelectionPage1> {
  List<String> selectedButtons = [];
  final List<bool> _isSelected = [false, false, false, false];
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
            SizedBox(  //Title
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
            SizedBox(      //토글 버튼 컨테이너
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.start,
                runSpacing: 30,
                children: [
                  ToggleButton(
                    text: "산",
                    onPressed: (){
                      _isSelected[0] = !_isSelected[0];
                      if(_isSelected[0]) {
                        selectedButtons.add("산");
                      }
                    },
                  ),
                  ToggleButton(
                    text: "바다",
                    onPressed: (){
                      if(!selectedButtons.contains("바다")) {
                        selectedButtons.add("바다");
                      }
                    },
                  ),
                  ToggleButton(
                    text: "평야",
                    onPressed: (){
                      if(!selectedButtons.contains("산")) {
                        selectedButtons.add("산");
                      }
                    },
                  ),
                  ToggleButton(text: "도심",
                    onPressed: (){
                      if(!selectedButtons.contains("산")) {
                        selectedButtons.add("산");
                      }
                    },),
                ],
              ),
            ),
            Container(      //하단 띄우기용 컨테이너
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