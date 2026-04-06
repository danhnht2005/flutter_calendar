import 'package:calender/utils/request.dart'; 

Future<dynamic> login(String email, String password) async {
  final result = await ApiService.get(
    'users?email=${Uri.encodeQueryComponent(email)}&password=${Uri.encodeQueryComponent(password)}',
  );
  return result;
}