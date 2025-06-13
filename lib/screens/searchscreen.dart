import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'item_detail.dart';
import 'models/menu_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<MenuItem> _allItems = [];
  List<MenuItem> _filteredItems = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    final String jsonString = await rootBundle.loadString('assets/menu.json');
    final List<dynamic> data = json.decode(jsonString);

    List<MenuItem> allItems = [];
    for (var category in data) {
      for (var item in category['items']) {
        allItems.add(MenuItem.fromJson(item));
      }
    }

    setState(() {
      _allItems = allItems;
      _filteredItems = allItems;
    });
  }

  void _filterItems(String query) {
    final results =
        _allItems
            .where(
              (item) => item.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    setState(() {
      _filteredItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng cho toàn bộ màn hình
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Nhập tên món bạn cần tìm...',
            border: InputBorder.none,
          ),
          onChanged: _filterItems,
          autofocus: true,
        ),
        backgroundColor: Colors.white, // Nền trắng cho AppBar
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        systemOverlayStyle:
            SystemUiOverlayStyle.dark, // Status bar tối trên nền trắng
      ),
      body:
          _filteredItems.isEmpty
              ? const Center(
                child: Text(
                  'Không tìm thấy món nào.',
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              )
              : ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return Container(
                    color: Colors.white, // Nền trắng cho mỗi item
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100], // Nền nhẹ cho hình ảnh
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(item.image, fit: BoxFit.cover),
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Gilroy',
                          color: Color(0xFFC58A66),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${NumberFormat("#,###", "vi_VN").format(item.price)}đ',
                        style: const TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder:
                              (context) => ItemDetailBottomSheet(item: item),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
