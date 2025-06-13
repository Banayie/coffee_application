import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String _verificationId = "";
  bool hasError = false;

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Đăng xuất khỏi Google trước khi đăng nhập lại
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đăng nhập Google thành công!")));

      // Sau khi đăng nhập thành công, chuyển đến màn hình Home
      Navigator.pushReplacementNamed(context, '/mainscreen');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đăng nhập Google thất bại: $e")));
    }
  }

  Future<void> _sendOtpAgain(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gửi lại mã thất bại: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        _showOtpBottomSheet(phoneNumber);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void _showOtpBottomSheet(String phoneNumber) {
    otpController.clear();
    hasError = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Stack(
                children: [
                  Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Xác thực mã OTP",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: "Bọn mình vừa gửi mã xác thực đến số ",
                              ),
                              TextSpan(
                                text: phoneNumber,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ". Nhập để tiếp tục nhé!"),
                            ],
                          ),
                        ),
                        SizedBox(height: 48),
                        PinCodeTextField(
                          appContext: context,
                          length: 6,
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          onChanged: (value) {
                            if (hasError) {
                              setModalState(() {
                                hasError = false;
                              });
                            }
                          },
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(6),
                            fieldHeight: 58,
                            fieldWidth: 42,
                            activeColor: hasError ? Colors.red : Colors.grey,
                            inactiveColor: hasError ? Colors.red : Colors.grey,
                            selectedColor:
                                hasError ? Colors.red : Colors.orange,
                            fieldOuterPadding: EdgeInsets.only(right: 12),
                          ),
                        ),
                        SizedBox(height: 48),
                        GestureDetector(
                          onTap: () => _sendOtpAgain(phoneNumber),
                          child: RichText(
                            text: TextSpan(
                              text: "Bạn không nhận được mã? ",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: "Gửi lại mã",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC58A66),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFC58A66),
                            minimumSize: Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            String otp = otpController.text.trim();
                            if (otp.length == 6) {
                              try {
                                PhoneAuthCredential credential =
                                    PhoneAuthProvider.credential(
                                      verificationId: _verificationId,
                                      smsCode: otp,
                                    );
                                await FirebaseAuth.instance
                                    .signInWithCredential(credential);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Xác thực thành công!"),
                                  ),
                                );
                                // Chuyển sang màn hình Home sau khi xác thực OTP thành công
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/mainscreen',
                                );
                              } catch (e) {
                                setModalState(() {
                                  hasError = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Sai mã OTP hoặc mã đã hết hạn.",
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            "Xác thực",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 24,
                    right: 24,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 24, color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/cf1 1.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 40),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Làm quen nhé!",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: MediaQuery.of(context).size.height * 0.6361,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 10),
                            Image.asset("assets/images/Cờ VN.png", width: 20),
                            SizedBox(width: 5),
                            Text("+84", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Nhập số điện thoại",
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFC58A66),
                      minimumSize: Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      String rawPhone = phoneController.text.trim();
                      String phoneNumber =
                          '+84${rawPhone.replaceFirst(RegExp(r'^0'), '')}';
                      if (rawPhone.isNotEmpty) {
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: phoneNumber,
                          timeout: const Duration(seconds: 60),
                          verificationCompleted: (
                            PhoneAuthCredential credential,
                          ) async {
                            await FirebaseAuth.instance.signInWithCredential(
                              credential,
                            );
                            Navigator.pushReplacementNamed(
                              context,
                              '/mainscreen',
                            );
                          },
                          verificationFailed: (FirebaseAuthException e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Xác minh thất bại: ${e.message}",
                                ),
                              ),
                            );
                          },
                          codeSent: (String verificationId, int? resendToken) {
                            setState(() {
                              _verificationId = verificationId;
                            });
                            _showOtpBottomSheet(phoneNumber);
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {
                            _verificationId = verificationId;
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Vui lòng nhập số điện thoại!"),
                          ),
                        );
                      }
                    },
                    child: Text(
                      "Đăng nhập",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Color(0xFFCDCED1), thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Hoặc tiếp tục với",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFFB8AFAF),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Color(0xFFCDCED1), thickness: 1),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  _buildSocialButton(
                    "Tiếp tục bằng Facebook",
                    Colors.blue,
                    "assets/images/fb logo.png",
                    onPressed: () {},
                  ),
                  SizedBox(height: 16),
                  _buildSocialButton(
                    "Tiếp tục bằng Apple",
                    Colors.black,
                    "assets/images/apple logo.png",
                    onPressed: () {},
                  ),
                  SizedBox(height: 16),
                  _buildSocialButton(
                    "Tiếp tục bằng Google",
                    Colors.white,
                    "assets/images/google logo.png",
                    textColor: Colors.black,
                    hasBorder: true,
                    onPressed: _signInWithGoogle,
                  ),
                  SizedBox(height: 40),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/staff_login');
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Đăng nhập với ",
                            style: TextStyle(fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: "vai trò nhân viên",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    String text,
    Color color,
    String imagePath, {
    Color textColor = Colors.white,
    bool hasBorder = false,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side:
              hasBorder
                  ? BorderSide(color: Color(0xFFCDCED1))
                  : BorderSide.none,
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(imagePath, width: 24, height: 24, fit: BoxFit.contain),
          Expanded(
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
