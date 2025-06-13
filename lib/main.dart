import 'package:coffee_application/screens/mainscreen.dart';
import 'package:coffee_application/screens/orders_management.dart';
import 'package:coffee_application/screens/splash.dart';
import 'package:coffee_application/screens/staff_login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Authentication',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Bắt đầu tại SplashScreen
      routes: {
        '/': (context) => SplashScreen(), // Màn hình kiểm tra đăng nhập
        '/register': (context) => Register(), // Màn hình đăng ký / login
        '/mainscreen': (context) => MainScreen(),
        '/ordermanagement': (context) => OrderManagementScreen(),
        '/staff_login': (context) => StaffLoginScreen(),
      },
    );
  }
}
