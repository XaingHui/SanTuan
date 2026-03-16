import 'package:flutter/material.dart';
import 'package:santuan/app.dart';
import 'package:santuan/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const SantuanApp());
}
