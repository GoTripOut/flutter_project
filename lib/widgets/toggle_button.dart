import 'package:flutter/material.dart';

/// A button widget that displays a "Next" text in Korean
/// positioned at the bottom right of its container.
class ToggleButton extends StatefulWidget {
  final String text;
  final Function onPressed;
  const ToggleButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  createState() => _ToggleButtonState();
}
class _ToggleButtonState extends State<ToggleButton>{
  int button_color = 0xFF808080;    //기본 버튼 컬러
  bool _isSelected = false;         //토글 버튼 선택 상태
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onPressed;
        setState((){    //상태 변경 및 레이아웃 업데이트
          _isSelected = !_isSelected;
          if(_isSelected) {
            button_color = 0xFF0000FF;
          } else{
            button_color = 0xFF808080;
          }
        });
      },
        child: Container(   //토글 버튼
          width: 170,
          height: 82,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 3,
                color: Color(button_color),
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(button_color),
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
    );
  }
}