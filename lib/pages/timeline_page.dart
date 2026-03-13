import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TimelinePage extends StatefulWidget {
  const TimelinePage({Key? key}) : super(key: key);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late Future<List<dynamic>> futureEvents;

  @override
  void initState() {
    super.initState();
    futureEvents = fetchEvents();
  }

  Future<List<dynamic>> fetchEvents() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/events'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return _getMockData();
      }
    } catch (e) {
      // 后端未启动，使用模拟数据
      return _getMockData();
    }
  }

  List<dynamic> _getMockData() {
    return [
      {'date': '2024-01-01', 'title': '相识之初', 'description': '我们相识的那一天'},
      {'date': '2024-03-15', 'title': '第一次约会', 'description': '在咖啡馆度过的美好时光'},
      {'date': '2024-06-20', 'title': '旅行开始', 'description': '一起去旅行，看世界'},
      {'date': '2024-12-25', 'title': '圣诞节', 'description': '最特别的节日'},
    ];
  }

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
      child: FutureBuilder<List<dynamic>>(
        future: futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('错误: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('暂无数据'));
          }

          final events = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return TimelineCard(
                date: event['date'] ?? '未知日期',
                title: event['title'] ?? '事件',
                description: event['description'] ?? '',
                isFirst: index == 0,
                isLast: index == events.length - 1,
              );
            },
          );
        },
      ),
    );
  }
}

class TimelineCard extends StatelessWidget {
  final String date;
  final String title;
  final String description;
  final bool isFirst;
  final bool isLast;

  const TimelineCard({
    Key? key,
    required this.date,
    required this.title,
    required this.description,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 时间轴线
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: Colors.pink.shade300,
              ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pink.shade400,
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: Colors.pink.shade300,
              ),
          ],
        ),
        const SizedBox(width: 24),
        // 事件卡片
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.pink.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
