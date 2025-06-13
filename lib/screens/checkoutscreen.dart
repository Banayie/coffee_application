import 'package:coffee_application/user_info.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'order_sucesssdialog.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;
  bool _isPlacingOrder = false;
  Map<String, dynamic>? _userInfo;
  Map<String, dynamic>? _orderMode;
  List<QueryDocumentSnapshot> _cartItems = [];
  int _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Load user info
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('info')
                .doc('personal')
                .get();

        if (userDoc.exists) {
          _userInfo = userDoc.data();
        } else {
          // Fallback to Firebase Auth data
          _userInfo = {
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'phone': '',
            'address': '',
          };
        }

        // Load order mode
        final orderModeDoc =
            await FirebaseFirestore.instance
                .collection('orderModes')
                .doc(user.uid)
                .get();

        if (orderModeDoc.exists) {
          _orderMode = orderModeDoc.data();
        } else {
          // Default order mode
          _orderMode = {'isTakeaway': true, 'selectedTable': null};
        }

        // Load cart items
        final cartSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('cart')
                .get();

        _cartItems = cartSnapshot.docs;

        // Calculate total price
        _totalPrice = 0;
        for (var item in _cartItems) {
          _totalPrice +=
              (item['price'] as num).toInt() *
              (item['quantity'] as num).toInt();
        }
      }
    } catch (e) {
      _showErrorSnackBar('Không thể tải thông tin: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_userInfo == null || _cartItems.isEmpty || _orderMode == null) {
      _showErrorSnackBar('Thông tin không đầy đủ để đặt hàng');
      return;
    }

    // Check if user info is complete
    if (_userInfo!['name'] == null ||
        _userInfo!['name'].toString().trim().isEmpty ||
        _userInfo!['address'] == null ||
        _userInfo!['address'].toString().trim().isEmpty) {
      _showErrorDialog();
      return;
    }

    // Check table selection for dine-in orders
    if (!(_orderMode!['isTakeaway'] ?? true) &&
        (_orderMode!['selectedTable'] == null ||
            _orderMode!['selectedTable'].toString().trim().isEmpty)) {
      _showErrorSnackBar('Vui lòng chọn bàn cho đơn hàng đặt món');
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create order document
        final orderRef = FirebaseFirestore.instance.collection('orders').doc();

        // Prepare order items
        List<Map<String, dynamic>> orderItems = [];
        for (var item in _cartItems) {
          orderItems.add({
            'name': item['name'],
            'price': item['price'],
            'quantity': item['quantity'],
            'image': item['image'],
            'note': item['note'] ?? '',
          });
        }

        // Save order
        await orderRef.set({
          'userId': user.uid,
          'customerInfo': {
            'name': _userInfo!['name'],
            'phone': _userInfo!['phone'] ?? '',
            'email': _userInfo!['email'] ?? user.email,
            'address': _userInfo!['address'],
          },
          'orderMode': {
            'isTakeaway': _orderMode!['isTakeaway'] ?? true,
            'selectedTable': _orderMode!['selectedTable'],
            'orderType':
                (_orderMode!['isTakeaway'] ?? true) ? 'Mang đi' : 'Đặt món',
          },
          'items': orderItems,
          'totalAmount': _totalPrice,
          'status': 'pending',
          'orderDate': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Clear cart after successful order
        final batch = FirebaseFirestore.instance.batch();
        for (var item in _cartItems) {
          batch.delete(
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('cart')
                .doc(item.id),
          );
        }
        await batch.commit();

        // ✅ Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => OrderSuccessDialog(
                orderId: orderRef.id.substring(0, 8).toUpperCase(),
              ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Không thể đặt hàng: ${e.toString()}');
    } finally {
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thông tin chưa đầy đủ'),
            content: const Text(
              'Vui lòng cập nhật đầy đủ họ tên và địa chỉ giao hàng trong phần thông tin cá nhân trước khi đặt hàng.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to personal info screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonalInfoScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC58A66),
                ),
                child: const Text(
                  'Cập nhật thông tin',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Thông tin thanh toán',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFC58A66)),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderModeSection(),
                    const SizedBox(height: 16),
                    _buildInfoSection(),
                    const SizedBox(height: 16),
                    _buildOrderItemsSection(),
                    const SizedBox(height: 16),
                    _buildOrderSummarySection(),
                    const SizedBox(
                      height: 80,
                    ), // thêm khoảng trống để tránh bị nút che
                  ],
                ),
              ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: _buildPlaceOrderButton(),
      ),
    );
  }

  Widget _buildOrderModeSection() {
    if (_orderMode == null) return const SizedBox.shrink();

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC58A66).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    (_orderMode!['isTakeaway'] ?? true)
                        ? Icons.takeout_dining
                        : Icons.table_restaurant,
                    color: const Color(0xFFC58A66),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Thông tin đặt hàng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Loại đơn hàng',
              (_orderMode!['isTakeaway'] ?? true) ? 'Mang đi' : 'Đặt món',
            ),
            if (!(_orderMode!['isTakeaway'] ?? true)) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Số bàn',
                _orderMode!['selectedTable'] ?? 'Chưa chọn bàn',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC58A66).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xFFC58A66),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  (_orderMode?['isTakeaway'] ?? true)
                      ? 'Thông tin khách hàng'
                      : 'Thông tin giao hàng',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_userInfo != null) ...[
              _buildInfoRow('Họ và tên', _userInfo!['name'] ?? 'Chưa cập nhật'),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Số điện thoại',
                _userInfo!['phone']?.toString().isNotEmpty == true
                    ? _userInfo!['phone']
                    : 'Chưa cập nhật',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                (_orderMode?['isTakeaway'] ?? true)
                    ? 'Địa chỉ'
                    : 'Địa chỉ giao hàng',
                _userInfo!['address'] ?? 'Chưa cập nhật',
              ),
            ] else
              const Text('Không thể tải thông tin người dùng'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemsSection() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC58A66).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xFFC58A66),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Đơn hàng (${_cartItems.length} sản phẩm)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cartItems.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return _buildOrderItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(QueryDocumentSnapshot item) {
    final image = item['image'];
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              image.startsWith('http')
                  ? Image.network(
                    image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  )
                  : Image.asset(
                    image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${NumberFormat("#,###", "vi_VN").format(item['price'])} đ × ${item['quantity']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (item['note'] != null && item['note'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Ghi chú: ${item['note']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Text(
          '${NumberFormat("#,###", "vi_VN").format((item['price'] as num).toInt() * (item['quantity'] as num).toInt())} đ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFC58A66),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tạm tính:',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  '${NumberFormat("#,###", "vi_VN").format(_totalPrice)} đ',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (_orderMode?['isTakeaway'] ?? true)
                      ? 'Phí dịch vụ:'
                      : 'Phí giao hàng:',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  'Miễn phí',
                  style: TextStyle(fontSize: 14, color: Colors.green[600]),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${NumberFormat("#,###", "vi_VN").format(_totalPrice)} đ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC58A66),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isPlacingOrder || _cartItems.isEmpty ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC58A66),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child:
            _isPlacingOrder
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đặt hàng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
