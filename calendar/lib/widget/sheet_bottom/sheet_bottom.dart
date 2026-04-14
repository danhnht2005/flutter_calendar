import 'package:calender/widget/drag_handle/drag_handle.dart';
import 'package:flutter/material.dart';


class SheetBottom extends StatefulWidget {
  const SheetBottom({super.key});

  @override
  State<SheetBottom> createState() => _SheetBottomState();
}

class _SheetBottomState extends State<SheetBottom> {
  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: const BoxDecoration(
      color: Color(0xFFF8F8F8),
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 1)],
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 8, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DragHandle(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Không có cuộc hẹn nào sắp tới',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.add, color: Colors.white, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF979797),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
        ],
      ),
    ),
  );
  }
}
