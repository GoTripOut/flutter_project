import 'package:flutter/material.dart';

class CategorySelectorSheet extends StatefulWidget {
  final Map<String, String> categoryMap;

  const CategorySelectorSheet({super.key, required this.categoryMap});

  @override
  State<CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends State<CategorySelectorSheet> {
  List<String> selected = [];

  final Map<String, IconData> categoryIcons = {
    "음식점": Icons.restaurant,
    "카페": Icons.local_cafe,
    "편의점": Icons.local_convenience_store,
    "관광명소": Icons.camera_alt,
    "문화시설": Icons.museum,
    "숙박": Icons.hotel,
    "주차장": Icons.local_parking,
    "주유소,충전소": Icons.local_gas_station,
    "지하철역": Icons.train,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Stack(
        children: [
          // 실제 내용
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              const Text(
                "카테고리를 선택하고 우선순위를 정렬하세요",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // ✅ 수정된 부분: Wrap을 Container로 감싸고 width 강제
              Container(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.center, // Wrap 중앙 정렬(중요!)
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.categoryMap.keys.map((name) {
                    return ActionChip(
                      avatar: Icon(categoryIcons[name], size: 20),
                      label: Text(name),
                      onPressed: selected.length < 5
                          ? () {
                        setState(() {
                          selected.add(name);
                        });
                      }
                          : null,
                    );
                  }).toList(),
                ),
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

          // 추천 시작 버튼 고정
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selected);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("AI 경로 추천 시작"),
            ),
          ),

          // X 버튼
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}