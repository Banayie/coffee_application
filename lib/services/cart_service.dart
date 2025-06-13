// lib/services/cart_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_application/models/menu_item.dart';

Future<void> addToCart(
  MenuItem item,
  String userId,
  int quantity,
  String note,
) async {
  final cartItem = {
    'id': item.id,
    'name': item.name,
    'price': item.price,
    'image': item.image,
    'quantity': quantity,
    'note': note, // ✅ Thêm field note
    'addedAt': FieldValue.serverTimestamp(),
  };

  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('cart')
      .doc(item.id)
      .set(cartItem, SetOptions(merge: true));
}
