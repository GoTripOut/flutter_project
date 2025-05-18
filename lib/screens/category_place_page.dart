import 'package:flutter/material.dart';
import 'dart:convert';

class CategoryPlaceListPage extends StatelessWidget {
  final String categoryName;
  final String placesJson;

  const CategoryPlaceListPage({
    super.key,
    required this.categoryName,
    required this.placesJson,
  });

  Icon? _getCategoryIcon(String category) {
    switch (category) {
      case '음식점':
        return const Icon(Icons.restaurant);
      case '카페':
        return const Icon(Icons.local_cafe);
      case '편의점':
        return const Icon(Icons.store);
      case '관광명소':
        return const Icon(Icons.tour);
      case '문화시설':
        return const Icon(Icons.museum);
      case '숙박':
        return const Icon(Icons.hotel);
      case '주차장':
        return const Icon(Icons.local_parking);
      case '주유소,충전소':
        return const Icon(Icons.local_gas_station);
      case '지하철역':
        return const Icon(Icons.subway);
      default:
        return null; // 기본적으로 아이콘 없음
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> placeList = jsonDecode(placesJson);
    final categoryIcon = _getCategoryIcon(categoryName);

    return Scaffold(
      appBar: AppBar(
        title: Row(
        children: [
          Text('$categoryName 주변 장소'),
          const SizedBox(width: 8.0), // 텍스트와 아이콘 사이 간격
          if (categoryIcon != null) categoryIcon,
        ],
      )),
      body: placeList.isNotEmpty
          ? ListView.builder(
        itemCount: placeList.length,
        itemBuilder: (context, index) {
          final place = placeList[index];
          final String placeName = place['store_name'];
          final double latitude = place['y'];
          final double longitude = place['x'];

          return ListTile(
            title: Text(placeName),
            subtitle: Text(
                '위도: ${latitude}, 경도: ${longitude}'),
            onTap: () {
              Navigator.pop(context, {'latitude': latitude, 'longitude': longitude});
            },
          );
        }
      ) : Center(
        child: Text("검색 결과가 없습니다")
      ),
    );
  }
}