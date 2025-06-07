import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sample_flutter_project/fetch_fastapi_data.dart';
import 'package:sample_flutter_project/widgets/icon_text_button.dart';
import '../password_hashing.dart';
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
  String? id, pw, checkPW;
  String isDuplicate = "";
  String pwCheckVal = "";
  Color duplicateCheckColor = Colors.grey;     //ID필드의 테두리 및 중복 확인 텍스트의 색상
  double showDuplicateCheckText = 0.0;
  bool? samePW;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: screenWidth,
            height: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 80,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: Colors.white),
            child: Stack(
              children: [
                Positioned(
                  top: screenHeight * 0.2,
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
                  top: screenHeight * 0.2 + 80,
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
                                id = _textEditingController[0].text.trim();
                                if(id == ""){
                                  isDuplicate = "empty";
                                } else {
                                  isDuplicate = await sendRequest('duplicateCheck', userID: id); // 버튼 클릭 시 실행할 코드
                                }
                                setState((){});
                              },
                              child: Text(
                                '중복 확인',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1,
                                )
                              )
                            ),
                          ),
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
                              errorText: idErrorCheck(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                              errorStyle: TextStyle(
                                fontSize: 10
                              ),
                              helperText: isDuplicate == 'false' ? "사용 가능한 ID 입니다." : null,
                              helperStyle: TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
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
                        ]
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
                          errorText: pwCheckVal == "short_length" ? "" : null,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                          errorStyle: TextStyle(
                            fontSize: 0
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
                      TextField(    //비밀번호 확인 입력 필드
                        controller: _textEditingController[2],
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
                          errorText: pwCheck(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
                          errorStyle: TextStyle(
                            fontSize: 10,
                          ),
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
                      IconTextButton(   //회원가입 버튼
                        onTap: (){
                          id = _textEditingController[0].text;
                          if(id == "") {                                    //id가 입력되었는지 확인
                            isDuplicate = "empty";
                          } else if (isDuplicate == "" || isDuplicate == "true" || isDuplicate == "need_check"){
                            isDuplicate = "need_check";
                          }
                          id = _textEditingController[0].text;
                          pw = _textEditingController[1].text;
                          checkPW = _textEditingController[2].text;
                          if(pw!.length < 8){
                            pwCheckVal = "short_length";
                          } else if(pw != checkPW){
                            pwCheckVal = "different_pw";
                          } else{
                            pwCheckVal = "valid_pw";
                          }
                          setState((){});
                          if(isDuplicate == 'false' && pwCheckVal == "valid_pw" && id!.trim().isNotEmpty
                              && pw!.trim().isNotEmpty && checkPW!.trim().isNotEmpty) {
                            pw = hashPassword(pw!);
                            sendRequest('signup', userID: id, userPW: pw);
                            Get.off(
                              SafeArea(
                                top: false,
                                left: false,
                                right: false,
                                bottom: true,
                                child: LoginPage()
                              )
                            );
                          }
                        },
                        text: '회원가입',
                        textColor: Colors.white,
                        backgroundColor: Colors.deepPurple,
                        icon: Icon(Icons.person_add_outlined, size: 18, color: Colors.white),
                        borderColor: Colors.deepPurple
                      ),
                      Divider(
                        thickness: 2,
                        color: Colors.grey
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          "계정이 있으신가요?"
                        ),
                      )
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
  String? idErrorCheck(){
    if(isDuplicate == "true"){
      return "이미 있는 ID 입니다.";
    } else if(isDuplicate == "false" || isDuplicate == "") {
      return null;
    } else if(isDuplicate == "need_check"){
      return "ID 중복을 확인해 주세요.";
    } else if(isDuplicate == "empty"){
      return "ID를 입력해 주세요.";
    }else{
      return null;
    }
  }
  String? pwCheck(){
    if(pwCheckVal == "short_length") {
      return "비밀번호는 8자리 이상 이어야 합니다.";
    } else if(pwCheckVal == "different_pw"){
      return "비밀번호가 일치하지 않습니다.";
    } else{
      return null;
    }
  }
}