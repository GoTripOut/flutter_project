import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_flutter_project/global_value_controller.dart';

class FavoriteSelectionPage extends StatefulWidget {

  const FavoriteSelectionPage({super.key,});

  @override
  State<FavoriteSelectionPage> createState() => _FavoriteSelectionPage1State();
}

class _FavoriteSelectionPage1State extends State<FavoriteSelectionPage> {
  List<String> selected = [];
  var valueController = Get.find<GlobalValueController>();

  final Map<String, IconData> categoryIcons = {
    "음식": Icons.restaurant,
    "풍경": Icons.camera_alt,
    "여행 스타일": Icons.flight,
  };

  final Map<String, IconData> foodCategoryIcons = {
    "한식": Icons.rice_bowl,
    "일식": Icons.ramen_dining,
    "중식": Icons.takeout_dining,
    "양식": Icons.local_pizza,
  };

  final Map<String, IconData> viewCategoryIcons = {
    "산": Icons.terrain,
    "바다": Icons.waves,
    "들": Icons.eco,
    "도심": Icons.location_city,
  };

  final Map<String, IconData> travelStyleCategoryIcons = {
    "계획적": Icons.event_note,
    "즉흥적": Icons.bolt,
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          shadowColor: Colors.grey.withAlpha(128),
          elevation: 2.0,
          title: Text("선호 카테고리 선택"),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ✅ 수정된 부분: Wrap을 Container로 감싸고 width 강제
              SizedBox(
                width: double.infinity,
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant),
                        Text("선호 음식")
                      ],
                    ),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: foodCategoryIcons.keys.map((name) {
                        return ActionChip(
                          avatar: Icon(
                            foodCategoryIcons[name],
                            size: 20,
                            color: valueController.foodSelectedMap[name]! ? Colors.deepPurpleAccent : Colors.grey,
                          ),
                          label: Text(
                            name,
                            style: TextStyle(
                              color: valueController.foodSelectedMap[name]! ? Colors.deepPurpleAccent : Colors.grey,
                            ),
                          ),
                          side: BorderSide(
                            color: valueController.foodSelectedMap[name]! ? Colors.deepPurpleAccent : Colors.grey,
                          ),
                          backgroundColor: Colors.white,
                          onPressed: (){
                            valueController.foodSelectedMap[name] = !valueController.foodSelectedMap[name]!;
                          },
                        );
                      }).toList(),
                    ),
                    )
                  ],
                )
              ),
              SizedBox(
                width: double.infinity,
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(categoryIcons["풍경"]),
                        Text("선호 풍경"),
                      ],
                    ),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: viewCategoryIcons.keys.map((name) {
                        return ActionChip(
                          avatar: Icon(
                            viewCategoryIcons[name],
                            size: 20,
                            color: valueController.viewSelectedMap[name]! ? Colors.deepPurpleAccent : Colors.grey,
                          ),
                          label: Text(
                            name,
                            style: TextStyle(
                              color: valueController.viewSelectedMap[name]! ? Colors.deepPurpleAccent : Colors.grey,
                            ),
                          ),
                          side: BorderSide(
                            color: valueController.viewSelectedMap[name]! ? Colors.deepPurpleAccent : Colors.grey,
                          ),
                          backgroundColor: Colors.white,
                          onPressed: (){
                            valueController.viewSelectedMap[name] = !valueController.viewSelectedMap[name]!;
                          },
                        );
                      }).toList(),
                    ),
                    )
                  ],
                )
              ),
              SizedBox(
                width: double.infinity,
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(categoryIcons["여행 스타일"]),
                        Text("여행 스타일")
                      ],
                    ),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: travelStyleCategoryIcons.keys.map((name) {
                        return ActionChip(
                          avatar: Icon(
                            travelStyleCategoryIcons[name],
                            size: 20,
                            color: valueController.travelStyleSelectedMap[name]! ? Colors.deepPurpleAccent : Colors.grey,
                          ),
                          label: Text(
                            name,
                            style: TextStyle(
                              color: valueController.travelStyleSelectedMap[name]! ? Colors.deepPurpleAccent : Colors.grey,
                            ),
                          ),
                          side: BorderSide(
                            color: valueController.travelStyleSelectedMap[name]! ? Colors.deepPurpleAccent : Colors.grey,
                          ),
                          backgroundColor: Colors.white,
                          onPressed: (){
                            valueController.travelStyleSelectedMap[name] = !valueController.travelStyleSelectedMap[name]!;
                          },
                        );
                      }).toList(),
                    ),
                    )
                  ],
                )
              ),
              const SizedBox(height: 20),
              if (selected.isNotEmpty) ...[
                const Text("우선순위 정렬 (최대 5개까지)"),
                const SizedBox(height: 8),
                SizedBox(
                  height: 300,
                  child: ReorderableListView(
                    shrinkWrap: true,
                    children: selected.asMap().entries.map((entry) {
                      final index = entry.key;
                      final name = entry.value;
                      return ListTile(
                        key: ValueKey('$name-$index'),
                        leading: Icon(categoryIcons[name]),
                        title: Text(name),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              selected.removeAt(index);
                            });
                          },
                        ),
                      );
                    }).toList(),
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = selected.removeAt(oldIndex);
                        selected.insert(newIndex, item);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ],
          ),
        )
    );
  }
}