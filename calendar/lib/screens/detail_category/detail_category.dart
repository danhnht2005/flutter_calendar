import 'package:calender/helpers/get_color.dart';
import 'package:calender/models/categories.dart';
import 'package:calender/models/color_category.dart';
import 'package:calender/services/categori_service.dart';
import 'package:calender/services/color_service.dart';
import 'package:calender/widget/drag_handle/drag_handle.dart';
import 'package:flutter/material.dart';
import 'package:elegant_notification/elegant_notification.dart';

class DetailCategoryScreen extends StatefulWidget {
  final String id;

  const DetailCategoryScreen({super.key, required this.id});

  @override
  State<DetailCategoryScreen> createState() => _DetailCategoryScreenState();
}

class _DetailCategoryScreenState extends State<DetailCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Categories categories = Categories();
  String _selectedColor = "B8B8B8";

  List<ColorCategory> colorOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchColors();
    _fetchCategory();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategory() async {
    final dynamic response = await getCategory(widget.id);
    if (response != null) {
      setState(() {
        categories = Categories.fromJson(response);
        _nameController.text = categories.name ?? '';
        _descriptionController.text = categories.description ?? '';
        _selectedColor = categories.color ?? "B8B8B8";
      });
    }
  }

  Future<void> _fetchColors() async {
    final dynamic response = await getListColor();
    if (response != null && response is List) {
      setState(() {
        colorOptions = response.map((e) => ColorCategory.fromJson(e)).toList();
      });
    }
  }

  Future<void> handleDeleteCategory() async {
    dynamic response = await deleteCategory(widget.id);

    if (!mounted) return;

    if (response != null) {
      if (!context.mounted) return;
      ElegantNotification.success(
        title: Text("Xóa danh mục thành công"),
        description: Text("Danh mục của bạn đã được xóa thành công"),
      ).show(context);
    } else {
      if (!context.mounted) return;
      ElegantNotification.error(
        title: Text("Xóa danh mục thất bại"),
        description: Text("Đã xảy ra lỗi khi xóa danh mục"),
      ).show(context);
    }
  }

  Future<void> handleEditCategory() async {
    dynamic response = await editCategory(
      widget.id,
      int.parse(categories.userId ?? '0'),
      _nameController.text,
      _descriptionController.text,
      _selectedColor,
    );

    if (!mounted) return;

    if (response != null) {
      if (!context.mounted) return;
      ElegantNotification.success(
        title: Text("Sửa danh mục thành công"),
        description: Text("Danh mục của bạn đã được sửa thành công"),
      ).show(context);
    } else {
      if (!context.mounted) return;
      ElegantNotification.error(
        title: Text("Sửa danh mục thất bại"),
        description: Text("Đã xảy ra lỗi khi sửa danh mục"),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DragHandle(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz),
                color: Colors.black,
                surfaceTintColor: Colors.transparent,
                onSelected: (String value) {
                  if (value == 'edit-active') {
                    print('Thực hiện chức năng Sửa');
                  } else if (value == 'delete') {
                    handleDeleteCategory();
                    Navigator.pop(context);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit-active',
                    child: Text(
                      'Chặn trên lịch',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text(
                      'Xóa danh mục',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),

              TextButton(
                onPressed: () {
                  handleEditCategory();
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFE5E5E5),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Hoàn tất',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _nameController,
             style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black, 
            ),
            decoration: InputDecoration(
              hintText: 'Tiêu đề',
              hintStyle: const TextStyle(
                fontSize: 20,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 16),

          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Mô tả',
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 16),

          const Text(
            'Màu danh mục',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 16.0,
              runSpacing: 12.0,
              children: colorOptions.map((item) {
                bool isSelected = _selectedColor == item.color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = item.color ?? 'B8B8B8';
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: getColor(item.color),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isSelected
                        ? Center(
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.black,
                            ),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
