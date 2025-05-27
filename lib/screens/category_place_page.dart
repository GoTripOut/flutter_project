import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CategoryPlaceListPage extends StatefulWidget {
  final String categoryName;
  final String placesJson;

  const CategoryPlaceListPage({
    super.key,
    required this.categoryName,
    required this.placesJson,
  });

  @override
  State<CategoryPlaceListPage> createState() => _CategoryPlaceListPageState();
}

class _CategoryPlaceListPageState extends State<CategoryPlaceListPage> {
  List<dynamic> placeList = [];

  @override
  void initState() {
    super.initState();

    placeList = jsonDecode(widget.placesJson);
    placeList.sort((a, b) { // AI_score별로 정렬
      final scoreA = a['AI_score'];
      final scoreB = b['AI_score'];
      return scoreB.compareTo(scoreA);
    });
  }

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
    final categoryIcon = _getCategoryIcon(widget.categoryName);

    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: [
              Text('${widget.categoryName} 주변 장소',
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
            final statusDescription = place['status_description'];
            final visitorReviewScore = place['visitorReviewScore'];
            final visitorReviewCount = place['visitorReviewCount'];
            final aiScore = place['AI_score'];

            double rating = 0;
            if (visitorReviewScore != null) {
              rating = double.tryParse(visitorReviewScore) ?? 0.0;
            }

            return ListTile(
                title: Row(
                  children: [
                    Text(placeName),
                    const SizedBox(width: 3.0,),
                    if (visitorReviewScore != null)
                      RatingBarIndicator(
                        rating: rating,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 10.0,
                        direction: Axis.horizontal, // 별들 가로로 배치
                      ),
                    const SizedBox(width: 3.0), // 별점과 점수 사이의 공간 추가
                      if (visitorReviewScore != null)
                      Text(
                        '$visitorReviewScore (${visitorReviewCount != null ? "$visitorReviewCount" : 0})',
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
                      Text("AI Score : $aiScore점,   ", style: TextStyle(
                        fontSize: 11,),
                      ),
                    if (status != null)
                      Text(status, style: TextStyle(
                        fontSize: 11,
                        color: status == '오늘 휴무' || status == '영업 종료'
                        ? Colors.red : Colors.black,),
                      ),
                    if (status == null)
                      Text("영업 정보가 없습니다", style: TextStyle(
                          fontSize: 11)),
                    const SizedBox(width: 8.0),
                    if (statusDescription != null)
                      Text(
                        statusDescription,
                        style: const TextStyle(fontSize: 12.0),
                      ),
                  ],
                ));
          }) : Center(
          child: Text("검색 결과가 없습니다")
      ),
    );
  }
}