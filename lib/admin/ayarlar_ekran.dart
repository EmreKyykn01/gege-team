import 'package:flutter/material.dart';
import 'package:gg/Authentication/login_screen.dart';
// BURAYA DİKKAT: Dosya yolunu kendi klasör yapına göre düzelt
import 'sistem_yapilandirma_sayfasi.dart';

class AyarlarEkran extends StatelessWidget {
  const AyarlarEkran({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 35),
              _buildProfileCard(isDark),
              const SizedBox(height: 40),

              _sectionLabel("HESAP VE FİNANS"),
              // İŞTE BURASI: Navigator artık aktif!
              _buildSettingItem(
                Icons.settings_suggest_outlined,
                "Sistem Yapılandırması",
                "Genel çalışma ve sistem parametreleri",
                Colors.blue,
                isDark,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SistemYapilandirmaSayfasi())
                  );
                },
              ),
              _buildSettingItem(Icons.account_balance_wallet_outlined, "Ödeme Yöntemleri", "Banka ve pos entegrasyonu", Colors.orange, isDark),

              const SizedBox(height: 25),

              _sectionLabel("OPERASYONEL"),
              _buildSettingItem(Icons.notifications_none_rounded, "Bildirim Ayarları", "Sipariş ve kurye uyarıları", Colors.purple, isDark),
              _buildSettingItem(Icons.map_outlined, "Bölge Yönetimi", "Aktif hizmet alanları", Colors.green, isDark),
              _buildSettingItem(Icons.admin_panel_settings_outlined, "Güvenlik & Rol Yönetimi", "Yönetici rolleri ve erişim izinleri", Colors.teal, isDark),

              const SizedBox(height: 25),

              _sectionLabel("UYGULAMA GENEL"),
              _buildSettingItem(Icons.translate_rounded, "Dil Seçimi", "Türkçe (Varsayılan)", Colors.pink, isDark),
              _buildSettingItem(Icons.help_outline_rounded, "Destek & Yardım", "7/24 operasyon desteği", Colors.grey, isDark),

              _buildBottomSection(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String sub, Color col, bool isDark, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E26) : Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: ListTile(
        onTap: onTap, // Bu satır sayesinde tıklama çalışıyor
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
          child: Icon(icon, color: col, size: 22),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black)),
        subtitle: Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  // --- DİĞER YARDIMCI METODLAR (Header, ProfileCard, SectionLabel, BottomSection aynı kalacak) ---
  Widget _buildHeader(bool isDark) { return Row(children: [/* Mevcut kodun */]); }
  Widget _buildProfileCard(bool isDark) { return Container(/* Mevcut kodun */); }
  Widget _sectionLabel(String title) { return Text(title); }
  Widget _buildBottomSection(BuildContext context, bool isDark) { return Column(/* Mevcut kodun */); }
}