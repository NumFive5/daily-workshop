import 'package:flutter/material.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final List<Map<String, String>> _photos = [
    {
      'title': '日出',
      'description': '清晨的阳光洒向大地',
      'icon': '🌅',
    },
    {
      'title': '山峦',
      'description': '壮观的山脉景色',
      'icon': '⛰️',
    },
    {
      'title': '星空',
      'description': '夜空中闪烁的繁星',
      'icon': '🌟',
    },
    {
      'title': '月亮',
      'description': '皎洁的月光照亮夜晚',
      'icon': '🌙',
    },
    {
      'title': '海浪',
      'description': '蔚蓝的大海与浪花',
      'icon': '🌊',
    },
    {
      'title': '森林',
      'description': '郁郁葱葱的森林',
      'icon': '🌲',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.pink.shade50,
            Colors.red.shade50,
          ],
        ),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          return GestureDetector(
            onTap: () {
              _showPhotoDetail(context, photo);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    photo['icon']!,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    photo['title']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      photo['description']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, Map<String, String> photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(photo['icon']!),
            const SizedBox(width: 8),
            Text(photo['title']!),
          ],
        ),
        content: Text(photo['description']!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
