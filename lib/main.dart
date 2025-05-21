import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'package:sample_flutter_project/screens/login_page.dart';
import 'package:sample_flutter_project/global_value_controller.dart';
import 'dart:io';

void listenFastAPIBroadCast() async {
  print("get broadcast message");
  RawDatagramSocket socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888);
  socket.listen((RawSocketEvent event) async {
    if(event == RawSocketEvent.read){
      print("read_broadcast_message");
      Datagram? datagram = socket.receive();
      if(datagram != null){
        print("get_datagram");
        String serverUrl = String.fromCharCodes(datagram.data).trim();
        print(serverUrl);
        final response = await http.get(Uri.parse("${serverUrl}get_connect_state"));
        if(response.statusCode == 200) {
          print(response.body);
          Get.find<GlobalValueController>().updateServerUrl(serverUrl);
          socket.close();
        }
      }
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');
  String? kakaoNativeAppKey = dotenv.env['KAKAO_MAP_KEY'];

  if (kakaoNativeAppKey == null) {
    throw Exception('KAKAO_MAP_KEY가 .env 파일에 정의되지 않았습니다.');
  }

  await kakao.KakaoMapSdk.instance.initialize(kakaoNativeAppKey);
  Get.put(GlobalValueController());
  listenFastAPIBroadCast();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widgets is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: LoginPage(),
      ),
    );
  }
}