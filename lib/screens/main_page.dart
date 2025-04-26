import 'package:flutter/material.dart';

import '../widgets/route_list_builder.dart';
import 'MyHomePage.dart';
import 'intro_page_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });
  @override
  createState() => _MainPageState();
}
class _MainPageState extends State<MainPage>{
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double startPosition = 0.06;
    return Scaffold(
      appBar: AppBar(
        title: Text("홈"),
        actions:[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: (){

            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: (){

            },
          )
        ]
      ),
      body: Container(
        width: screenWidth, // 동적 너비
        height: screenHeight, // 동적 높이
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: const Color(0xFFF0F0F0)),
        child: Stack(
          children: [
            Positioned(
              child: Center(
                child:SizedBox(
                  width: screenWidth * 0.88,
                  height: screenHeight * 0.9,
                  child: RouteListBuilder(routeContent: [['강릉', '2025-04-26']],)
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => SafeArea(child: IntroPageView()))
          );
        }
      ),
    );
  }
}
