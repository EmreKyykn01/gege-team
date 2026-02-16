import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Authentication/login_screen.dart';

class CourierScreen extends StatefulWidget {
  const CourierScreen({super.key});

  @override
  State<CourierScreen> createState() => _CourierScreenState();
}

class _CourierScreenState extends State<CourierScreen> {
  // Tasarım Renkleri
  static const Color darkBg = Color(0xFF111827);
  static const Color cardBg = Color(0xFF1F2937);
  static const Color primaryYellow = Color(0xFFEAB308);
  static const Color textColor = Color(0xFFF9FAFB);

  // Modern Popup Sistemi (Giriş/Kayıttaki sistemle uyumlu)
  Future<void> _showStatusPopup(String title, String message, {required bool success}) async {
    if (!mounted) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                    child: Icon(success ? Icons.check : Icons.priority_high, color: Colors.white, size: 35),
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 15)),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, __, child) {
        return ScaleTransition(scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack), child: child);
      },
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) Navigator.pop(context);
  }

  // Çıkış Yapma Fonksiyonu
  Future<void> _logout() async {
    try {
      // 1. Firebase oturumunu kapat
      await FirebaseAuth.instance.signOut();

      // 2. Başarı popup'ını göster ve kapanmasını bekle
      await _showStatusPopup(
          'Güle Güle!',
          'Oturum güvenli bir şekilde kapatıldı.',
          success: true
      );

      // 3. Yönlendirme
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false, // Geri dönülmesini engeller
        );
      }
    } catch (e) {
      // Hata durumunda popup göster
      _showStatusPopup('Hata', 'Çıkış yapılırken bir sorun oluştu: $e', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kurye Paneli', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Şu an Görevde', style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent, size: 28),
            onPressed: _logout,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Performans Özeti Kartı
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryYellow, Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: primaryYellow.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSimpleStat("Teslimat", "14"),
                  _buildDivider(),
                  _buildSimpleStat("Kazanç", "₺840"),
                  _buildDivider(),
                  _buildSimpleStat("Puan", "4.9"),
                ],
              ),
            ),
            const SizedBox(height: 35),
            const Text('Aktif Görevler', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Örnek Görev Kartları
            _buildCourierTaskCard("Paket #8812", "Kadıköy Merkez", "Beşiktaş Sahil", "15:30", true),
            _buildCourierTaskCard("Paket #8845", "Üsküdar İskele", "Ataşehir Batı", "16:45", false),

            const SizedBox(height: 100), // FAB için boşluk
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryYellow,
        elevation: 4,
        onPressed: () => _showStatusPopup('Tarayıcı', 'QR Tarayıcı hazırlanıyor...', success: true),
        label: const Text('YENİ PAKET TARA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDivider() => Container(width: 1.5, height: 35, color: Colors.black.withOpacity(0.1));

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20)),
        Text(label, style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCourierTaskCard(String id, String from, String to, String time, bool isUrgent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isUrgent ? primaryYellow.withOpacity(0.3) : Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(id, style: const TextStyle(color: primaryYellow, fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUrgent ? Colors.redAccent.withOpacity(0.2) : Colors.greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isUrgent ? 'ACİL' : 'NORMAL',
                    style: TextStyle(color: isUrgent ? Colors.redAccent : Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 24),
            Row(
              children: [
                Column(
                  children: [
                    const Icon(Icons.radio_button_checked, color: primaryYellow, size: 18),
                    Container(width: 2, height: 20, color: Colors.white10),
                    const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                  ],
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(from, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 18),
                      Text(to, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryYellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () {},
                      child: const Text('BAŞLAT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}