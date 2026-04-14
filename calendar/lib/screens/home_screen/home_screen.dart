import 'package:calender/helpers/get_color.dart';
import 'package:calender/helpers/token.dart';
import 'package:calender/models/meeting_data_source.dart';
import 'package:calender/models/task.dart';
import 'package:calender/services/task_service.dart';
import 'package:calender/widget/sheet_bottom/sheet_bottom.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calender/widget/drawer/app_draw.dart';

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
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final String? id = await Token.getId();
    if (id == null || id.isEmpty) return;

    final dynamic response = await getListTasks(id);
    if (response != null && response is List) {
      setState(() {
        listTasks = response.map((e) => Task.fromJson(e)).toList();
      });
    }
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    for (var element in listTasks) {
      meetings.add(
        Meeting(
          element.eventName ?? '',
          DateTime.parse(element.from ?? DateTime.now().toString()),
          DateTime.parse(element.to ?? today.toString()),
          getColor(element.background ?? ''),
          element.isAllDay ?? false,
        ),
      );
    }
    return meetings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: SfCalendar(
              dataSource: MeetingDataSource(_getDataSource()),
              view: CalendarView.day,
              headerHeight: 0,
              todayHighlightColor: Color(0xFFF04842),
              viewHeaderStyle: ViewHeaderStyle(
                backgroundColor: const Color(0xFFF8F8F8),
              ),
              timeSlotViewSettings: TimeSlotViewSettings(
                startHour: 0,
                endHour: 24,
                numberOfDaysInView: 3,
                dayFormat: 'EEE dd',
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SheetBottom(),
          ),
        ],
      ),
    );
  }
}
