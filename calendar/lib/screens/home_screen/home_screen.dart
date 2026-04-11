import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:calender/widget/drawer/app_draw.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      drawer: const AppDrawer(),
      body: SfCalendar(
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
    );
  }
}
