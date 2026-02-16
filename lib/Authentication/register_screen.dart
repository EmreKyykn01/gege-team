import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Tasarım Renkleri
  static const Color primaryBlue = Color(0xFF1553CE);
  static const Color backgroundColor = Color(0xFFF4F7FA);
  static const Color textColor = Color(0xFF1F2937);
  static const Color mutedColor = Color(0xFF6B7280);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Popup Fonksiyonu
  Future<void> _showPopup(String title, String message, {required bool success, int durationMs = 1800}) async {
    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: false, // İşlem bitene kadar dışarı tıklanmasın
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: success ? primaryBlue : Colors.redAccent,
                    child: Icon(
                      success ? Icons.check_rounded : Icons.priority_high_rounded,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: mutedColor, height: 1.4),
                  ),
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
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  // Kayıt Fonksiyonu - KESİN YÖNLENDİRME KONTROLLÜ
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _nameController.text.trim();

      // 1. Firebase Auth ile kullanıcı oluşturma
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Firestore'a kullanıcı bilgilerini kaydetme
      // Bu işlem hata verirse direkt 'catch' bloğuna atlar ve aşağıdaki yönlendirme çalışmaz.
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
        'name': name,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. EĞER BURAYA KADAR HATASIZ GELDİYSE BAŞARILI DEMEKTİR
      if (mounted) {
        setState(() => _isLoading = false);

        // Başarı popup'ını göster ve BİTMESİNİ BEKLE (await)
        await _showPopup(
            'Harika!',
            'Hesabınız başarıyla oluşturuldu. Giriş yapabilirsiniz.',
            success: true,
            durationMs: 2200
        );

        // Sadece her şey bittikten sonra giriş ekranına at
        if (mounted) {
          Navigator.of(context).pop();
        }
      }

    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _isLoading = false);
      String errorMsg = 'Kayıt başarısız.';
      if (e.code == 'email-already-in-use') errorMsg = 'Bu e-posta zaten kullanımda.';
      else if (e.code == 'weak-password') errorMsg = 'Şifre çok zayıf.';

      // Hata durumunda sadece popup gösterilir, yönlendirme yapılmaz.
      await _showPopup('Hata', errorMsg, success: false);

    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      // Firestore kuralları veya internet hatası buraya düşer
      await _showPopup('Hata', 'Veritabanı bağlantısı kurulamadı. (Kuralları kontrol edin)', success: false);
      // Burada Navigator.pop() YOK, kullanıcı ekranda kalır.
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
              const SizedBox(height: 40),
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.local_shipping, color: Colors.white, size: 35),
              ),
              const SizedBox(height: 16),
              const Text('Gelirken Getir', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 30),
              const Text('Kayıt Ol', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: textColor)),
              const SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildLabel('Ad Soyad'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Örn: Ahmet Yılmaz',
                      prefixIcon: Icons.person_outline,
                      validator: (v) => (v == null || v.isEmpty) ? 'İsim gerekli' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Email'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'example@mail.com',
                      prefixIcon: Icons.email_outlined,
                      validator: (v) => (v == null || !v.contains('@')) ? 'Geçersiz email' : null,
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
                      validator: (v) => (v == null || v.length < 6) ? 'En az 6 karakter' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Kayıt Ol', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Zaten hesabın var mı? ", style: TextStyle(color: mutedColor)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Giriş yap', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)));
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, required IconData prefixIcon, bool obscureText = false, Widget? suffixIcon, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller, obscureText: obscureText, validator: validator,
      decoration: InputDecoration(
        filled: true, fillColor: Colors.white, hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: mutedColor), suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue)),
      ),
    );
  }
}