import 'package:calender/helpers/get_color.dart';
import 'package:calender/helpers/token.dart';
import 'package:calender/models/categories.dart';
import 'package:calender/services/category_db_service.dart';
import 'package:calender/services/task_db_service.dart';
import 'package:calender/widget/drag_handle/drag_handle.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';

class AddTaskScreen extends StatefulWidget {
  final VoidCallback? onTaskAdded;
  const AddTaskScreen({super.key, this.onTaskAdded});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _nameController = TextEditingController();
  bool _isAllDay = false;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now().add(const Duration(hours: 1));
  Categories? _selectedCategory;
  List<Categories> _categories = [];
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final id = await Token.getId();
    if (id == null) return;
    final cats = await CategoryDbService.getListCategories(id);
    setState(() {
      _categories = cats;
      if (cats.isNotEmpty) _selectedCategory = cats.first;
    });
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _fromDate : _toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFF04842)),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;

    if (isFrom) {
      setState(() {
        _fromDate = DateTime(
          picked.year, picked.month, picked.day,
          _fromDate.hour, _fromDate.minute,
        );
        if (_toDate.isBefore(_fromDate)) {
          _toDate = _fromDate.add(const Duration(hours: 1));
        }
      });
    } else {
      setState(() {
        _toDate = DateTime(
          picked.year, picked.month, picked.day,
          _toDate.hour, _toDate.minute,
        );
      });
    }
  }

  Future<void> _pickTime({required bool isFrom}) async {
    final initial = TimeOfDay.fromDateTime(isFrom ? _fromDate : _toDate);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFF04842)),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = DateTime(
          _fromDate.year, _fromDate.month, _fromDate.day,
          picked.hour, picked.minute,
        );
      } else {
        _toDate = DateTime(
          _toDate.year, _toDate.month, _toDate.day,
          picked.hour, picked.minute,
        );
      }
    });
  }

  Future<void> _handleSave() async {
    final userId = await Token.getId();
    if (userId == null) return;

    final color = _selectedCategory?.color ?? 'B8B8B8';
    final catId = _selectedCategory?.id != null
        ? int.tryParse(_selectedCategory!.id!)
        : null;

    try {
      await TaskDbService.createTask(
        userId: userId,
        categoryId: catId,
        eventName: _nameController.text.trim(),
        from: _fromDate.toIso8601String(),
        to: _toDate.toIso8601String(),
        background: color,
        isAllDay: _isAllDay,
      );
      if (!mounted) return;
      widget.onTaskAdded?.call();
      Navigator.pop(context);
      ElegantNotification.success(
        title: const Text('Thêm thành công'),
        description: const Text('Sự kiện đã được thêm vào lịch'),
      ).show(context);
    } catch (_) {
      if (!mounted) return;
      ElegantNotification.error(
        title: const Text('Lỗi'),
        description: const Text('Không thể thêm sự kiện'),
      ).show(context);
    }
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DragHandle(),

            // ─── Header ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE5E5E5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.all(4),
                  ),
                ),
                if (_isFormValid)
                  TextButton(
                    onPressed: _handleSave,
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF04842),
                      foregroundColor: Colors.white,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Lưu',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // ─── Tên sự kiện ───────────────────────────────────────────
            TextField(
              controller: _nameController,
              onChanged: (v) => setState(() => _isFormValid = v.trim().isNotEmpty),
              autofocus: true,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Tiêu đề sự kiện',
                hintStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              ),
            ),

            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 16),

            // ─── Cả ngày ───────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.wb_sunny_outlined,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 10),
                const Text('Cả ngày', style: TextStyle(fontSize: 15)),
                const Spacer(),
                Switch(
                  value: _isAllDay,
                  onChanged: (v) => setState(() => _isAllDay = v),
                  activeThumbColor: const Color(0xFFF04842),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ─── Từ ────────────────────────────────────────────────────
            _buildDateTimeRow(
              label: 'Từ',
              date: _fromDate,
              isFrom: true,
            ),
            const SizedBox(height: 6),

            // ─── Đến ───────────────────────────────────────────────────
            _buildDateTimeRow(
              label: 'Đến',
              date: _toDate,
              isFrom: false,
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 16),

            // ─── Chọn danh mục ─────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.folder_outlined,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 10),
                const Text('Danh mục', style: TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            if (_categories.isEmpty)
              Text(
                'Chưa có danh mục nào. Hãy tạo danh mục trước.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory?.id == cat.id;
                  final color = getColor(cat.color);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat.name ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected ? color : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeRow({
    required String label,
    required DateTime date,
    required bool isFrom,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 4),
        // Date chip
        GestureDetector(
          onTap: () => _pickDate(isFrom: isFrom),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatDate(date),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Time chip (ẩn nếu cả ngày)
        if (!_isAllDay)
          GestureDetector(
            onTap: () => _pickTime(isFrom: isFrom),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF04842).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatTime(date),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFF04842),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
