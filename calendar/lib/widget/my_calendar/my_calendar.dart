import 'package:calender/helpers/get_color.dart';
import 'package:calender/helpers/token.dart';
import 'package:calender/models/categories.dart';
import 'package:calender/screens/detail_category/detail_category.dart';
import 'package:calender/services/categori_service.dart';
import 'package:flutter/material.dart';

class MyCalendar extends StatefulWidget {
  const MyCalendar({super.key});

  @override
  State<MyCalendar> createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  List<Categories> categories = <Categories>[];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final String? id = await Token.getId();
    if (id == null || id.isEmpty) return;

    final dynamic response = await getListCategories(id);
    if (response != null && response is List) {
      setState(() {
        categories = List<Categories>.from(
          response.map((e) => Categories.fromJson(e)),
        );
      });
    }
  }

  void _showDetailCategorySheet(BuildContext context, String categoryId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DetailCategoryScreen(id: categoryId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...categories.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: getColor(item.color),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => {
                      Navigator.pop(context),
                      _showDetailCategorySheet(context, item.id ?? ''),
                    },
                    child: Text(
                      (item.name ?? 'Danh mục').toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.visibility_outlined,
                  color: Colors.grey.shade600,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
