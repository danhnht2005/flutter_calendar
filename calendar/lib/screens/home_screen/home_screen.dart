import 'package:calender/helpers/get_color.dart';
import 'package:calender/helpers/token.dart';
import 'package:calender/models/meeting_data_source.dart';
import 'package:calender/models/task.dart';
import 'package:calender/screens/add_task/add_task_screen.dart';
import 'package:calender/services/notification_db_service.dart';
import 'package:calender/services/seed_service.dart';
import 'package:calender/services/task_db_service.dart';
import 'package:calender/widget/drawer/app_draw.dart';
import 'package:calender/widget/sheet_bottom/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> listTasks = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final String? id = await Token.getId();
    if (id == null || id.isEmpty) return;

    // Thêm mock data nếu chưa có
    await SeedService.seedIfEmpty(id);
    await _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final String? id = await Token.getId();
    if (id == null || id.isEmpty) return;

    final tasks = await TaskDbService.getListTasks(id);
    setState(() => listTasks = tasks);
    await NotificationDbService.syncFromTasks(tasks);
  }

  void _openAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddTaskScreen(onTaskAdded: _fetchTasks),
    );
  }

  List<Meeting> _getDataSource() {
    return listTasks.map((task) {
      return Meeting(
        task.eventName ?? '',
        DateTime.tryParse(task.from ?? '') ?? DateTime.now(),
        DateTime.tryParse(task.to ?? '') ?? DateTime.now(),
        getColor(task.background ?? ''),
        task.isAllDay ?? false,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTask,
        backgroundColor: const Color(0xFF333333),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          Expanded(
            child: SfCalendar(
              dataSource: MeetingDataSource(_getDataSource()),
              view: CalendarView.day,
              headerHeight: 0,
              todayHighlightColor: const Color(0xFFF04842),
              viewHeaderStyle: const ViewHeaderStyle(
                backgroundColor: Color(0xFFF8F8F8),
              ),
              timeSlotViewSettings: const TimeSlotViewSettings(
                startHour: 0,
                endHour: 24,
                numberOfDaysInView: 3,
                dayFormat: 'EEE dd',
              ),
            ),
          ),
          const SheetBottom(),
        ],
      ),
    );
  }
}
