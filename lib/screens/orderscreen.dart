import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_application/searchscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';
import 'item_detail.dart';
import 'models/menu_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cartscreen.dart';
import 'services/cart_service.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
// import 'dart:io';
// import 'QR_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isTakeaway = true;
  String? selectedTable;
  List<MenuCategory> menuCategories = [];

  Future<void> _saveOrderMode() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('orderModes')
        .doc(user.uid)
        .set({
          'isTakeaway': isTakeaway,
          'selectedTable': selectedTable,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  void initState() {
    super.initState();
    _loadMenuFromJson();

    // Reset trạng thái order khi mở màn hình
    // isTakeaway = true;
    // selectedTable = null;
    // _saveOrderMode();
  }

  Future<void> _loadMenuFromJson() async {
    final String jsonString = await rootBundle.loadString('assets/menu.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      menuCategories =
          jsonData.map((cat) => MenuCategory.fromJson(cat)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ĐẶT MÓN',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('cart')
                    .snapshots(),
            builder: (context, snapshot) {
              int itemCount = 0;
              if (snapshot.hasData) {
                itemCount = snapshot.data!.docs.length;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CartScreen()),
                      );
                    },
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFC58A66),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8), // Khoảng cách cuối cho đẹp
        ],
      ),

      body: Column(
        children: [
          _buildTakeawaySelector(),
          _buildTableSelector(),
          Expanded(
            child:
                menuCategories.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : CustomScrollView(
                      slivers: [
                        ...menuCategories.map((category) {
                          return SliverStickyHeader(
                            header: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Text(
                                category.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final item = category.items[index];
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Image.asset(
                                          item.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Gilroy',
                                          color: Color(0xFFC58A66),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${NumberFormat("#,###", "vi_VN").format(item.price)}đ',
                                        style: TextStyle(
                                          fontFamily: 'Gilroy',
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      trailing: GestureDetector(
                                        onTap: () async {
                                          final user =
                                              FirebaseAuth.instance.currentUser;

                                          if (user != null) {
                                            String userId = user.uid;

                                            // Tham số mặc định
                                            String note =
                                                'Size: S, 100% Đường, 100% Đá';

                                            await addToCart(
                                              item,
                                              userId,
                                              1,
                                              note,
                                            );

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Đã thêm vào giỏ hàng',
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Vui lòng đăng nhập',
                                                ),
                                              ),
                                            );
                                          }
                                        },

                                        child: CircleAvatar(
                                          radius: 14,
                                          backgroundColor:
                                              Colors.white, // Viền ngoài
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Color(
                                              0xFFC58A66,
                                            ), // Nền nút
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder:
                                              (context) =>
                                                  ItemDetailBottomSheet(
                                                    item: item,
                                                  ),
                                        );
                                      },
                                    ),
                                    const Divider(height: 1),
                                  ],
                                );
                              }, childCount: category.items.length),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTakeawaySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          Container(
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E6),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            left: isTakeaway ? 8 : MediaQuery.of(context).size.width / 2 - 16,
            top: 6, // Căn giữa theo chiều dọc
            child: Container(
              width: MediaQuery.of(context).size.width / 2 - 24,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFCB8F72),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10, // Căn giữa text theo chiều dọc
            left: 0,
            right: 0,
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isTakeaway = true;
                        });
                        _saveOrderMode(); // Lưu khi chọn "Mang đi"
                      },

                      child: Center(
                        child: Text(
                          'Mang đi',
                          style: TextStyle(
                            color:
                                isTakeaway
                                    ? Colors.white
                                    : const Color(0xFFCB8F72),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: const Color(0xFFD8C0B3),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isTakeaway = false;
                        });
                        _saveOrderMode(); // Lưu khi chọn "Đặt món"
                      },

                      child: Center(
                        child: Text(
                          'Đặt món',
                          style: TextStyle(
                            color:
                                !isTakeaway
                                    ? Colors.white
                                    : const Color(0xFFCB8F72),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: const Text('Chọn bàn'),
        subtitle: Text(selectedTable ?? 'Bàn chưa xác định'),
        trailing: SizedBox(
          width: 40,
          height: 40,
          child: Image.asset('assets/images/QR SCAN.png', fit: BoxFit.contain),
        ),
        onTap: _showTableSelectionDialog,
      ),
    );
  }

  void _showTableSelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chọn bàn'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (context, index) {
                  final tableName = 'Bàn ${index + 1}';
                  return ListTile(
                    title: Text(tableName),
                    onTap: () {
                      setState(() {
                        selectedTable = tableName;
                      });
                      _saveOrderMode(); // Lưu khi chọn bàn
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
            ],
          ),
    );
  }
}
