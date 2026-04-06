import 'package:flutter/material.dart';
import 'package:calender/helpers/token.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> checkMyToken() async {
    try {
      String? myToken = await Token.getToken();
      String? myId = await Token.getId();

      if (myToken != null) {
        print("✓ Token hiện tại là: $myToken");
      } else {
        print("✗ Chưa có token nào được lưu!");
      }

      if (myId != null) {
        print("✓ ID hiện tại là: $myId");
      } else {
        print("✗ Chưa có ID nào được lưu!");
      }
    } catch (e) {
      print("✗ Lỗi khi kiểm tra token: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => checkMyToken(),
          child: const Text('Kiểm tra Token'),
        ),
      ),
    );
  }
}
