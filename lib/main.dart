import 'package:flutter/material.dart';
import 'package:git7assignment/pages/fibo_home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(home: const FiboHome());
}
