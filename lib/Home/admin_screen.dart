import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF111827);
    const Color cardBg = Color(0xFF1F2937);
    const Color primaryYellow = Color(0xFFEAB308);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Yönetim Paneli', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Genel Durum', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // İstatistik Kartları
            Row(
              children: [
                _buildStatCard("Aktif Kargo", "124", Icons.local_shipping, primaryYellow, cardBg),
                const SizedBox(width: 15),
                _buildStatCard("Kuryeler", "12", Icons.person_pin_circle, primaryYellow, cardBg),
              ],
            ),
            const SizedBox(height: 30),

            const Text('Hızlı İşlemler', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            _buildAdminAction(cardBg, primaryYellow, "Kurye Atama Yap", Icons.assignment_ind),
            _buildAdminAction(cardBg, primaryYellow, "Kullanıcıları Yönet", Icons.people_alt),
            _buildAdminAction(cardBg, primaryYellow, "Sistem Raporları", Icons.analytics),

            const SizedBox(height: 30),
            const Text('Son Hareketler', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Örnek bir liste öğesi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: darkBg, child: Icon(Icons.add_alert, color: primaryYellow)),
                title: const Text('Yeni Sipariş #8821', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('2 dakika önce oluşturuldu', style: TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color yellow, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: yellow, size: 30),
            const SizedBox(height: 15),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminAction(Color bg, Color yellow, String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: yellow),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: () {},
      ),
    );
  }
}