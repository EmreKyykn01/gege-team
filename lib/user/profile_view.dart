import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../Authentication/login_screen.dart';
import 'saved_addresses_view.dart';
import 'notification_settings_view.dart';
import 'help_support_view.dart';
import 'about_us_view.dart';
import 'payment_methods_view.dart';
import '../services/firestore_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String userName = 'Yönetici';
  String userPhone = '+90 555 123 45 67';
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Firestore'dan kullanıcı bilgilerini yükle
  Future<void> _loadUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            userName = doc.data()?['name'] ?? user.displayName ?? '';
            userPhone = doc.data()?['phone'] ?? '';
            profileImageUrl = doc.data()?['profileImageUrl'];
          });
        } else {
          setState(() {
            userName = user.displayName ?? '';
            userPhone = '';
            profileImageUrl = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Kullanıcı bilgileri yüklenirken hata: $e');
    }
  }

  // Profil fotoğrafı güncelleme
  Future<void> _updateProfilePhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final ref = FirebaseStorage.instance.ref().child('profile_photos/${user.uid}.jpg');
      await ref.putData(await pickedFile.readAsBytes());
      final url = await ref.getDownloadURL();
      await FirestoreService().updateUserProfile(uid: user.uid, profileImageUrl: url);
      setState(() { profileImageUrl = url; });
    }
  }

  // Tema renkleri
  static const Color _primaryGreen = Color(0xFF12D6C5);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _errorColor = Color(0xFFEF4444);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);

  Future<void> _showThemedPopup(String title, String message, {required bool success, bool warning = false, int durationMs = 2000}) async {
    if (!mounted) return;
    final Color iconColor = success
        ? _successColor
        : warning
          ? _primaryGreen
          : _errorColor;
    final IconData icon = success
        ? Icons.check_circle_rounded
        : warning
          ? Icons.info_rounded
          : Icons.error_rounded;
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
                    color: _primaryGreen.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 36, color: iconColor),
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: _textMuted)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
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
    await Future.delayed(Duration(milliseconds: durationMs));
  }

  // Şifre güncelleme
  Future<void> _changePassword() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
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
                    color: _primaryGreen.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Şifreyi Değiştir', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                  const SizedBox(height: 16),
                  TextField(controller: oldPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Mevcut Şifre')),
                  const SizedBox(height: 8),
                  TextField(controller: newPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Yeni Şifre')),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal', style: TextStyle(color: _textDark)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;
                            final cred = EmailAuthProvider.credential(email: user.email!, password: oldPasswordController.text);
                            try {
                              await user.reauthenticateWithCredential(cred);
                              await user.updatePassword(newPasswordController.text);
                              Navigator.pop(context);
                              await _showThemedPopup('Başarılı', 'Şifre başarıyla değiştirildi.', success: true);
                            } catch (e) {
                              Navigator.pop(context);
                              await _showThemedPopup('Hata', 'Şifre değiştirilemedi: $e', success: false);
                            }
                          },
                          child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Ad/Telefon güncelleme
  Future<void> _editProfileInfo() async {
    final nameController = TextEditingController(text: userName);
    final phoneController = TextEditingController(text: userPhone);
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
                    color: _primaryGreen.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Profil Bilgilerini Güncelle', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                  const SizedBox(height: 16),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Ad Soyad')),
                  const SizedBox(height: 8),
                  TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telefon')),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal', style: TextStyle(color: _textDark)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;
                            await FirestoreService().updateUserProfile(uid: user.uid, name: nameController.text, phone: phoneController.text);
                            setState(() {
                              userName = nameController.text;
                              userPhone = phoneController.text;
                            });
                            Navigator.pop(context);
                            await _showThemedPopup('Başarılı', 'Profil güncellendi.', success: true);
                          },
                          child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // E-posta güncelleme
  Future<void> _changeEmail() async {
    final emailController = TextEditingController(text: FirebaseAuth.instance.currentUser?.email ?? '');
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
                    color: _primaryGreen.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('E-posta Güncelle', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                  const SizedBox(height: 16),
                  TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Yeni E-posta')),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal', style: TextStyle(color: _textDark)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;
                            try {
                              await user.verifyBeforeUpdateEmail(emailController.text);
                              await FirestoreService().updateUser(user.uid, {'email': emailController.text});
                              Navigator.pop(context);
                              await _showThemedPopup('Başarılı', 'E-posta güncellendi. Lütfen yeni e-posta ile tekrar giriş yapın.', success: true);
                              await FirebaseAuth.instance.signOut();
                              if (mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              Navigator.pop(context);
                              await _showThemedPopup('Hata', 'E-posta güncellenemedi: $e', success: false);
                            }
                          },
                          child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Hesap silme
  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
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
                    color: _primaryGreen.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Hesabı Sil', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                  const SizedBox(height: 16),
                  const Text('Hesabınızı kalıcı olarak silmek istediğinize emin misiniz? Bu işlem geri alınamaz.', style: TextStyle(color: _textMuted)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal', style: TextStyle(color: _textDark)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _errorColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                              await user.delete();
                              Navigator.pop(context);
                              await _showThemedPopup('Başarılı', 'Hesabınız silindi.', success: true);
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            } catch (e) {
                              Navigator.pop(context);
                              await _showThemedPopup('Hata', 'Hesap silinemedi: $e', success: false);
                            }
                          },
                          child: const Text('Sil', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Çıkış fonksiyonu
  Future<void> _logout() async {
    try {
      // Firebase oturumunu kapat
      await FirebaseAuth.instance.signOut();

      // Giriş ekranına yönlendir ve önceki sayfaları kaldır
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Çıkış yapılırken hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Çıkış yapılırken hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Profilim", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF00BFA5)),
            onPressed: () async { await _editProfileInfo(); },
            tooltip: 'Profil Bilgilerini Düzenle',
          ),
          IconButton(
            icon: const Icon(Icons.email_outlined, color: Color(0xFF00BFA5)),
            onPressed: () async { await _changeEmail(); },
            tooltip: 'E-posta Güncelle',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildMenuSection(
              title: "Hesap",
              items: [
                _buildMenuItem(
                  Icons.location_on_outlined,
                  "Kayıtlı Adreslerim",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedAddressesView()));
                  },
                ),
                _buildMenuItem(
                  Icons.credit_card_outlined,
                  "Ödeme Yöntemleri",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsView()));
                  },
                ),
                _buildMenuItem(
                  Icons.notifications_none,
                  "Bildirim Ayarları",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsView()));
                  },
                ),
                _buildMenuItem(
                  Icons.lock_outline,
                  "Şifreyi Değiştir",
                  onTap: () async { await _changePassword(); },
                ),
                _buildMenuItem(
                  Icons.delete_outline,
                  "Hesabı Sil",
                  onTap: () async { await _deleteAccount(); },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildMenuSection(
              title: "Diğer",
              items: [
                _buildMenuItem(
                  Icons.help_outline,
                  "Yardım ve Destek",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportView()));
                  },
                ),
                _buildMenuItem(
                  Icons.info_outline,
                  "Hakkımızda",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsView()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Üst Kısım: Profil Fotoğrafı ve Dinamik İsim
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : const NetworkImage("https://cdn-icons-png.flaticon.com/512/3135/3135715.png"),
            ),
            GestureDetector(
              onTap: () async { await _updateProfilePhoto(); },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFF1DE9B6), shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(userName.isNotEmpty ? userName : 'İsim Yok', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(userPhone.isNotEmpty ? userPhone : 'Telefon Yok', style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  // Menü Grupları
  Widget _buildMenuSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  // Tekil Menü Elemanı
  Widget _buildMenuItem(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF1DE9B6).withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF00BFA5), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () async { onTap(); },
    );
  }

  // Aktif Çıkış Yap Butonu
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text("Çıkış Yap", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}