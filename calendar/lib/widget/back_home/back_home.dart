import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackHome extends StatelessWidget {
  final VoidCallback? onPressed; 

  const BackHome({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        context.go('/');
      },
    );
  }
}