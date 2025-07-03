import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sample_flutter_project/screens/main_page.dart';
import 'package:sample_flutter_project/screens/add_new_place_page.dart';
import '../global_value_controller.dart';
import '../widgets/sliding_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  final _valueController = Get.find<GlobalValueController>();
  final PageController _pageController = PageController(initialPage: 1);
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildHomeScreen(BuildContext context) {
    // Calculate the height of the header dynamically
    final double headerHeight = MediaQuery.of(context).padding.top + 60; // Approx height of the header

    return Container(
      color: Colors.white, // Page background
      child: Stack(
        children: [
          // Main content of the home screen, positioned below the header
          Padding(
            padding: EdgeInsets.only(top: headerHeight),
            child: Column(
              children: [
                const SizedBox(height: 10.0), // Margin below the header
                Obx(() => SlidingBanner(
                      bannerItems: _valueController.placeList
                          .map((item) => item[0])
                          .toList(),
                    )),
              ],
            ),
          ),
          // Custom Header that extends into the safe area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: 15,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: const [Colors.blue, Colors.purple],
                      transform: GradientRotation(
                        _animationController.value * 2 * pi,
                      ),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'TripOut',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      MainPage(),
      _buildHomeScreen(context),
      AddNewPlacePage(),
    ];

    return Scaffold(
      // Remove the default safe area handling for the body
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '나의 여행',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '새 여행',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 5,
      ),
    );
  }
}
