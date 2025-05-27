import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_flutter_project/global_value_controller.dart';
import 'package:sample_flutter_project/widgets/route_container.dart';

class RouteListBuilder extends StatefulWidget{
  const RouteListBuilder({
    super.key,
    required this.routeContent,
    required this.addNewRoute,
    this.controller,
  });
  final PageController? controller;
  final List<dynamic> routeContent;
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
        direction: Axis.vertical,
        children: widget.routeContent.map((content){
          return widget.addNewRoute
              ? RouteContainer(place: content[0], controller: widget.controller,)
              : RouteContainer(place: content[1], startDate: content[4], endDate: content[5], controller: widget.controller,);
        }).toList(),
      ),
    );
  }
}

