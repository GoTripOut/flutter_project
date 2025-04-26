import 'package:flutter/material.dart';

import 'intro_page_view.dart';
import 'main_page.dart';


class LoginPage extends StatefulWidget{
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginState();

}

class _LoginState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Positioned(
              top: screenHeight * 0.25,
              width: screenWidth,
              child: Text(
                '로그인',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Positioned( //로그인 ID, PW, 로그인, 회원가입 버튼 컨테이너
              top: screenHeight * 0.4,
              left: screenWidth * 0.1,
              width: screenWidth * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: screenHeight * 0.02,
                children: [
                  SizedBox(   //ID입력 필드
                    height: 40,
                    child:TextField(
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '사용자 이름',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          height: 1,
                        )
                      ),
                    ),
                  ),
                  SizedBox(   //비밀번호 입력 필드
                    height: 40,
                    child:TextField(
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1,
                      ),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: '비밀번호',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            height: 1,
                          )
                      ),
                    ),
                  ),
                  InkWell(    //로그인 버튼
                    onTap:(){
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => SafeArea(child: MainPage()))
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: const Color(0xFF0000FF),
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
                            child: Icon(Icons.login_outlined, size: 18, color: Color(0xFF0000FF)),
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
                                '로그인',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF0000FF),
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
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF0000FF),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: const Color(0xFF0000FF),
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
                          child: Icon(Icons.person_add_outlined, size: 18, color: Colors.white),
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
                              '회원가입',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}