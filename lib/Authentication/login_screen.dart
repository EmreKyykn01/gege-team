import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../user/user_main_screen.dart';
import '../utils/error_handler.dart';
import 'register_screen.dart';
import '../Home/admin_screen.dart';
import '../Home/courier_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // 🎨 RENKLER
  static const Color primaryGreen = Color(0xFF12D6C5);
  static const Color primaryGreenDark = Color(0xFF0BB3A7);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🔐 LOGIN - PROPER ERROR HANDLING
  Future<void> _attemptLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Firebase ile giriş yap
      final userCred =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Kullanıcı belgesi kontrol et
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .get();

      if (!mounted) {
        setState(() => _isLoading = false);
        return;
      }

      setState(() => _isLoading = false);

      // Belgenin var olup olmadığını kontrol et
      if (!doc.exists) {
        _showErrorDialog('Kullanıcı Bulunamadı', 'Kullanıcı profili veritabanında bulunamadı.');
        return;
      }

      // Rol bilgisini güvenli bir şekilde al
      final role = doc.data()?['role'] ?? 'user';

      // Rol'e göre yönlendir
      if (role == 'admin') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminScreen()));
      } else if (role == 'courier') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const CourierScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const UserMainScreen()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);

      final errorMsg = ErrorHandler.getAuthErrorMessage(e.code);
      _showErrorDialog('Giriş Hatası', errorMsg);
    } on FirebaseException catch (e) {
      setState(() => _isLoading = false);
      final errorMsg = ErrorHandler.getFirestoreErrorMessage(e.message ?? '');
      _showErrorDialog('Ağ Hatası', errorMsg);
    } catch (e) {
      setState(() => _isLoading = false);
      final errorMsg = ErrorHandler.getGeneralErrorMessage(e.toString());
      _showErrorDialog('Beklenmeyen Hata', errorMsg);
    }
  }

  // Hata Dialog'unu Göster
  void _showErrorDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam', style: TextStyle(color: primaryGreen)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 ARKA PLAN
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_pattern.png',
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 SOFT OVERLAY
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
                    const SizedBox(height: 36),

                    // 🔹 LOGO + SLOGAN
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
                            borderRadius: BorderRadius.circular(999), // tam oval
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

                    const SizedBox(height: 36),

                    // 🔹 FORM KART (KORUNAN TASARIM)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(24),
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
                              children: [
                                const Text(
                                  'Hoş Geldiniz!',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Kargo gönderiminiz için giriş yapın.',
                                  style: TextStyle(color: textMuted),
                                ),
                                const SizedBox(height: 28),

                                // E-posta alanı
                                _inputLabel('E-posta Adresi'),
                                const SizedBox(height: 8),
                                _inputField(
                                  controller: _emailController,
                                  hint: 'example@mail.com',
                                  icon: Icons.email_outlined,
                                  validator: ErrorHandler.validateEmail,
                                ),
                                const SizedBox(height: 16),

                                _inputField(
                                  controller: _passwordController,
                                  hint: 'Şifre',
                                  icon: Icons.lock_outline,
                                  obscure: !_isPasswordVisible,
                                  suffix: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: textMuted,
                                    ),
                                    onPressed: () => setState(() =>
                                    _isPasswordVisible =
                                    !_isPasswordVisible),
                                  ),
                                  validator: (v) =>
                                  v!.length < 6 ? 'Şifre kısa' : null,
                                ),

                                const SizedBox(height: 22),

                                GestureDetector(
                                  onTap:
                                  _isLoading ? null : _attemptLogin,
                                  child: Container(
                                    height: 56,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(18),
                                      gradient: const LinearGradient(
                                        colors: [
                                          primaryGreen,
                                          primaryGreenDark
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: _isLoading
                                          ? const CircularProgressIndicator(
                                          color: Colors.white)
                                          : const Text(
                                        'GİRİŞ YAP',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 22),

                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Hesabınız yok mu? ',
                                      style:
                                      TextStyle(color: textMuted),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                            const RegisterScreen()),
                                      ),
                                      child: const Text(
                                        'Kayıt Ol',
                                        style: TextStyle(
                                          color: primaryGreen,
                                          fontWeight:
                                          FontWeight.bold,
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

                    // 🔹 SOSYAL GİRİŞ
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          _socialButton(
                              icon: Icons.g_mobiledata,
                              text: 'Google ile devam et'),
                          const SizedBox(height: 12),
                          _socialButton(
                              icon: Icons.apple,
                              text: 'Apple ile devam et'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton({required IconData icon, required String text}) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
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
        prefixIcon: Icon(icon, color: primaryGreen),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}

