import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample_flutter_project/fetch_fastapi_data.dart';
import 'package:get/get.dart';
import 'package:sample_flutter_project/screens/signup_page.dart';
import '../global_value_controller.dart';
import '../password_hashing.dart';
import '../widgets/icon_text_button.dart';
import 'main_page.dart';


class LoginPage extends StatefulWidget{
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginState();

}

class _LoginState extends State<LoginPage> {
  final List<TextEditingController> _textEditingController = List.generate(
      2, (index) => TextEditingController()
  );
  bool userAuthentication = true;
  String? id, pw;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child:Scaffold(
        body: SingleChildScrollView(
          child: Container(
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
                      TextField(    //ID 입력 필드
                        controller: _textEditingController[0],
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1,
                        ),
                        decoration: InputDecoration(
                          errorText: !userAuthentication ? "" : null,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                          errorStyle: TextStyle(
                              fontSize: 0
                          ),
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
                      TextField(    //비밀번호 입력 필드
                        controller: _textEditingController[1],
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        maxLines: 1,
                        obscureText: true,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1,
                        ),
                        decoration: InputDecoration(
                          errorText: !userAuthentication ? "잘못된 사용자 정보입니다." : null,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                          errorStyle: TextStyle(
                              fontSize: 10
                          ),
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
                      IconTextButton(
                        onTap: () async {
                          id = _textEditingController[0].text;
                          pw = _textEditingController[1].text;
                          pw = pw != "" ? hashPassword(pw!) : "";
                          userAuthentication = "true" == await sendRequest('user_validation', userID: id, userPW: pw);
                          print(userAuthentication);
                          setState((){});
                          if(userAuthentication) {
                            Get.find<GlobalValueController>().updateUserID(id!);
                            Get.off(
                              SafeArea(
                                top: false,
                                left: false,
                                right: false,
                                bottom: true,
                                child: MainPage()
                              )
                            );
                          }
                        },
                        text: "로그인", 
                        textColor: const Color(0xFF0000FF),
                        backgroundColor: Colors.white,
                        borderColor: const Color(0xFF0000FF),
                        icon: Icon(Icons.login_outlined, size: 18, color: Color(0xFF0000FF)),
                      ),
                      IconTextButton(
                        onTap:(){
                          List<String> placeInfo = ["CE7", "127.743288", "37.872316"];
                          // sendRequest("getPlaceList", placeInfo: placeInfo);
                          Get.to(
                            SafeArea(
                              child: SignupPage()
                            )
                          );
                        },
                        text: '회원가입',
                        textColor: Colors.white,
                        backgroundColor: const Color(0xFF0000FF),
                        icon: Icon(Icons.person_add_outlined, size: 18, color: Colors.white),
                        borderColor: const Color(0xFF0000FF),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      )
    );
  }
}