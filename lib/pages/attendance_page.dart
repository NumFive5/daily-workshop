import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late Future<Map<String, dynamic>> futureData;
  String _selectedMonth = '2025-12';
  String _selectedEmployee = '全部';
  String _selectedDepartment = '全部';
  List<String> _availableMonths = [];
  List<String> _availableEmployees = [];
  List<String> _availableDepartments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    futureData = _fetchAllData();
  }

  Future<Map<String, dynamic>> _fetchAllData() async {
    try {
      // 获取所有月份
      final monthsResponse = await http.get(
        Uri.parse('http://42.193.243.34:8081/api/attendance-summary/months'),
      ).timeout(const Duration(seconds: 10));

      if (monthsResponse.statusCode == 200) {
        final monthsData = jsonDecode(monthsResponse.body);
        final months = List<String>.from(monthsData['months'] ?? []);
        
        if (months.isNotEmpty) {
          _selectedMonth = months.last; // 选择最新月份
        }

        // 获取所有汇总数据
        final allResponse = await http.get(
          Uri.parse('http://42.193.243.34:8081/api/attendance-summary/all'),
        ).timeout(const Duration(seconds: 10));

        if (allResponse.statusCode == 200) {
          final allData = jsonDecode(allResponse.body);
          final records = allData['records'] ?? [];
          
          // 提取唯一的员工名称和部门
          final employees = <String>{'全部'};
          final departments = <String>{'全部'};
          
          for (var record in records) {
            employees.add(record['employeeName'] ?? '未知');
            departments.add(record['department'] ?? '未知');
          }

          setState(() {
            _availableMonths = months;
            _availableEmployees = employees.toList();
            _availableDepartments = departments.toList();
          });

          return {'success': true, 'records': records, 'months': months};
        }
      }
      
      return {'success': false, 'error': '获取数据失败'};
    } catch (e) {
      print('错误: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> _uploadFile() async {
    try {
      // 使用 file_picker 选择文件
      // 在 Web 上，使用 <input type="file"> 的替代方案
      final html.InputElement uploadInput = html.FileUploadInputElement()
        ..accept = '.xlsx,.xls'
        ..multiple = false;
      
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files!.isEmpty) return;

        final file = files[0];
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) async {
          try {
            // 获取文件的 Uint8List 数据
            final Uint8List fileBytes = Uint8List.fromList(
              reader.result as List<int>,
            );

            // 上传到后端
            final request = http.MultipartRequest(
              'POST',
              Uri.parse('http://42.193.243.34:8081/api/process/organize-attendance'),
            );

            request.files.add(
              http.MultipartFile.fromBytes(
                'file',
                fileBytes,
                filename: file.name,
              ),
            );

            setState(() {
              _isLoading = true;
            });

            final response = await request.send().timeout(const Duration(seconds: 60));
            final responseBody = await response.stream.bytesToString();

            if (response.statusCode == 200) {
              // 下载文件
              final Uint8List downloadData = response.bodyBytes.isNotEmpty
                  ? Uint8List.fromList(response.bodyBytes)
                  : Uint8List.fromList(responseBody.codeUnits);

              final downloadLink = html.AnchorElement()
                ..href = html.Url.createObjectUrlFromBlob(
                  html.Blob([downloadData], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
                )
                ..download = '考勤整理表_${DateTime.now().toString().split(' ')[0]}.xlsx'
                ..click();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ 文件处理成功！已自动下载'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              final errorBody = jsonDecode(responseBody);
              throw Exception(errorBody['message'] ?? '处理失败');
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ 处理失败: $e'),
                backgroundColor: Colors.red,
              ),
            );
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        });

        reader.readAsArrayBuffer(file);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ 错误: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      futureData = _fetchAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.cyan.shade50,
          ],
        ),
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('加载考勤数据中...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('错误: ${snapshot.error}'),
                ],
              ),
            );
          } else if (!snapshot.hasData || !snapshot.data!['success']) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(snapshot.data?['error'] ?? '暂无数据'),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final records = List<Map<String, dynamic>>.from(data['records'] ?? []);
          final months = List<String>.from(data['months'] ?? []);

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                // Tab 标签栏
                TabBar(
                  tabs: const [
                    Tab(text: '📊 数据概览', icon: Icon(Icons.dashboard)),
                    Tab(text: '📋 详细汇总', icon: Icon(Icons.table_chart)),
                    Tab(text: '⚙️ 管理工具', icon: Icon(Icons.settings)),
                  ],
                  labelColor: Colors.blue.shade600,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue.shade600,
                  isScrollable: true,
                ),
                // Tab 内容
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildOverviewTab(records, months),
                      _buildDetailTab(records, months),
                      _buildManagementTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Tab 1: 数据概览
  Widget _buildOverviewTab(List<Map<String, dynamic>> records, List<String> months) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统计卡片
          _buildStatisticsCards(records, months),
          const SizedBox(height: 20),

          // 月份选择
          _buildMonthSelector(months),
          const SizedBox(height: 20),

          // 本月数据
          _buildMonthDataCard(records),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(List<Map<String, dynamic>> records, List<String> months) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📊 统计概览',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard('总员工数', records.length.toString(), Colors.blue),
            _buildStatCard('覆盖月份', months.length.toString(), Colors.green),
            _buildStatCard(
              '平均出勤率',
              records.isNotEmpty
                  ? '${(records.fold<double>(0, (sum, r) => sum + ((r['attendanceRate'] as num?) ?? 0).toDouble()) / records.length).toStringAsFixed(1)}%'
                  : '0%',
              Colors.orange,
            ),
            _buildStatCard(
              '数据总条数',
              records.length.toString(),
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(List<String> months) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🗓️ 选择月份',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: months.map((month) {
                  final isSelected = _selectedMonth == month;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(month),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedMonth = month;
                        });
                      },
                      selectedColor: Colors.blue.shade100,
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthDataCard(List<Map<String, dynamic>> records) {
    final monthRecords = records.where((r) => r['month'] == _selectedMonth).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📅 $_selectedMonth 月数据',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (monthRecords.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('该月暂无数据'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: monthRecords.length,
                itemBuilder: (context, index) {
                  final record = monthRecords[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record['employeeName'] ?? '未知',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                record['department'] ?? '未知',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '出勤率: ${record['attendanceRate']?.toStringAsFixed(1) ?? '0'}%',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '实出勤: ${record['actualDays'] ?? 0}/${record['totalDays'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Tab 2: 详细汇总
  Widget _buildDetailTab(List<Map<String, dynamic>> records, List<String> months) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 筛选器
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔍 筛选条件',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedMonth,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: '月份',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    items: months
                        .map((month) => DropdownMenuItem(
                              value: month,
                              child: Text(month),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value ?? _selectedMonth;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedEmployee,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: '员工',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    items: _availableEmployees
                        .map((emp) => DropdownMenuItem(
                              value: emp,
                              child: Text(emp),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEmployee = value ?? _selectedEmployee;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: '部门',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.business),
                    ),
                    items: _availableDepartments
                        .map((dept) => DropdownMenuItem(
                              value: dept,
                              child: Text(dept),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value ?? _selectedDepartment;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 数据表格
          _buildDataTable(records),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> records) {
    final filtered = records.where((r) {
      if (_selectedMonth != '全部' && r['month'] != _selectedMonth) return false;
      if (_selectedEmployee != '全部' && r['employeeName'] != _selectedEmployee) return false;
      if (_selectedDepartment != '全部' && r['department'] != _selectedDepartment) return false;
      return true;
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '数据总数: ${filtered.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('员工名称')),
                  DataColumn(label: Text('部门')),
                  DataColumn(label: Text('月份')),
                  DataColumn(label: Text('应出勤')),
                  DataColumn(label: Text('实出勤')),
                  DataColumn(label: Text('出勤率')),
                  DataColumn(label: Text('年假')),
                ],
                rows: filtered.map((record) {
                  return DataRow(
                    cells: [
                      DataCell(Text(record['employeeName'] ?? '-')),
                      DataCell(Text(record['department'] ?? '-')),
                      DataCell(Text(record['month'] ?? '-')),
                      DataCell(Text((record['totalDays'] ?? 0).toString())),
                      DataCell(Text((record['actualDays'] ?? 0).toString())),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ((record['attendanceRate'] as num?) ?? 0) >= 95
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${(record['attendanceRate'] as num?)?.toStringAsFixed(1) ?? '0'}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ((record['attendanceRate'] as num?) ?? 0) >= 95
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text((record['annualLeave'] ?? 0).toString())),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tab 3: 管理工具
  Widget _buildManagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 上传文件
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_upload, size: 32, color: Colors.blue),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📤 上传考勤数据',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '支持 Excel 文件 (.xlsx)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 120,
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(8),
                      dashPattern: const [8, 4],
                      color: Colors.blue.shade300,
                      strokeWidth: 2,
                      child: InkWell(
                        onTap: _uploadFile,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.file_upload_outlined,
                              size: 48,
                              color: Colors.blue.shade300,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '点击上传或拖拽文件',
                              style: TextStyle(
                                color: Colors.blue.shade300,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _uploadFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('选择文件上传'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 刷新数据
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.refresh, size: 32, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        '🔄 刷新数据',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '重新从服务器加载最新的考勤数据',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _refreshData,
                      icon: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(_isLoading ? '加载中...' : '刷新数据'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // API 信息
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, size: 32, color: Colors.purple),
                      const SizedBox(width: 12),
                      Text(
                        'ℹ️ 系统信息',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('API 地址', 'http://42.193.243.34:8081'),
                  const SizedBox(height: 8),
                  _buildInfoRow('状态', '✅ 正常'),
                  const SizedBox(height: 8),
                  _buildInfoRow('数据库', 'MySQL 8.0'),
                  const SizedBox(height: 8),
                  _buildInfoRow('框架', 'Spring Boot 3.2.0'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// 虚线边框 Widget
class DottedBorder extends StatelessWidget {
  final Widget child;
  final BorderType borderType;
  final Radius radius;
  final List<double> dashPattern;
  final Color color;
  final double strokeWidth;

  const DottedBorder({
    Key? key,
    required this.child,
    required this.borderType,
    required this.radius,
    required this.dashPattern,
    required this.color,
    required this.strokeWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: color,
          width: strokeWidth,
          style: BorderStyle.solid,
        ),
      ),
      child: child,
    );
  }
}
