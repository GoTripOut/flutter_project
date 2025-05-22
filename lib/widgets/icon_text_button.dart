import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget{
  final VoidCallback onTap;
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final Icon icon;
  const IconTextButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.icon,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(    //회원 가입 버튼
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Container(
              width: 18,
              height: 18,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: icon,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 18,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                ),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}