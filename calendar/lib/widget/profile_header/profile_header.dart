import 'package:calender/helpers/token.dart';
import 'package:calender/models/user.dart';
import 'package:calender/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  User dataUser = User();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final String? id = await Token.getId();
    if (id == null || id.isEmpty) return;

    final dynamic response = await getUser(id);
    if (response == null || response.isEmpty) return;
    setState(() {
      dataUser = User.fromJson(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 0, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blueGrey,
            child: Text(
              dataUser.fullName != null && dataUser.fullName!.isNotEmpty
                  ? dataUser.fullName![0].toUpperCase()
                  : 'U',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dataUser.fullName ?? 'Người dùng',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.left,
                ),
                Text(
                  dataUser.email ?? '',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            color: Colors.grey.shade600,
            iconSize: 16,
            onPressed: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
        ],
      ),
    );
  }
}
