import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  // 🎨 RENKLER (Login ile tutarlı)
  static const Color primaryGreen = Color(0xFF12D6C5);
  static const Color primaryGreenDark = Color(0xFF0BB3A7);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 🎨 Premium Popup Tasarımı
  Future<void> _showPremiumPopup(String title, String message, {required bool success, int durationMs = 2000}) async {
    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'popup',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: (success ? successColor : errorColor).withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // İkon ve arka plan
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: (success ? successColor : errorColor).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        success ? Icons.check_circle_rounded : Icons.error_rounded,
                        size: 40,
                        color: success ? successColor : errorColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Başlık
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Mesaj
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: textMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    await Future.delayed(Duration(milliseconds: durationMs));
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  // 📝 Kayıt Fonksiyonu
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showPremiumPopup(
        'Şartları Kabul Edin',
        'Devam etmek için Kullanım Şartları\'nı kabul etmelisiniz.',
        success: false,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showPremiumPopup(
        'Şifreler Uyuşmuyor',
        'Girdiğiniz şifreler aynı değil. Lütfen kontrol edin.',
        success: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      // Firebase Auth ile kullanıcı oluştur
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore'a kaydet
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
        'name': name,
        'phone': phone,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => _isLoading = false);

        // Başarı popup'ı
        await _showPremiumPopup(
          'Hoş Geldiniz! 🎉',
          'Hesabınız başarıyla oluşturuldu.\nŞimdi giriş yapabilirsiniz.',
          success: true,
          durationMs: 2500,
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      }

    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _isLoading = false);
      String errorMsg = 'Kayıt başarısız oldu.';
      
      if (e.code == 'email-already-in-use') {
        errorMsg = 'Bu e-posta zaten kullanımda.\nFarklı bir e-posta deneyiniz.';
      } else if (e.code == 'weak-password') {
        errorMsg = 'Şifre çok zayıf.\nEn az 8 karakter, harf ve rakam içermelidir.';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Geçersiz e-posta adresi.';
      }

      await _showPremiumPopup('Hata', errorMsg, success: false);

    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      await _showPremiumPopup(
        'Bağlantı Hatası',
        'Veritabanı bağlantısı kurulamadı.\nLütfen internet bağlantınızı kontrol edin.',
        success: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Arka Plan
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_pattern.png',
              fit: BoxFit.cover,
            ),
          ),

          // Soft Overlay
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: Column(
                  children: [
                    const SizedBox(height: 28),

                    // Logo + Slogan
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 40,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'GEGE',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: primaryGreen.withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryGreen.withValues(alpha: 0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Text(
                            'PROFESYONEL LOJİSTİK ÇÖZÜMÜ',
                            style: TextStyle(
                              fontSize: 12,
                              color: textMuted,
                              letterSpacing: 0.9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Form Kartı
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hesap Oluştur',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Kargo gönderimi için hesap açın.',
                                  style: TextStyle(color: textMuted, fontSize: 14),
                                ),
                                const SizedBox(height: 24),

                                // Ad Soyad
                                _inputLabel('Ad Soyad'),
                                const SizedBox(height: 8),
                                _inputField(
                                  controller: _nameController,
                                  hint: 'Ahmet Yılmaz',
                                  icon: Icons.person_outline,
                                  validator: (v) => (v == null || v.isEmpty) ? 'Ad soyad gerekli' : null,
                                ),
                                const SizedBox(height: 16),

                                // Email
                                _inputLabel('Email Adresi'),
                                const SizedBox(height: 8),
                                _inputField(
                                  controller: _emailController,
                                  hint: 'example@mail.com',
                                  icon: Icons.email_outlined,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Email gerekli';
                                    if (!v.contains('@')) return 'Geçersiz email';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Telefon
                                _inputLabel('Telefon Numarası'),
                                const SizedBox(height: 8),
                                _inputField(
                                  controller: _phoneController,
                                  hint: '05XX XXX XXXX',
                                  icon: Icons.phone_outlined,
                                  validator: (v) => (v == null || v.isEmpty) ? 'Telefon gerekli' : null,
                                ),
                                const SizedBox(height: 16),

                                // Şifre
                                _inputLabel('Şifre'),
                                const SizedBox(height: 8),
                                _inputField(
                                  controller: _passwordController,
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  obscure: !_isPasswordVisible,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: textMuted,
                                    ),
                                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Şifre gerekli';
                                    if (v.length < 6) return 'En az 6 karakter';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Şifre Tekrarı
                                _inputLabel('Şifreyi Onayla'),
                                const SizedBox(height: 8),
                                _inputField(
                                  controller: _confirmPasswordController,
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  obscure: !_isConfirmPasswordVisible,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: textMuted,
                                    ),
                                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Şifre tekrarı gerekli';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Şartları Kabul Et
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: _agreedToTerms,
                                      onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                                      activeColor: primaryGreen,
                                      side: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: RichText(
                                          text: TextSpan(
                                            text: 'Kullanım Şartları\'nı kabul ediyorum ve ',
                                            style: const TextStyle(color: textMuted, fontSize: 12),
                                            children: [
                                              TextSpan(
                                                text: 'Gizlilik Politikası',
                                                style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Kayıt Butonu
                                GestureDetector(
                                  onTap: _isLoading ? null : _register,
                                  child: Container(
                                    height: 56,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      gradient: const LinearGradient(
                                        colors: [primaryGreen, primaryGreenDark],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryGreen.withValues(alpha: 0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: _isLoading
                                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                          : const Text(
                                        'KAYIT OL',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Giriş Linki
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Zaten hesabınız var mı? ',
                                      style: TextStyle(color: textMuted, fontSize: 14),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                                      ),
                                      child: const Text(
                                        'Giriş Yap',
                                        style: TextStyle(
                                          color: primaryGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _inputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textMuted),
        prefixIcon: Icon(icon, color: primaryGreen, size: 22),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}