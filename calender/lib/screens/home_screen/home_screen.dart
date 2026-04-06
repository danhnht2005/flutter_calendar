import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calender/helpers/token.dart';
import 'package:calender/services/categoriService.dart';
import 'package:calender/services/userServices.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  dynamic dataUser;
  List<dynamic> categories = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final dynamic response = await getListCategories();
    if (response != null && response is List) {
      setState(() {
        categories = List<dynamic>.from(response);
      });
    }
  }

  Future<void> _loadUser() async {
    final String? id = await Token.getId();
    if (id == null || id.isEmpty) return;

    final dynamic response = await getUser(id);
    if (response == null || response.isEmpty) return;
    setState(() {
      dataUser = response;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await Token.removeToken();
    await Token.removeId();
    if (!context.mounted) return;
    context.go('/login');
  }

  Color getColor(dynamic colorName) {
    final String value = (colorName ?? '').toString().toLowerCase();
    switch (value) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.greenAccent;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.amber;
      case 'purple':
        return Colors.purpleAccent;
      case 'blue':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = (dataUser?['fullName'] ?? 'Người dùng').toString();
    final String email = (dataUser?['email'] ?? '').toString();
    final String avatarChar =
        fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(fullName),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(child: Text(avatarChar)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text(
                  'Lịch của tôi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: getColor(item['color']),
                            borderRadius: BorderRadius.circular(
                              6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 1),

                        Expanded(
                          child: Text(
                            (item['name'] ?? 'Danh mục').toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.visibility_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Cài đặt'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Đăng xuất'),
                onTap: () async {
                  await _logout(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: SfCalendar(
        view: CalendarView.workWeek,
        timeSlotViewSettings: TimeSlotViewSettings(
          startHour: 0,
          endHour: 24,
          numberOfDaysInView: 3,
          nonWorkingDays: <int>[DateTime.friday, DateTime.saturday],
        ),
      ),
    );
  }
}
