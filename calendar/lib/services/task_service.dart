import 'package:calender/utils/request.dart'; 

Future<dynamic> getListTasks(String id) async {
  final result = await ApiService.get('tasks?userId=$id');
  return result;
}