import 'package:flutter/material.dart';

void showMySnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          right: 20,
          left: 20),
      duration: const Duration(
        seconds: 5,
      ),
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            15,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(0.0),
          child: Center(
            child: Text(
              'Нет интернет сединения',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
      )));
}
