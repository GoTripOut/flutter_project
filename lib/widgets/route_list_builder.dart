import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_flutter_project/global_value_controller.dart';
import 'package:sample_flutter_project/widgets/route_container.dart';

class RouteListBuilder extends StatefulWidget{
  const RouteListBuilder({
    super.key,
    required this.routeContents,
    required this.addNewRoute,
    this.controller,
  });
  final PageController? controller;
  final List<dynamic> routeContents;
  final bool addNewRoute;
  @override
  createState() => _RouteListBuilderState();
}

class _RouteListBuilderState extends State<RouteListBuilder>{
  var valueController = Get.find<GlobalValueController>();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: widget.routeContents.map((content){
          return widget.addNewRoute
              ? RouteContainer(place: content[0], controller: widget.controller,)
              : RouteContainer(placeListID: content[0], place: content[1], startDate: content[4], endDate: content[5], controller: widget.controller,);
        }).toList(),
      ),
    );
  }
}