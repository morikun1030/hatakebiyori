import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'dashboard_screen.dart';
import 'diary_screen.dart';
import 'guide_screen.dart';
import 'my_garden_screen.dart';
import 'shop_screen.dart';
import 'vegetable_db_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    MyGardenScreen(),
    CalendarScreen(),
    VegetableDbScreen(),
    DiaryScreen(),
    ShopScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 初回起動時にガイドを表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GuideScreen.showIfFirstLaunch(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: '今日',
          ),
          NavigationDestination(
            icon: Icon(Icons.yard_outlined),
            selectedIcon: Icon(Icons.yard),
            label: 'マイ畑',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'カレンダー',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco),
            label: '野菜図鑑',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: '日誌',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'ショップ',
          ),
        ],
      ),
    );
  }
}
