import 'package:flutter/material.dart';
import 'package:sample_flutter_project/widgets/toggle_button.dart';

class FavoriteSelectionPage2 extends StatefulWidget {
  const FavoriteSelectionPage2({super.key});

  @override
  State<StatefulWidget> createState() => _FavoriteSelectionPage2State();
}

class _FavoriteSelectionPage2State extends State<FavoriteSelectionPage2> {
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
                      '음식',
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
                    text: "한식",
                    onPressed: (){
                      _isSelected[0] = !_isSelected[0];
                      if(_isSelected[0]) {
                        selectedButtons.add("한식");
                      } else{
                        selectedButtons.remove("한식");
                      }
                    },
                  ),
                  ToggleButton(
                    text: "중식",
                    onPressed: (){
                      _isSelected[1] = !_isSelected[1];
                      if(_isSelected[1]) {
                        selectedButtons.add("중식");
                      } else{
                        selectedButtons.remove("중식");
                      }
                    },
                  ),
                  ToggleButton(
                    text: "양식",
                    onPressed: (){
                      _isSelected[2] = !_isSelected[2];
                      if(_isSelected[2]) {
                        selectedButtons.add("양식");
                      } else{
                        selectedButtons.remove("양식");
                      }
                    },
                  ),
                  ToggleButton(text: "일식",
                    onPressed: (){
                      _isSelected[3] = !_isSelected[3];
                      if(_isSelected[3]) {
                        selectedButtons.add("일식");
                      } else{
                        selectedButtons.remove("일식");
                      }
                    },
                  ),
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