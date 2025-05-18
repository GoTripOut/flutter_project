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
          Text('$categoryName 주변 장소',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
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
          final status = place['status'];
          final status_description = place['status_description'];
          final visitorReviewScore = place['visitorReviewScore'];
          final visitorReviewCount = place['visitorReviewCount'];

          return ListTile(
            title: Row(
              children: [
                Text(placeName),
                const SizedBox(width: 12.0,),
                if (visitorReviewScore != null)
                  Text(
                    '$visitorReviewScore (${visitorReviewCount != null ? visitorReviewCount : 0})',
                    style: const TextStyle(fontSize: 12.0),
                  ),
                const Spacer(), // 아이콘을 오른쪽 끝으로
                IconButton(
                  iconSize: 15.0,
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.pop(context,
                        {'latitude': latitude, 'longitude': longitude});
                  },
                ),
              ],
            ),
            subtitle: Row(
              children: [
                if (status != null)
                Text(status, style: TextStyle(
                    fontSize: 11,
                    color: status == '오늘 휴무' ? Colors.red : Colors.black,),),
                const SizedBox(width: 8.0),
                if (status_description != null)
                  Text(
                  status_description,
                  style: const TextStyle(fontSize: 12.0),),
              ],
            ));
        })
          : const Center(
        child: Text("검색 결과가 없습니다"),
      ),
    );
  }
}