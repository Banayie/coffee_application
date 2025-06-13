import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
  }) : super(key: key);

  final List<_NavItem> items = const [
    _NavItem(
      'assets/images/home_normal.png',
      'assets/images/home_selected.png',
      'Trang chủ',
    ),
    _NavItem(
      'assets/images/order_normal.png',
      'assets/images/order_selected.png',
      'Đặt món',
    ),
    _NavItem(
      'assets/images/heart_normal.png',
      'assets/images/heart_selected.png',
      'Yêu thích',
    ),
    _NavItem(
      'assets/images/user_normal.png',
      'assets/images/user_selected.png',
      'Tài khoản',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 26),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = currentIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isSelected ? 30 : 0,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.brown : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Image.asset(
                      isSelected ? item.selectedAsset : item.normalAsset,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.brown : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final String normalAsset;
  final String selectedAsset;
  final String label;

  const _NavItem(this.normalAsset, this.selectedAsset, this.label);
}
