import 'package:calender/helpers/get_color.dart';
import 'package:calender/helpers/token.dart';
import 'package:calender/models/color_category.dart';
import 'package:calender/services/categori_service.dart';
import 'package:calender/services/color_service.dart';
import 'package:calender/widget/drag_handle/drag_handle.dart';
import 'package:flutter/material.dart';
import 'package:elegant_notification/elegant_notification.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedColor = "B8B8B8";

  bool _isFormValid = false;

  List<ColorCategory> colorOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchColors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchColors() async {
    final dynamic response = await getListColor();
    if (response != null && response is List) {
      setState(() {
        colorOptions = response.map((e) => ColorCategory.fromJson(e)).toList();
      });
    }
  }

  Future<void> handleAddCategory() async {
    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();
    final String color = _selectedColor;

    final String? id = await Token.getId();
    if (id == null) return;

    dynamic response = await createCategory(
      int.parse(id),
      name,
      description,
      color,
    );

    if (!mounted) return;

    if (response != null) {
      ElegantNotification.success(
        title: Text("Thêm danh mục thành công"),
        description: Text("Danh mục của bạn đã được tạo thành công"),
      ).show(context);
    } else {
      if (!context.mounted) return;
      ElegantNotification.error(
        title: Text("Thêm danh mục thất bại"),
        description: Text("Đã xảy ra lỗi khi thêm danh mục"),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 8, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DragHandle(),

          Align(
            alignment: Alignment.topRight,
            child: _isFormValid
                ? TextButton(
                    onPressed: () {
                      handleAddCategory();
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
                  )
                : IconButton(
                    onPressed: () => {Navigator.pop(context)},
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFE5E5E5),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 14),

          Form(
            key: _formKey,
            child: TextFormField(
              controller: _nameController,
              onChanged: (value) {
                setState(() {
                  _isFormValid = value.trim().isNotEmpty;
                });
              },
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
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 16),

          TextFormField(
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
