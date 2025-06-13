import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/menu_item.dart';
import 'services/cart_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDetailBottomSheet extends StatefulWidget {
  final MenuItem item;

  const ItemDetailBottomSheet({Key? key, required this.item}) : super(key: key);

  @override
  State<ItemDetailBottomSheet> createState() => _ItemDetailBottomSheetState();
}

class _ItemDetailBottomSheetState extends State<ItemDetailBottomSheet> {
  double sugarLevel = 0;
  double iceLevel = 0;
  int quantity = 1;
  String selectedSize = 'S';

  bool isFavorited = false;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  final TextEditingController noteController = TextEditingController();

  final Map<String, int> sizePrices = {'S': 0, 'M': 5000, 'L': 10000};

  int get totalPrice {
    int basePrice = widget.item.price.toInt();
    int sizePrice = sizePrices[selectedSize] ?? 0;
    return (basePrice + sizePrice) * quantity;
  }

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  Future<void> _checkIfFavorited() async {
    if (userId == null) return;

    final favDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(widget.item.id)
            .get();

    setState(() {
      isFavorited = favDoc.exists;
    });
  }

  Future<void> _toggleFavorite() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để sử dụng tính năng yêu thích'),
        ),
      );
      return;
    }

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(widget.item.id);

    if (isFavorited) {
      await favRef.delete();
    } else {
      await favRef.set({
        'id': widget.item.id,
        'name': widget.item.name,
        'image': widget.item.image,
        'price': widget.item.price,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    setState(() {
      isFavorited = !isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return DraggableScrollableSheet(
      initialChildSize: 0.875,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Close button
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product image
                        Center(
                          child: Container(
                            width: screenWidth,
                            height: screenWidth - 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                widget.item.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name + Favorite icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  fontFamily: 'Playfair_Display',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    isFavorited
                                        ? const Color.fromARGB(255, 198, 88, 80)
                                        : Colors.grey,
                              ),
                              onPressed: _toggleFavorite,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildHorizontalSlider(
                          title: 'Mức độ ngọt',
                          value: sugarLevel,
                          onChanged: (v) => setState(() => sugarLevel = v),
                          label: _getSugarLabel(sugarLevel),
                        ),
                        const SizedBox(height: 20),

                        _buildHorizontalSlider(
                          title: 'Mật độ đá',
                          value: iceLevel,
                          onChanged: (v) => setState(() => iceLevel = v),
                          label: _getIceLabel(iceLevel),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'Size',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children:
                              ['S', 'M', 'L'].map((size) {
                                bool isSelected = selectedSize == size;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap:
                                        () =>
                                            setState(() => selectedSize = size),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        right:
                                            size == 'L'
                                                ? 0
                                                : 12, // Khoảng cách giữa các ô
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? const Color(0xFFF5E6D3)
                                                : Colors
                                                    .white, // Nền nâu nhạt khi select, trắng khi không select
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? const Color(0xFFC58A66)
                                                  : Colors
                                                      .grey[400]!, // Viền nâu khi select, xám khi không select
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          size,
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? const Color(0xFFC58A66)
                                                    : Colors
                                                        .black, // Chữ nâu khi select, đen khi không select
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 24),

                        TextField(
                          controller: noteController,
                          decoration: InputDecoration(
                            hintText: 'Ghi chú cho bọn mình nhé!',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(
                              Icons.edit_note,
                              color: Colors.grey[400],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFC58A66),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${NumberFormat("#,###", "vi_VN").format(totalPrice)}đ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (sizePrices[selectedSize]! > 0)
                          Text(
                            'Size $selectedSize (+${NumberFormat("#,###", "vi_VN").format(sizePrices[selectedSize]!)}đ)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed:
                                quantity > 1
                                    ? () => setState(() => quantity--)
                                    : null,
                            icon: Icon(
                              Icons.remove,
                              color: quantity > 1 ? Colors.black : Colors.grey,
                            ),
                          ),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => quantity++),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (userId != null) {
                          String sugarText = _getSugarLabel(sugarLevel);
                          String iceText = _getIceLabel(iceLevel);
                          String note =
                              'Size: $selectedSize, $sugarText, $iceText';

                          if (noteController.text.trim().isNotEmpty) {
                            note += '\nGhi chú: ${noteController.text.trim()}';
                          }

                          await addToCart(widget.item, userId!, quantity, note);
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã thêm vào giỏ hàng'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng đăng nhập')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC58A66),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Chọn',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHorizontalSlider({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required String label,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFC58A66),
              inactiveTrackColor: Colors.grey[300],
              thumbColor: const Color(0xFFC58A66),
              overlayColor: const Color(0xFFC58A66).withOpacity(0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: 0,
              max: title == 'Mức độ ngọt' ? 6 : 3,
              divisions: title == 'Mức độ ngọt' ? 6 : 3,
            ),
          ),
        ),
      ],
    );
  }

  String _getSugarLabel(double level) {
    switch (level.round()) {
      case 0:
        return '0% đường';
      case 1:
        return '25% đường';
      case 2:
        return '50% đường';
      case 3:
        return '75% đường';
      case 4:
        return '100% đường';
      case 5:
        return '125% đường';
      case 6:
        return '150% đường';
      default:
        return '';
    }
  }

  String _getIceLabel(double level) {
    switch (level.round()) {
      case 0:
        return '0% đá';
      case 1:
        return '25% đá';
      case 2:
        return '50% đá';
      case 3:
        return '100% đá';
      default:
        return '';
    }
  }
}
