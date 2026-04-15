import 'package:calender/screens/add_category/add_catetory.dart';
import 'package:calender/widget/logout/logout.dart';
import 'package:calender/widget/my_calendar/my_calendar.dart';
import 'package:calender/widget/profile_header/profile_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  void _showAddCategorySheet(BuildContext context) {
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
          child: const AddCategoryScreen(),
        );
      },
    );
  }

  void _navigate(String route) {
    Navigator.pop(context);
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ProfileHeader(),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Lịch của tôi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),

            MyCalendar(),

            ListTile(
              horizontalTitleGap: 8,
              leading: const Icon(Icons.add, color: Colors.grey, size: 20),
              title: const Text(
                'Thêm danh mục lịch',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              onTap: () {
                Navigator.pop(context);
                _showAddCategorySheet(context);
              },
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Được chia sẻ với tôi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),

            const Divider(),

            // --- Thống kê ---
            ListTile(
              horizontalTitleGap: 8,
              leading: const Icon(
                Icons.bar_chart_outlined,
                color: Color(0xFF5C6BC0),
                size: 22,
              ),
              title: const Text(
                'Thống kê công việc',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () => _navigate('/statistics'),
            ),

            // --- Thông báo ---
            ListTile(
              horizontalTitleGap: 8,
              leading: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFFF04842),
                size: 22,
              ),
              title: const Text(
                'Thông báo',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () => _navigate('/notifications'),
            ),

            // --- Cài đặt thông báo ---
            ListTile(
              horizontalTitleGap: 8,
              leading: const Icon(
                Icons.notifications_active_outlined,
                color: Color(0xFF66BB6A),
                size: 22,
              ),
              title: const Text(
                'Cài đặt thông báo',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () => _navigate('/notification-settings'),
            ),

            // --- Cài đặt chung ---
            ListTile(
              horizontalTitleGap: 8,
              leading: const Icon(
                Icons.settings_outlined,
                color: Colors.grey,
                size: 22,
              ),
              title: const Text(
                'Cài đặt',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () => _navigate('/settings'),
            ),

            const Divider(),

            Logout(),
          ],
        ),
      ),
    );
  }
}
