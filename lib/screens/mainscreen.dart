import 'package:coffee_application/register.dart';

import 'favouritescreen.dart';
import 'package:flutter/material.dart';
import 'bot_nav.dart';
import 'homescreen.dart';
import 'orderscreen.dart';
import 'profilescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'orders_management.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _goToOrder() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeScreen1(goToOrder: _goToOrder),
      OrderScreen(),
      FavoriteScreen(),
      ProfileScreen(
        onLogout: () {
          FirebaseAuth.instance.signOut();
          // Đăng xuất Google trước khi đăng xuất Firebase
          // Chuyển về màn hình đăng nhập
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Register()),
          );
        },
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
