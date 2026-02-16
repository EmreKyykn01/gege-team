import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_screen.dart';
import '../Home/admin_screen.dart';
import '../Home/courier_screen.dart';
import '../Home/home_screen.dart';
import '../user/home.dart';
import '../user/user_main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Tasarım Renkleri
  static const Color primaryBlue = Color(0xFF1553CE);
  static const Color secondaryGold = Color(0xFFEAB308);
  static const Color backgroundColor = Color(0xFFF4F7FA);
  static const Color textColor = Color(0xFF1F2937);
  static const Color mutedColor = Color(0xFF6B7280);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Premium Popup Sistemi
  Future<void> _showPopup(String title, String message, {required bool success, int durationMs = 1800}) async {
    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'popup',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: success ? primaryBlue : Colors.redAccent,
                    child: Icon(success ? Icons.check_rounded : Icons.priority_high_rounded, size: 35, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: mutedColor, height: 1.4)),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );

    await Future.delayed(Duration(milliseconds: durationMs));
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  // Gerçek Giriş Fonksiyonu
  Future<void> _attemptLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. Auth Girişi
      UserCredential userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Rol Kontrolü (Firestore'dan veri çekme)
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .get();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (userDoc.exists) {
        String role = userDoc['role'] ?? 'user';
        String name = userDoc['name'] ?? 'Yönetici';

        await _showPopup('Hoş Geldiniz!', 'Giriş Başarılı: $name', success: true);

        if (!mounted) return;

        // 3. Role Göre Yönlendirme
        if (role == 'admin') {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminScreen())
          );
        } else if (role == 'courier') {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => CourierScreen())
          );
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserMainScreen())
          );
        }

      } else {
        await _showPopup('Hata', 'Kullanıcı verisi bulunamadı.', success: false);
      }

    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String errorMsg = 'Bilgilerinizi kontrol ediniz.';
      if (e.code == 'user-not-found') errorMsg = 'Kullanıcı bulunamadı.';
      else if (e.code == 'wrong-password') errorMsg = 'Hatalı şifre.';
      await _showPopup('Hata', errorMsg, success: false);
    } catch (e) {
      setState(() => _isLoading = false);
      await _showPopup('Hata', 'Sistem hatası: $e', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Logo
              Hero(
                tag: 'logo',
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: const Icon(Icons.local_shipping, color: Colors.white, size: 45),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Gelirken Getir', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 40),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Giriş Yap', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textColor)),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Hesabınıza erişmek için bilgilerinizi girin.', style: TextStyle(color: mutedColor, fontSize: 15)),
              ),
              const SizedBox(height: 35),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildLabel('Email Adresi'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'mail@domain.com',
                      prefixIcon: Icons.email_outlined,
                      validator: (v) => (v == null || v.isEmpty) ? 'Email boş bırakılamaz' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Şifre'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: mutedColor),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'Şifre çok kısa' : null,
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Şifreni mi unuttun?', style: TextStyle(color: secondaryGold, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 15),

              // Giriş Butonu
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _attemptLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Giriş Yap', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),

              // Kayıt Ol Kısmı (Geliştirilmiş Tasarım)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Henüz bir hesabınız yok mu? ", style: TextStyle(color: mutedColor, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text(
                        'Kayıt Ol',
                        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w800, fontSize: 14, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(color: textColor, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: Icon(prefixIcon, color: primaryBlue.withOpacity(0.7)),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primaryBlue, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

// Extension hatayı önlemek için her iki dosyada da bulunabilir
extension TextCopyWith on Text {
  Text copyWith({Color? color}) {
    return Text(
      data ?? '',
      textAlign: textAlign,
      style: (style ?? const TextStyle()).copyWith(color: color),
    );
  }
}