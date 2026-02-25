import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

import '../user/user_main_screen.dart';
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

  // 🔐 LOGIN
  Future<void> _attemptLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userCred =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .get();

      setState(() => _isLoading = false);

      final role = doc['role'] ?? 'user';
      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AdminScreen()));
      } else if (role == 'courier') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => CourierScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const UserMainScreen()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      String errorMessage = 'Giriş başarısız oldu';

      // Hata kodlarına göre Türkçe mesajlar (Firebase exception görmezsin)
      if (e.code == 'user-not-found') {
        errorMessage = 'Bir e-posta adresi ile hesap bulunamadı.\nLütfen kayıt olunuz.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Şifre yanlış.\nLütfen tekrar deneyiniz.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Bu hesap devre dışı bırakılmıştır.\nLütfen destek ile iletişime geçiniz.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Geçersiz e-posta adresi.\nLütfen kontrol edip tekrar deneyiniz.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Çok fazla başarısız giriş denemesi yapıldı.\nLütfen daha sonra tekrar deneyiniz.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'E-posta veya şifre hatalı.\nLütfen kontrol edip tekrar deneyiniz.';
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showErrorDialog('Bir hata oluştu.\nLütfen daha sonra tekrar deneyiniz.');
    }
  }

  // Hata dialog'ı göster - Tema Uyumlu
  void _showErrorDialog(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(28),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hata Ikonu
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.error_rounded, size: 36, color: Color(0xFFEF4444)),
                  ),
                  const SizedBox(height: 16),
                  // Başlık
                  const Text(
                    'Hata',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textDark),
                  ),
                  const SizedBox(height: 8),
                  // Mesaj
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: textMuted),
                  ),
                  const SizedBox(height: 24),
                  // Tamam Butonu
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    ),
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    child: const Text('Tamam', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🔐 GOOGLE İLE GİRİŞ
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Firestore'da kullanıcı kontrol et, yoksa oluştur
      final userRef = FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid);
      final userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        // Yeni kullanıcı oluştur
        await userRef.set({
          'uid': userCred.user!.uid,
          'email': userCred.user!.email,
          'name': userCred.user!.displayName ?? 'Google User',
          'phone': '',
          'role': 'user',
          'profileImageUrl': userCred.user!.photoURL,
          'createdAt': DateTime.now(),
          'isActive': true,
        });
      }

      final doc = await userRef.get();
      setState(() => _isLoading = false);

      final role = doc['role'] ?? 'user';
      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AdminScreen()));
      } else if (role == 'courier') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => CourierScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const UserMainScreen()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      String errorMessage = 'Google ile giriş başarısız oldu';

      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'Bu e-posta başka bir giriş yöntemi ile kayıtlı.\nLütfen o yöntemi kullanınız.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Google kimliği doğrulanamadı.\nLütfen tekrar deneyiniz.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Google ile giriş şu anda kullanılamıyor.\nLütfen daha sonra tekrar deneyiniz.';
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      // Kullanıcı iptal ettiyse hiçbir mesaj gösterme
      if (e.toString().contains('PlatformException') ||
          e.toString().contains('cancel')) {
        return;
      }

      _showErrorDialog('Google ile giriş başarısız oldu.\nLütfen tekrar deneyiniz.');
    }
  }

  // 🔐 APPLE İLE GİRİŞ
  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCred =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      // Firestore'da kullanıcı kontrol et, yoksa oluştur
      final userRef = FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid);
      final userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        // Yeni kullanıcı oluştur
        String fullName = 'Apple User';
        if (appleCredential.givenName != null && appleCredential.familyName != null) {
          fullName = '${appleCredential.givenName} ${appleCredential.familyName}';
        } else if (userCred.user?.displayName != null) {
          fullName = userCred.user!.displayName!;
        }

        await userRef.set({
          'uid': userCred.user!.uid,
          'email': userCred.user!.email ?? 'apple_${userCred.user!.uid}@privaterelay.appleid.com',
          'name': fullName,
          'phone': '',
          'role': 'user',
          'profileImageUrl': null,
          'createdAt': DateTime.now(),
          'isActive': true,
        });
      }

      final doc = await userRef.get();
      setState(() => _isLoading = false);

      final role = doc['role'] ?? 'user';
      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AdminScreen()));
      } else if (role == 'courier') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => CourierScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const UserMainScreen()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      String errorMessage = 'Apple ile giriş başarısız oldu';

      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'Bu e-posta başka bir giriş yöntemi ile kayıtlı.\nLütfen o yöntemi kullanınız.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Apple kimliği doğrulanamadı.\nLütfen tekrar deneyiniz.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Apple ile giriş şu anda kullanılamıyor.\nLütfen daha sonra tekrar deneyiniz.';
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      // Kullanıcı iptal ettiyse hiçbir mesaj gösterme
      if (e.toString().contains('SignUpCanceled') ||
          e.toString().contains('Cancelled') ||
          e.toString().contains('PlatformException')) {
        return;
      }

      _showErrorDialog('Apple ile giriş başarısız oldu.\nLütfen tekrar deneyiniz.');
    }
  }

  // Yardımcı fonksiyonlar
  String _generateNonce([int length = 32]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
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

                                _inputField(
                                  controller: _emailController,
                                  hint: 'Mail adresinizi giriniz',
                                  icon: Icons.mail_outline,
                                  validator: (v) =>
                                  v!.isEmpty ? 'Boş bırakılamaz' : null,
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
                          GestureDetector(
                            onTap: _isLoading ? null : _signInWithGoogle,
                            child: _socialButton(
                                icon: Icons.g_mobiledata,
                                text: 'Google ile devam et'),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _isLoading ? null : _signInWithApple,
                            child: _socialButton(
                                icon: Icons.apple,
                                text: 'Apple ile devam et'),
                          ),
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
}