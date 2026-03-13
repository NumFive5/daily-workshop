import 'package:flutter/material.dart';

class PoemPage extends StatefulWidget {
  const PoemPage({Key? key}) : super(key: key);

  @override
  State<PoemPage> createState() => _PoemPageState();
}

class _PoemPageState extends State<PoemPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 诗歌卡片
                  Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        // 诗文
                        Text(
                          '吴越千年思绪长',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                color: Colors.grey.shade800,
                                height: 2,
                              ),
                        ),
                        Text(
                          '昊日东升耀四方',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                color: Colors.grey.shade800,
                                height: 2,
                              ),
                        ),
                        Text(
                          '爱你如诗入心房',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                color: Colors.grey.shade800,
                                height: 2,
                              ),
                        ),
                        Text(
                          '胡笳声声伴远航',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                color: Colors.grey.shade800,
                                height: 2,
                              ),
                        ),
                        Text(
                          '珍珠闪烁映月光',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                color: Colors.grey.shade800,
                                height: 2,
                              ),
                        ),
                        Text(
                          '珍心永驻在你身旁',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                color: Colors.grey.shade800,
                                height: 2,
                              ),
                        ),

                        const SizedBox(height: 30),

                        // 说明文字
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.pink.shade200,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '藏头诗说明',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink.shade700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '读取诗歌每一行的首字：\n吴、昊、爱、胡、珍、珍\n组成"吴昊爱胡珍珍"',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.pink.shade600,
                                      height: 1.6,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 底部署名
                  Text(
                    '❤️ 永远爱你 ❤️',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.red.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
