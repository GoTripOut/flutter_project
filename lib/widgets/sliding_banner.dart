import 'dart:async';
import 'package:flutter/material.dart';

class SlidingBanner extends StatefulWidget {
  final List<String> bannerItems;
  final List<String>? bannerImages; // Optional list of image URLs
  const SlidingBanner({super.key, required this.bannerItems, this.bannerImages});

  @override
  State<SlidingBanner> createState() => _SlidingBannerState();
}

class _SlidingBannerState extends State<SlidingBanner> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Set a large initial page to allow for "infinite" scrolling
    final int initialPage =
        widget.bannerItems.isNotEmpty ? widget.bannerItems.length * 1000 : 0;
    _pageController = PageController(initialPage: initialPage);
    if (widget.bannerItems.isNotEmpty) {
      _currentPage = initialPage % widget.bannerItems.length;
    }
    _startTimer();
  }

  void _startTimer() {
    // Do not start a timer if there is only one or zero items
    if (widget.bannerItems.length < 2) {
      return;
    }
    // Cancel any existing timer
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _pageController.page!.round() + 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Helper to get an image URL based on the banner item text
  String getBannerImageUrl(String bannerText) {
    // This is a placeholder. In a real app, you might have a map or a service for this.
    final Map<String, String> imageMap = {
      '서울':
          'https://images.unsplash.com/photo-1532274402911-5a369e4c4bb5?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8JUVDJTg0JTlDJUVDJTlFJTg0JUVEJTlFJTg0fGVufDB8fDB8fHww',
      '부산':
          'https://images.unsplash.com/photo-1590424742398-67366572635e?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8JUVCJUIyJTgxJUVDJTg0JTlDJUVDJTlFJTg0JUVEJTlFJTg0fGVufDB8fDB8fHww',
      '제주':
          'https://images.unsplash.com/photo-1532274402911-5a369e4c4bb5?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8JUVDJTg0JTlDJUVDJTlFJTg0JUVEJTlFJTg0fGVufDB8fDB8fHww',
      '원주':
          'https://encrypted-tbn3.gstatic.com/licensed-image?q=tbn:ANd9GcQedwgKBH15OcYfThVyLkSKkK1mtgF4SGZBU6HrN7T4J8VC-zIxRNGApYxv8FgW3aZz9loFPqeFdoBDbMs9djTzbM6aKuzq464Sc5cinQ',
      '부산':
          'https://lh3.googleusercontent.com/gps-cs-s/AC9h4nrR7TmkyelTgu7WBi4fZlCkd6YIHw-T8Brh6N16p2uZQLbZz1lQoo1RERWdDOnoo43ttlrmzYSiRvSHIUJqIgKEYXWZhhX416L3TVvfIUA5rzeGnPUKDav3B7fIWs-BvWLBkTb2=w810-h468-n-k-no'
      // Add more mappings as needed
    };
    return imageMap[bannerText] ??
        'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8JUVDJTg0JTlDJUVDJTlFJTg0JUVEJTlFJTg0fGVufDB8fDB8fHww'; // Default image
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bannerItems.isEmpty) {
      return Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: const Center(child: Text('추천 여행지가 없습니다.')),
      );
    }

    return SizedBox(
      height: 180, // Banner height
      child: Listener(
        onPointerDown: (_) => _timer?.cancel(),
        onPointerUp: (_) => _startTimer(),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _pageController,
              itemBuilder: (context, index) {
                final int actualIndex = index % widget.bannerItems.length;
                final imageUrl = widget.bannerImages != null &&
                        actualIndex < widget.bannerImages!.length
                    ? widget.bannerImages![actualIndex]
                    : getBannerImageUrl(widget.bannerItems[actualIndex]);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.bannerItems[actualIndex],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page % widget.bannerItems.length;
                });
              },
            ),
            // Page indicators
            Positioned(
              bottom: 15.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.bannerItems.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentPage == index ? 24.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
