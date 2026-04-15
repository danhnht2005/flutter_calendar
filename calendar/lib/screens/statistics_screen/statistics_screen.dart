import 'package:calender/helpers/get_color.dart';
import 'package:calender/helpers/token.dart';
import 'package:calender/models/categories.dart';
import 'package:calender/models/task.dart';
import 'package:calender/services/category_db_service.dart';
import 'package:calender/services/task_db_service.dart';
import 'package:calender/widget/back_home/back_home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Task> _tasks = [];
  List<Categories> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final id = await Token.getId();
      if (id == null || id.isEmpty) return;

      final tasks = await TaskDbService.getListTasks(id);
      final cats = await CategoryDbService.getListCategories(id);

      setState(() {
        _tasks = tasks;
        _categories = cats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không thể tải dữ liệu';
        _isLoading = false;
      });
    }
  }

  // --- Bộ lọc ---
  List<Task> get _todayTasks {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (t.from == null) return false;
      final from = DateTime.tryParse(t.from!);
      if (from == null) return false;
      return from.year == now.year &&
          from.month == now.month &&
          from.day == now.day;
    }).toList();
  }

  List<Task> get _upcomingTasks {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (t.from == null) return false;
      final from = DateTime.tryParse(t.from!);
      return from != null && from.isAfter(now);
    }).toList();
  }

  List<Task> get _overdueTasks {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (t.to == null) return false;
      final to = DateTime.tryParse(t.to!);
      return to != null && to.isBefore(now);
    }).toList();
  }

  Map<String, int> get _tasksByCategory {
    final Map<String, int> result = {};
    for (final task in _tasks) {
      final key = task.categoryId?.toString() ?? 'none';
      result[key] = (result[key] ?? 0) + 1;
    }
    return result;
  }

  Categories? _findCategory(String? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void _goToDetail(String filter) {
    context.push('/statistics-detail/$filter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F8),
        leading: const BackHome(),
        title: const Text(
          'Thống kê công việc',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _loadData,
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF04842)),
            )
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  color: const Color(0xFFF04842),
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSummaryCards(),
                      const SizedBox(height: 24),
                      _buildCategorySection(),
                      const SizedBox(height: 24),
                      _buildWeekSection(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _loadData,
            child: const Text('Thử lại',
                style: TextStyle(color: Color(0xFFF04842))),
          ),
        ],
      ),
    );
  }

  // --- Summary cards ---
  Widget _buildSummaryCards() {
    final stats = [
      {
        'label': 'Tất cả',
        'count': _tasks.length,
        'icon': Icons.calendar_today_outlined,
        'color': const Color(0xFF5C6BC0),
        'filter': 'all',
      },
      {
        'label': 'Hôm nay',
        'count': _todayTasks.length,
        'icon': Icons.today_outlined,
        'color': const Color(0xFF42A5F5),
        'filter': 'today',
      },
      {
        'label': 'Sắp tới',
        'count': _upcomingTasks.length,
        'icon': Icons.schedule_outlined,
        'color': const Color(0xFF66BB6A),
        'filter': 'upcoming',
      },
      {
        'label': 'Quá hạn',
        'count': _overdueTasks.length,
        'icon': Icons.warning_amber_outlined,
        'color': const Color(0xFFF04842),
        'filter': 'overdue',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tổng quan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: stats.map((s) => _buildStatCard(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildStatCard(Map<String, dynamic> s) {
    final color = s['color'] as Color;
    return InkWell(
      onTap: () => _goToDetail(s['filter'] as String),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(s['icon'] as IconData, color: color, size: 20),
                ),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s['count']}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  s['label'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Category breakdown ---
  Widget _buildCategorySection() {
    final byCategory = _tasksByCategory;
    if (byCategory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Theo danh mục',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: byCategory.entries.toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final catId = entry.value.key;
              final count = entry.value.value;
              final cat = _findCategory(catId);
              final color = cat?.color != null
                  ? getColor(cat!.color)
                  : Colors.grey;
              final name = cat?.name ?? 'Không có danh mục';
              final ratio = _tasks.isEmpty ? 0.0 : count / _tasks.length;

              return Column(
                children: [
                  if (idx > 0) const Divider(height: 1, indent: 16),
                  InkWell(
                    onTap: () => _goToDetail('category-$catId'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '$count sự kiện',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(ratio * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- Tuần này ---
  Widget _buildWeekSection() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));
    final dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    final dayCounts = days.map((day) {
      return _tasks.where((t) {
        if (t.from == null) return false;
        final from = DateTime.tryParse(t.from!);
        return from != null &&
            from.year == day.year &&
            from.month == day.month &&
            from.day == day.day;
      }).length;
    }).toList();

    final maxCount = dayCounts.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tuần này',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final isToday = days[i].day == now.day &&
                      days[i].month == now.month &&
                      days[i].year == now.year;
                  final ratio = maxCount == 0 ? 0.0 : dayCounts[i] / maxCount;
                  final barHeight = 60.0 * ratio + 4;
                  return Column(
                    children: [
                      if (dayCounts[i] > 0)
                        Text(
                          '${dayCounts[i]}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isToday
                                ? const Color(0xFFF04842)
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        width: 28,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: isToday
                              ? const Color(0xFFF04842)
                              : dayCounts[i] > 0
                                  ? const Color(0xFF5C6BC0).withValues(alpha: 0.5)
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dayLabels[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: isToday
                              ? const Color(0xFFF04842)
                              : Colors.grey.shade500,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
