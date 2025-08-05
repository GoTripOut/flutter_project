import 'package:flutter/material.dart';

class CategorySelectorSheet extends StatefulWidget {
  final Map<String, String> categoryMap;

  const CategorySelectorSheet({super.key, required this.categoryMap});

  @override
  State<CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends State<CategorySelectorSheet> {
  // 선택된 카테고리 목록(순서 유지)
  final List<String> _selected = [];
  static const int _maxSelection = 5;

  final Map<String, IconData> _categoryIcons = const {
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

  void _toggleChip(String name, bool selected) {
    setState(() {
      if (selected) {
        if (_selected.length >= _maxSelection) {
          // 최대 개수 초과 시 안내
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('최대 $_maxSelection개까지 선택할 수 있습니다.')),
            );
          return;
        }
        if (!_selected.contains(name)) _selected.add(name);
      } else {
        _selected.remove(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 닫기 버튼
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 4),
              // 헤더 & 선택 개수
              Text(
                "카테고리 선택 (${_selected.length}/$_maxSelection)",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              // Chip 영역
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.categoryMap.keys.map((name) {
                    final bool isSelected = _selected.contains(name);
                    return ChoiceChip(
                      avatar: Icon(_categoryIcons[name], size: 18),
                      label: Text(name),
                      selected: isSelected,
                      onSelected: (val) => _toggleChip(name, val),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              if (_selected.isNotEmpty) ...[
                const Divider(thickness: 1),
                const SizedBox(height: 8),
                const Text(
                  "우선순위 정렬",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 250,
                  child: ReorderableListView(
                    shrinkWrap: true,
                    children: _selected.asMap().entries.map((entry) {
                      final index = entry.key;
                      final name = entry.value;
                      return ListTile(
                        key: ValueKey(name),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.drag_handle),
                            const SizedBox(width: 4),
                            Icon(_categoryIcons[name]),
                          ],
                        ),
                        title: Text(name),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selected.removeAt(index);
                            });
                          },
                        ),
                      );
                    }).toList(),
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _selected.removeAt(oldIndex);
                        _selected.insert(newIndex, item);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // 확인 버튼
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selected),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    child: const Text("AI 경로 추천 시작"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
