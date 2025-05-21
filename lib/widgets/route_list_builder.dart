import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_flutter_project/global_value_controller.dart';
import 'package:sample_flutter_project/widgets/route_container.dart';

class RouteListBuilder extends StatefulWidget{
  const RouteListBuilder({
    super.key,
    required this.routeContent,
    required this.addNewRoute,
  });
  final List<List<String>> routeContent;
  final bool addNewRoute;
  @override
  createState() => _RouteListBuilderState();
}

class _RouteListBuilderState extends State<RouteListBuilder>{
  var valueController = Get.find<GlobalValueController>();
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(
        spacing: 10,
        direction: Axis.vertical,
        children: widget.routeContent.map((content){
          return widget.addNewRoute
              ? RouteContainer(place: content[0])
              : RouteContainer(place: content[0], startDate: content[1], endDate: content[2]);
        }).toList(),
      ),
    );
  }
}

