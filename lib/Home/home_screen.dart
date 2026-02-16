import 'package:flutter/material.dart';
import '../Home/tracking_details_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Renk Paleti (image_da22fb.jpg'den analiz edildi)
    const Color darkBg = Color(0xFF111827); // Çok koyu lacivert/siyah
    const Color cardBg = Color(0xFF1F2937); // Kart arka planı
    const Color primaryYellow = Color(0xFFEAB308); // Canlı sarı
    const Color mutedText = Color(0xFF9CA3AF);

    return Scaffold(
      backgroundColor: darkBg,
      bottomNavigationBar: _buildBottomNav(primaryYellow),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              _buildHeader(),
              const SizedBox(height: 30),
              // Track Your Package Text
              const Text(
                'Track your Package',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Search Bar
              _buildSearchBar(cardBg, primaryYellow),
              const SizedBox(height: 30),
              // Quick Actions
              const Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildQuickActions(cardBg, primaryYellow),
              const SizedBox(height: 30),
              // Active Shipments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Shipments', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('See All', style: TextStyle(color: primaryYellow))),
                ],
              ),
              _buildShipmentCard(context, cardBg, primaryYellow, "#CRG-88291", "İstanbul", "Ankara", 0.75),
              _buildShipmentCard(context, cardBg, primaryYellow, "#CRG-11029", "İzmir", "Bursa", 0.35),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryYellow,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Header: Profil ve Bildirim
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex'), // Örnek resim
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hoşgeldin', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                const Text('Alex Morgan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.notifications_none, color: Colors.white),
        ),
      ],
    );
  }

  // Search Bar
  Widget _buildSearchBar(Color bg, Color yellow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: yellow),
          hintText: 'Enter Tracking ID...',
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.qr_code_scanner, color: Colors.grey),
        ),
      ),
    );
  }

  // Hızlı Aksiyonlar
  Widget _buildQuickActions(Color bg, Color yellow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionItem(bg, yellow, Icons.inventory_2, "Send Package"),
        _actionItem(bg, yellow, Icons.calculate, "Calculator"),
        _actionItem(bg, yellow, Icons.location_on, "Find Branch"),
      ],
    );
  }

  Widget _actionItem(Color bg, Color yellow, IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
          child: Icon(icon, color: yellow, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  // Gönderi Kartı
  Widget _buildShipmentCard(
      BuildContext context, // Navigasyon için context ekledik
      Color bg,
      Color yellow,
      String id,
      String from,
      String to,
      double progress
      ) {
    return GestureDetector(
      onTap: () {
        // Detay sayfasına yönlendirme
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TrackingDetailsScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28), // Daha yumuşak köşeler
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Üst Kısım: ID ve Durum Etiketi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: yellow.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.local_shipping_rounded, color: yellow, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Takip Numarası',
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          id,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: yellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Yarın Geliyor',
                    style: TextStyle(color: yellow, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Orta Kısım: Rota Görseli
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLocationInfo(from, "Çıkış"),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Divider(color: Colors.grey.withOpacity(0.2), thickness: 1.5),
                        Icon(Icons.chevron_right_rounded, color: yellow, size: 24),
                      ],
                    ),
                  ),
                ),
                _buildLocationInfo(to, "Varış"),
              ],
            ),

            const SizedBox(height: 25),

            // Alt Kısım: İlerleme Çubuğu ve Yüzde
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sevkiyat Durumu', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                    Text(
                      '%${(progress * 100).toInt()}',
                      style: TextStyle(color: yellow, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(yellow),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Rota detayları için yardımcı küçük widget
  Widget _buildLocationInfo(String city, String label) {
    return Column(
      crossAxisAlignment: city == "Varış" ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          city,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildBottomNav(Color yellow) {
    return BottomAppBar(
      color: const Color(0xFF1F2937),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: Icon(Icons.home, color: yellow), onPressed: () {}),
          IconButton(icon: const Icon(Icons.assignment, color: Colors.grey), onPressed: () {}),
          const SizedBox(width: 40), // Floating Button için boşluk
          IconButton(icon: const Icon(Icons.account_balance_wallet, color: Colors.grey), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person, color: Colors.grey), onPressed: () {}),
        ],
      ),
    );
  }
}