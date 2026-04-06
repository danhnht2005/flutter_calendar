import 'package:calender/utils/request.dart'; 

Future<dynamic> getListCategories() async {
  final result = await ApiService.get('categories');
  return result;
}
