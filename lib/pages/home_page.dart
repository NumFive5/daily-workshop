import 'package:flutter/material.dart';
import 'poem_page.dart';
import 'timeline_page.dart';
import 'gallery_page.dart';
import 'attendance_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const PoemPage(),
    const TimelinePage(),
    const GalleryPage(),
    const AttendancePage(),
  ];

  final List<String> _titles = ['诗歌', '时间轴', '相册', '工作坊'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '💕 ${_titles[_selectedIndex]} 💕',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink.shade400,
        elevation: 0,
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '诗歌',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: '时间轴',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: '相册',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: '工作坊',
          ),
        ],
        selectedItemColor: Colors.pink.shade600,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
