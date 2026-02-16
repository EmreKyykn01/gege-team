import 'package:flutter/material.dart';
import 'saved_addresses_view.dart';
import 'notification_settings_view.dart';
import 'help_support_view.dart';
import 'about_us_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Menüdeyiz
        title: const Text("Profilim", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
                    // TODO: Ödeme yöntemleri sayfası eklenebilir
                  },
                ),
                _buildMenuItem(
                  Icons.notifications_none,
                  "Bildirim Ayarları",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsView()));
                  },
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
            _buildLogoutButton(context),
            const SizedBox(height: 40), // Alt bar boşluğu
          ],
        ),
      ),
    );
  }

  // Üst Kısım: Profil Fotoğrafı ve İsim
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/512/3135/3135715.png"), // Örnek Avatar
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFF1DE9B6), shape: BoxShape.circle),
              child: const Icon(Icons.edit, color: Colors.white, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text("Ahmet Yılmaz", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("+90 555 123 45 67", style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  // Menü Grupları (Hesap, Diğer vb.)
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
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
        decoration: BoxDecoration(color: const Color(0xFF1DE9B6).withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF00BFA5), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Çıkış Yap Butonu
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          // Çıkış yapıldığında Login ekranına yönlendirme
          // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
        },
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text("Çıkış Yap", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.redAccent.withOpacity(0.1),
        ),
      ),
    );
  }
}