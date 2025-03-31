import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/config/.env');
  String? kakaoNativeAppKey = dotenv.env['KAKAO_MAP_KEY'];

  if (kakaoNativeAppKey == null) {
    throw Exception('KAKAO_MAP_KEY가 .env 파일에 정의되지 않았습니다.');
  }

  await KakaoMapSdk.instance.initialize(kakaoNativeAppKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? myPosition;
  KakaoMapController? mapController;

  @override
  void initState() {
    super.initState();
    _getPermission();
  }

  // 위치 권한 요청
  Future<void> _getPermission() async{
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      print('위치 서비스가 꺼져있습니다');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("위치 권한이 거부되었습니다.");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print("위치 권한이 거부되었습니다.");
      return;
    }
    _getPosition();
  }

  // 현재 위치 가져오기
  Future<void> _getPosition() async{
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      myPosition = position;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: myPosition != null ? KakaoMap(
        option: KakaoMapOption(
          position: LatLng(myPosition!.latitude, myPosition!.longitude),
        ),
        onMapReady: (KakaoMapController controller) {
          mapController = controller;
          print("카카오 지도가 정상적으로 불러와졌습니다.");
          // Poi 추가
          controller.labelLayer.addPoi(
              LatLng(myPosition!.latitude, myPosition!.longitude),
              style: PoiStyle(icon: KImage.fromAsset('assets/images/marker.png', 70, 70),
          ));
        },
      ): const Center(child: CircularProgressIndicator()),
    );
  }
}