import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isLoading = false;
  List<QueryDocumentSnapshot> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final orderSnapshot =
            await FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: user.uid)
                .orderBy('orderDate', descending: true)
                .get();

        setState(() {
          _orders = orderSnapshot.docs;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Không thể tải lịch sử đơn hàng: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'delivering':
        return 'Đang giao hàng';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'delivering':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getOrderTypeDisplayText(Map<String, dynamic> orderMode) {
    final orderType = orderMode['orderType'] as String? ?? '';
    final isTakeaway = orderMode['isTakeaway'] as bool? ?? false;

    if (isTakeaway) {
      return 'Mang đi';
    } else if (orderType == 'Đặt món') {
      return 'Đặt món';
    } else {
      return orderType.isNotEmpty ? orderType : 'Không xác định';
    }
  }

  String _getTableInfo(Map<String, dynamic> orderMode) {
    final selectedTable = orderMode['selectedTable'] as String? ?? '';
    final isTakeaway = orderMode['isTakeaway'] as bool? ?? false;

    if (isTakeaway) {
      return 'Mang đi';
    } else if (selectedTable.isNotEmpty) {
      return selectedTable;
    } else {
      return 'Không xác định';
    }
  }

  void _showOrderDetails(QueryDocumentSnapshot order) {
    final orderData = order.data() as Map<String, dynamic>;
    final items = orderData['items'] as List<dynamic>;
    final customerInfo = orderData['customerInfo'] as Map<String, dynamic>;
    final orderDate = orderData['orderDate'] as Timestamp?;
    final orderMode = orderData['orderMode'] as Map<String, dynamic>? ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        'Chi tiết đơn hàng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order info
                        _buildDetailSection(
                          'Thông tin đơn hàng',
                          Icons.receipt_outlined,
                          [
                            _buildDetailRow(
                              'Mã đơn hàng',
                              order.id.substring(0, 8).toUpperCase(),
                            ),
                            _buildDetailRow(
                              'Ngày đặt',
                              orderDate != null
                                  ? DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(orderDate.toDate())
                                  : 'Không xác định',
                            ),
                            _buildDetailRow(
                              'Loại đơn hàng',
                              _getOrderTypeDisplayText(orderMode),
                            ),
                            _buildDetailRow(
                              'Bàn/Vị trí',
                              _getTableInfo(orderMode),
                            ),
                            _buildDetailRow(
                              'Trạng thái',
                              _getStatusText(orderData['status'] ?? 'pending'),
                            ),
                            _buildDetailRow(
                              'Tổng tiền',
                              '${NumberFormat("#,###", "vi_VN").format(orderData['totalAmount'])} đ',
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Customer info
                        _buildDetailSection(
                          'Thông tin khách hàng',
                          Icons.person_outline,
                          [
                            _buildDetailRow(
                              'Họ tên',
                              customerInfo['name'] ?? '',
                            ),
                            _buildDetailRow(
                              'Số điện thoại',
                              customerInfo['phone'] ?? '',
                            ),
                            if (customerInfo['email'] != null &&
                                customerInfo['email'].toString().isNotEmpty)
                              _buildDetailRow(
                                'Email',
                                customerInfo['email'] ?? '',
                              ),
                            if (customerInfo['address'] != null &&
                                customerInfo['address'].toString().isNotEmpty)
                              _buildDetailRow(
                                'Địa chỉ',
                                customerInfo['address'] ?? '',
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Order items
                        _buildDetailSection(
                          'Sản phẩm đã đặt',
                          Icons.shopping_bag_outlined,
                          [],
                        ),

                        const SizedBox(height: 8),

                        ...items
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildOrderItemDetail(item),
                              ),
                            )
                            .toList(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFC58A66), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (children.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...children,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemDetail(Map<String, dynamic> item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              item['image'] != null
                  ? Image.asset(
                    item['image'],
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
                  : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${NumberFormat("#,###", "vi_VN").format(item['price'] ?? 0)} đ × ${item['quantity'] ?? 0}',
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
          '${NumberFormat("#,###", "vi_VN").format((item['price'] ?? 0) * (item['quantity'] ?? 0))} đ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFC58A66),
          ),
        ),
      ],
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
          'Lịch sử đơn hàng',
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
              : _orders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: _loadOrderHistory,
                color: const Color(0xFFC58A66),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return _buildOrderCard(order);
                  },
                ),
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có đơn hàng nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy đặt đơn hàng đầu tiên của bạn!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(QueryDocumentSnapshot order) {
    final orderData = order.data() as Map<String, dynamic>;
    final items = orderData['items'] as List<dynamic>;
    final orderDate = orderData['orderDate'] as Timestamp?;
    final status = orderData['status'] ?? 'pending';
    final totalAmount = orderData['totalAmount'] ?? 0;
    final orderMode = orderData['orderMode'] as Map<String, dynamic>? ?? {};

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
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Icons.receipt_outlined,
                          color: Color(0xFFC58A66),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đơn hàng #${order.id.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (orderDate != null)
                            Text(
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(orderDate.toDate()),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Order type and table info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          orderMode['isTakeaway'] == true
                              ? Icons.takeout_dining
                              : Icons.restaurant,
                          size: 14,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getOrderTypeDisplayText(orderMode),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (orderMode['isTakeaway'] != true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.table_bar,
                            size: 14,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTableInfo(orderMode),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Items preview
              Text(
                '${items.length} sản phẩm',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const SizedBox(height: 12),

              // Total and action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng: ${NumberFormat("#,###", "vi_VN").format(totalAmount)} đ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC58A66),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Xem chi tiết',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
