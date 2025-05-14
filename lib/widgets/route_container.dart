import 'package:flutter/material.dart';
import 'package:sample_flutter_project/screens/MyHomePage.dart';

class RouteContainer extends StatefulWidget{
  const RouteContainer({
    super.key,
    required this.place,
    required this.date,
  });

  final String place;
  final String date;
  @override
  createState() => _RouteContainerState();
}

class _RouteContainerState extends State<RouteContainer> with SingleTickerProviderStateMixin{
  late AnimationController animationController;
  late double screenHeight;
  @override
  void initState(){
    super.initState();
    animationController = BottomSheet.createAnimationController(this);
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => SafeArea(child: MyHomePage(title: 'demo')))
        );
      },
      style: TextButton.styleFrom(
        fixedSize: Size(screenWidth * 0.88, 77),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        widget.place,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 16,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}