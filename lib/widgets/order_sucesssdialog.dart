import 'package:flutter/material.dart';
import 'orderhistory.dart'; // Nhớ sửa đường dẫn nếu khác

class OrderSuccessDialog extends StatefulWidget {
  final String orderId;

  const OrderSuccessDialog({Key? key, required this.orderId}) : super(key: key);

  static Future<void> show(BuildContext context, {required String orderId}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false, // ❌ Không cho bấm ra ngoài để tắt
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(child: OrderSuccessDialog(orderId: orderId));
      },
    );
  }

  @override
  State<OrderSuccessDialog> createState() => _OrderSuccessDialogState();
}

class _OrderSuccessDialogState extends State<OrderSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );

    _startAnimation();

    // 🕒 Tự động chuyển màn hình sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // đóng dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
        );
      }
    });
  }

  void _startAnimation() async {
    await _scaleController.forward();
    await _checkController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _checkAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: CheckMarkPainter(_checkAnimation.value),
                            size: const Size(80, 80),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Đặt hàng thành công!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Mã đơn hàng: ${widget.orderId}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cảm ơn bạn đã đặt hàng!\nChúng tôi sẽ xử lý đơn hàng của bạn ngay.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckMarkPainter extends CustomPainter {
  final double progress;

  CheckMarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final checkPath = Path();

    final startPoint = Offset(center.dx - 10, center.dy);
    final middlePoint = Offset(center.dx - 2, center.dy + 8);
    final endPoint = Offset(center.dx + 12, center.dy - 8);

    checkPath.moveTo(startPoint.dx, startPoint.dy);

    if (progress <= 0.5) {
      final currentPoint = Offset.lerp(startPoint, middlePoint, progress * 2);
      checkPath.lineTo(currentPoint!.dx, currentPoint.dy);
    } else {
      checkPath.lineTo(middlePoint.dx, middlePoint.dy);
      final currentPoint = Offset.lerp(
        middlePoint,
        endPoint,
        (progress - 0.5) * 2,
      );
      checkPath.lineTo(currentPoint!.dx, currentPoint.dy);
    }

    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
