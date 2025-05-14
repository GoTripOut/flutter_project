import 'package:flutter/material.dart';
import 'package:sample_flutter_project/widgets/route_container.dart';

class RouteListBuilder extends StatefulWidget{
  const RouteListBuilder({
    super.key,
    required this.routeContent,
  });
  final List<List<String>> routeContent;

  @override
  createState() => _RouteListBuilderState();
}

class _RouteListBuilderState extends State<RouteListBuilder>{
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.8,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Wrap(
          spacing: 10,
          direction: Axis.vertical,
          children: widget.routeContent.map((content){
            return RouteContainer(place: content[0], date: content[1]);
          }).toList(),
        ),
      ),
    );
  }
}

