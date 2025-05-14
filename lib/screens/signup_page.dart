import 'package:flutter/material.dart';
import 'package:sample_flutter_project/fetch_fastapi_data.dart';
import 'login_page.dart';


class SignupPage extends StatefulWidget{
  const SignupPage({
    super.key,
  });

  @override
  State<SignupPage> createState() => _SignupPage();

}

class _SignupPage extends State<SignupPage> {
  final List<TextEditingController> _textEditingController = List.generate(
      3, (index) => TextEditingController()
  );
  String? id, pw, checkPW, isDuplicate;
  bool? samePW;
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
                '회원가입',
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
                  Column(
                    spacing: screenHeight * 0.001,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            id = _textEditingController[0].text;
                            isDuplicate = await sendRequest('duplicateCheck', userID: id);// 버튼 클릭 시 실행할 코드
                          },
                          child: Text(
                            '중복 확인',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(   //ID입력 필드
                        height: 40,
                        child:TextField(
                          controller: _textEditingController[0],
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
                    ]
                  ),
                  SizedBox(   //비밀번호 입력 필드
                    height: 40,
                    child:TextField(
                      controller: _textEditingController[1],
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
                  SizedBox(   //비밀번호 입력 필드
                    height: 40,
                    child:TextField(
                      controller: _textEditingController[2],
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '비밀번호 확인',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          height: 1,
                        )
                      ),
                    ),
                  ),
                  InkWell(    //회원가입 버튼
                    onTap:(){
                      id = _textEditingController[0].text;
                      pw = _textEditingController[1].text;
                      checkPW = _textEditingController[2].text;
                      if(isDuplicate == 'false' && pw == checkPW && id!.trim().isNotEmpty
                          && pw!.trim().isNotEmpty && checkPW!.trim().isNotEmpty) {
                        sendRequest('signup', userID: id, userPW: pw);
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) =>
                                SafeArea(child: LoginPage()))
                        );
                      }
                    },
                    child: Container(
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