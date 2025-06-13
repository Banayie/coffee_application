import 'package:coffee_application/orderhistory.dart';
import 'package:coffee_application/user_info.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Chưa đăng nhập")));
    }

    final name = user.displayName ?? 'Không có tên';
    final email = user.email ?? 'Không có email';

    final avatarProvider =
        user.photoURL != null
            ? NetworkImage(user.photoURL!)
            : const AssetImage('assets/images/default_avatar.jpg')
                as ImageProvider;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'HỒ SƠ CÁ NHÂN',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header với thông tin user
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: avatarProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC58A66),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _buildSectionGroup(
              title: 'Tài khoản',
              items: [
                _ProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'Thông tin cá nhân',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PersonalInfoScreen(),
                      ),
                    );
                  },
                ),
                _ProfileMenuItem(
                  icon: Icons.payment_outlined,
                  title: 'Thông tin thanh toán',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildSectionGroup(
              title: 'Đơn hàng',
              items: [
                _ProfileMenuItem(
                  icon: Icons.history_outlined,
                  title: 'Lịch sử đơn hàng',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderHistoryScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildSectionGroup(
              title: 'Hỗ trợ',
              items: [
                _ProfileMenuItem(
                  icon: Icons.description_outlined,
                  title: 'Điều khoản và dịch vụ',
                  onTap: () => _showComingSoon(context),
                ),
                _ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: 'Hỗ trợ khách hàng',
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildSectionGroup(
              title: 'Khác',
              items: [
                _ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  onTap: () => _showLogoutDialog(context),
                  isDestructive: true,
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionGroup({
    required String title,
    required List<_ProfileMenuItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Container(
              decoration: BoxDecoration(
                border:
                    isLast
                        ? null
                        : Border(
                          bottom: BorderSide(
                            color: Colors.grey[100]!,
                            width: 1,
                          ),
                        ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        item.isDestructive
                            ? Colors.red[50]
                            : const Color(0xFFC58A66).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color:
                        item.isDestructive
                            ? Colors.red[600]
                            : const Color(0xFFC58A66),
                    size: 20,
                  ),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color:
                        item.isDestructive ? Colors.red[600] : Colors.black87,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thông báo'),
            content: const Text(
              'Tính năng này sẽ có trong phiên bản tiếp theo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận đăng xuất'),
            content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onLogout();
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });
}
