import 'package:calender/utils/request.dart'; 
import 'package:calender/helpers/generrateTeken.dart';

Future<dynamic> login(String email, String password) async {
  final result = await ApiService.get(
    'users?email=${Uri.encodeQueryComponent(email)}&password=${Uri.encodeQueryComponent(password)}',
  );
  return result;
}

Future<dynamic> getUser(String id) async {
  final result = await ApiService.get('users/$id');
  return result;
}

Future<dynamic> register(String fullName, String email, String password) async {
  final result = await ApiService.post('users', {
    'fullName': fullName,
    'email': email,
    'password': password,
    'token': generateToken(),
  });
  return result;
}