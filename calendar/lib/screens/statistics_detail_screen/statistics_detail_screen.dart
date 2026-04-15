import 'package:calender/helpers/get_color.dart';
import 'package:calender/helpers/token.dart';
import 'package:calender/models/categories.dart';
import 'package:calender/models/task.dart';
import 'package:calender/services/category_db_service.dart';
import 'package:calender/services/task_db_service.dart';
import 'package:flutter/material.dart';

class StatisticsDetailScreen extends StatefulWidget {
  /// Các giá trị filter hợp lệ: 'all' | 'today' | 'upcoming' | 'overdue' | 'category-{id}'
  final String filter;

  const StatisticsDetailScreen({super.key, required this.filter});

  @override
  State<StatisticsDetailScreen> createState() => _StatisticsDetailScreenState();
}

class _StatisticsDetailScreenState extends State<StatisticsDetailScreen> {
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

      final allTasks = await TaskDbService.getListTasks(id);
      final allCats = await CategoryDbService.getListCategories(id);

      setState(() {
        _categories = allCats;
        _tasks = _applyFilter(allTasks);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không thể tải dữ liệu';
        _isLoading = false;
      });
    }
  }

  List<Task> _applyFilter(List<Task> all) {
    final now = DateTime.now();
    final filter = widget.filter;

    if (filter == 'today') {
      return all.where((t) {
        if (t.from == null) return false;
        final from = DateTime.tryParse(t.from!);
        if (from == null) return false;
        return from.year == now.year &&
            from.month == now.month &&
            from.day == now.day;
      }).toList();
    }

    if (filter == 'upcoming') {
      return all.where((t) {
        if (t.from == null) return false;
        final from = DateTime.tryParse(t.from!);
        return from != null && from.isAfter(now);
      }).toList();
    }

    if (filter == 'overdue') {
      return all.where((t) {
        if (t.to == null) return false;
        final to = DateTime.tryParse(t.to!);
        return to != null && to.isBefore(now);
      }).toList();
    }

    if (filter.startsWith('category-')) {
      final catId = filter.replaceFirst('category-', '');
      return all.where((t) => t.categoryId?.toString() == catId).toList();
    }

    return all; // 'all'
  }

  String get _title {
    switch (widget.filter) {
      case 'today':
        return 'Hôm nay';
      case 'upcoming':
        return 'Sắp tới';
      case 'overdue':
        return 'Quá hạn';
      case 'all':
        return 'Tất cả sự kiện';
      default:
        if (widget.filter.startsWith('category-')) {
          final catId = widget.filter.replaceFirst('category-', '');
          try {
            final cat = _categories.firstWhere((c) => c.id == catId);
            return cat.name ?? 'Danh mục';
          } catch (_) {
            return 'Danh mục';
          }
        }
        return 'Chi tiết';
    }
  }

  Categories? _findCategory(String? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  String _formatDateTime(String? iso) {
    if (iso == null) return '--';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final d = dt.day.toString().padLeft(2, '0');
      final mo = dt.month.toString().padLeft(2, '0');
      final h = dt.hour.toString().padLeft(2, '0');
      final mi = dt.minute.toString().padLeft(2, '0');
      return '$d/$mo/${dt.year} $h:$mi';
    } catch (_) {
      return '--';
    }
  }

  bool _isOverdue(Task t) {
    if (t.to == null) return false;
    final to = DateTime.tryParse(t.to!);
    return to != null && to.isBefore(DateTime.now());
  }

  bool _isToday(Task t) {
    if (t.from == null) return false;
    final from = DateTime.tryParse(t.from!);
    if (from == null) return false;
    final now = DateTime.now();
    return from.year == now.year &&
        from.month == now.month &&
        from.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!_isLoading)
              Text(
                '${_tasks.length} sự kiện',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF04842)),
            )
          : _error != null
              ? _buildError()
              : _tasks.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: const Color(0xFFF04842),
                      onRefresh: _loadData,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tasks.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _buildTaskCard(_tasks[index]),
                      ),
                    ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_outlined,
              size: 64, color: Colors.grey.shade300),
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Không có sự kiện nào',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            'Không tìm thấy sự kiện phù hợp với bộ lọc này',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final cat = _findCategory(task.categoryId?.toString());
    final catColor =
        cat?.color != null ? getColor(cat!.color) : Colors.grey;
    final catName = cat?.name ?? 'Không có danh mục';
    final overdue = _isOverdue(task);
    final today = _isToday(task);

    return Container(
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
      child: Row(
        children: [
          // Thanh màu bên trái
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: catColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sự kiện + badge trạng thái
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.eventName ?? 'Không có tên',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (overdue)
                        _buildBadge('Quá hạn', const Color(0xFFF04842))
                      else if (today)
                        _buildBadge('Hôm nay', const Color(0xFF42A5F5)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Thời gian
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_formatDateTime(task.from)} → ${_formatDateTime(task.to)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Danh mục
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: catColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        catName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (task.isAllDay == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Cả ngày',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
