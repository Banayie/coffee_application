import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Đảm bảo rằng Firebase đã được khởi tạo hoàn tất
    await Firebase.initializeApp();

    // Kiểm tra trạng thái đăng nhập
    User? user = _auth.currentUser;

    // Nếu người dùng đã đăng nhập, chuyển sang Home
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/mainscreen');
    } else {
      // Nếu chưa đăng nhập, chuyển sang Register
      Navigator.pushReplacementNamed(context, '/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Chờ trong lúc loading
      ),
    );
  }
}
