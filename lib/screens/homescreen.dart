import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:ui';
import 'package:marquee/marquee.dart';

class HomeScreen1 extends StatefulWidget {
  final VoidCallback goToOrder;

  const HomeScreen1({Key? key, required this.goToOrder}) : super(key: key);
  @override
  State<HomeScreen1> createState() => _HomeScreen1State();
}

class _HomeScreen1State extends State<HomeScreen1> {
  final PanelController _panelController = PanelController();
  double _currentPanelHeight = 0;
  bool _isAtTop = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final double maxPanelHeight = screenHeight;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      //backgroundColor: const Color.fromARGB(255, 177, 133, 105),
      body: Stack(
        children: [
          // HEADER TRÊN
          Positioned.fill(
            child: Image.network(
              'https://upload.wikimedia.org/wikipedia/en/9/9f/Midnights_-_Taylor_Swift.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),

          // Blur chỉ áp dụng lên ảnh
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent), // bắt buộc có
            ),
          ),

          // Lớp phủ màu nâu 70%
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(163, 162, 111, 80), // 70% opacity
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm món bạn cần...',
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(
                                8.0,
                              ), // padding cho đẹp
                              child: Image.asset(
                                'assets/images/loupe 1.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 12,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: IconButton(
                        icon: Image.asset(
                          'assets/images/voucher_icon.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                        onPressed: () {
                          // hành động khi nhấn nút voucher
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: IconButton(
                        icon: Image.asset(
                          'assets/images/noti 1.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                        onPressed: () {
                          // hành động khi nhấn nút noti
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nhạc đang phát ♫',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Gilroy',
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 24, // chiều cao dòng chữ
                            child: Marquee(
                              text: 'Snow on the beach - Taylor Swift',
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Gilroy',
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              blankSpace: 30.0,
                              velocity: 30.0,
                              startPadding: 10.0,
                              accelerationDuration: Duration(seconds: 1),
                              accelerationCurve: Curves.linear,
                              decelerationDuration: Duration(milliseconds: 500),
                              decelerationCurve: Curves.easeOut,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                130,
                                32,
                              ), // Đặt kích thước cho nút
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  18,
                                ), // Bo góc
                              ),
                            ),
                            child: const Text(
                              'Đề xuất nhạc',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    //Chứa ảnh album, đây là ảnh cần phải xoay
                    Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://upload.wikimedia.org/wikipedia/en/9/9f/Midnights_-_Taylor_Swift.png',
                          ),
                          fit: BoxFit.cover, // để ảnh phủ đều khung hình tròn
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // PANEL TRƯỢT LÊN
          SlidingUpPanel(
            controller: _panelController,
            minHeight: screenHeight - 350,
            maxHeight: maxPanelHeight,
            borderRadius:
                _isAtTop
                    ? const BorderRadius.vertical(top: Radius.circular(0))
                    : const BorderRadius.vertical(top: Radius.circular(24)),
            onPanelSlide: (position) {
              final height = position * maxPanelHeight;
              setState(() {
                _currentPanelHeight = height;
                _isAtTop = height >= maxPanelHeight - 30;
              });
            },
            panelBuilder:
                (scrollController) => _buildPanel(scrollController, _isAtTop),
            parallaxEnabled: true,
            parallaxOffset: 0.5,
            body: const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(ScrollController controller, bool isAtTop) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(16.0),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: actionBox(
                title: "Mang đi",
                subtitle: "tại quán",
                assetImagePath: "assets/images/MangDi.png",
                backgroundColor: Color(0xFFD3BAAE),
                onTap: widget.goToOrder,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: actionBox(
                title: "Đặt Món",
                subtitle: "tại quán",
                assetImagePath: "assets/images/DatMon.png",
                backgroundColor: Color(0xFFE4B9A2),
                onTap: widget.goToOrder,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ...List.generate(1, (_) => _section()),
      ],
    );
  }

  Widget _section() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CÁC MÓN NÊN THỬ MỘT LẦN ✨',
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250, // Đặt chiều cao phù hợp cho thẻ card
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              drinkCard('Cà Phê Đá', '40.000đ', 'assets/images/capheda.png'),
              SizedBox(width: 16), // Khoảng cách giữa các card
              drinkCard('Cà Phê Sữa', '45.000đ', 'assets/images/caphesua.png'),
              SizedBox(width: 16),
              drinkCard('Latte Đá', '45.000đ', 'assets/images/latteda.png'),
              SizedBox(width: 16),
              drinkCard('Americano', '35.000đ', 'assets/images/americano.png'),
              SizedBox(width: 16), // Khoảng cách giữa các card
              drinkCard('Bạc Xỉu', '45.000đ', 'assets/images/caphesua.png'),
              SizedBox(width: 16),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text(
          'CÁC SẢN PHẨM ĐÓNG GÓI 👋🏼',
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        // Row(
        //   children: [
        //     // popularItem('Tai nghe chụp tai', '5.000đ', Icons.headphones),
        //     // const SizedBox(width: 16),
        //     // popularItem('Đồ buộc tóc', 'miễn phí', Icons.favorite),
        //     drinkCard('Latte Đá', '45.000đ', 'assets/images/caphesua.png'),
        //     SizedBox(width: 16),
        //     drinkCard('Cà Phê Sữa', '45.000đ', 'assets/images/caphesua.png'),
        //     SizedBox(width: 16),
        //     drinkCard('Cà Phê Sữa', '45.000đ', 'assets/images/caphesua.png'),
        //     SizedBox(width: 16),
        //     drinkCard('Cà Phê Sữa', '45.000đ', 'assets/images/caphesua.png'),
        //   ],
        // ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250, // Đặt chiều cao phù hợp cho thẻ card
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              drinkCard(
                'Cà Phê Đá',
                '40.000đ',
                'assets/images/ca-phe-goi-caramel.png',
              ),
              SizedBox(width: 16), // Khoảng cách giữa các card
              drinkCard(
                'Latte Đá',
                '45.000đ',
                'assets/images/ca-phe-goi-caramel.png',
              ),
              SizedBox(width: 16),
              drinkCard(
                'Cà Phê Sữa',
                '45.000đ',
                'assets/images/ca-phe-goi-caramel.png',
              ),
              SizedBox(width: 16),
              drinkCard(
                'Cà Phê Đá',
                '40.000đ',
                'assets/images/ca-phe-goi-caramel.png',
              ),
              SizedBox(width: 16), // Khoảng cách giữa các card
              drinkCard(
                'Latte Đá',
                '45.000đ',
                'assets/images/ca-phe-goi-caramel.png',
              ),
              SizedBox(width: 16),
              drinkCard(
                'Cà Phê Sữa',
                '45.000đ',
                'assets/images/ca-phe-goi-caramel.png',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget actionBox({
    required String title,
    required String subtitle,
    required String assetImagePath,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Hình ảnh (không chịu padding và bị cắt nếu tràn)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Image.asset(
                    assetImagePath,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
                // Padding nội dung
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          //height: 1.2,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Nút tròn ở góc trái
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.brown,
                      weight: 10,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget drinkCard(String name, String price, String imagePath) {
    return Container(
      width: 150,
      height: 180, // đặt chiều cao card cố định
      decoration: BoxDecoration(
        color: Color(0xFFFFF5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "MỌI NGƯỜI\nBẢO NGON",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w900,
                        color: Color.fromARGB(255, 132, 65, 69),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  SizedBox(height: 42),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      imagePath,
                      width: 100,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 8, //khoảng cách so với đáy
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              width: 136,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 110, // hoặc width cụ thể như 120
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              price,
                              style: const TextStyle(
                                fontFamily: 'Gilroy',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.brown,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget popularItem(String name, String price, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.brown),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13)),
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
