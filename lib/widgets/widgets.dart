import 'package:flutter/material.dart';

/// A button widget that displays a "Next" text in Korean
/// positioned at the bottom right of its container.
class ToggleButton extends StatelessWidget{
  const ToggleButton({
    Key ? key,
    this.color,
  }): super(key:key);
  final int ? color;
  @override
  Widget build(BuildContext context) {
    return _drawToggleButton(color!);
  }
  Container _drawToggleButton(int color){
    return Container(
      width: 170,
      height: 82,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 3,
            color: Color(color),
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
            '산',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(color),
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}