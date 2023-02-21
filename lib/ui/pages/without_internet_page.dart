import 'package:flutter/material.dart';

class WithoutInternetPage extends StatelessWidget {
  const WithoutInternetPage({Key? key}) : super(key: key);

  static const String id = 'WithoutInternetPage';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('No Internet'),
      ),
    );
  }
}
