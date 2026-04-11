import 'package:calender/helpers/token.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Logout extends StatefulWidget {
  const Logout({super.key});

  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  Future<void> _logout() async {
    await Token.removeToken();
    await Token.removeId();
    
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.redAccent),
      title: const Text('Đăng xuất'),
      onTap: () => _logout(),
    );
  }
}
