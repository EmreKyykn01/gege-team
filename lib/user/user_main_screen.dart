import 'package:flutter/material.dart';
import 'home.dart';
import 'package_details_view.dart';
import 'shipments_view.dart';
import 'wallet_view.dart';
import 'profile_view.dart';
class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _currentIndex = 0;

  // Alt menüden tıklanacak sayfaların listesi
  // Şimdilik diğer sayfalar boş, onları da sırayla yapacağız.
  final List<Widget> _pages = [
    const HomeView(), // 0. İndeks: Ana Sayfa
    const ShipmentsView(),   // 1. İndeks: Gönderiler
    const WalletView(),      // 2. İndeks: Cüzdan
    const ProfileView(),     // 3. İndeks: Profil (BURASI EKLENDİ)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // Seçili olan sayfayı gövdede gösteriyoruz
      body: _pages[_currentIndex],

      // Ortadaki (+) Butonu
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1DE9B6),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.black, size: 32),
        onPressed: () {
          // Ortadaki artıya basılınca direkt Paket Detayları'na (Kurye Çağırma akışına) yönlendir
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PackageDetailsView()),
          );
        },
      ),
      // Butonu alt barın tam ortasına oturtur
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Alt Navigasyon Barı
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(icon: Icons.home_filled, label: "Ana Sayfa", index: 0),
              _buildTabItem(icon: Icons.inventory_2, label: "Gönderiler", index: 1),

              const SizedBox(width: 48), // Ortadaki (+) butonu için boşluk bırakıyoruz

              _buildTabItem(icon: Icons.account_balance_wallet, label: "Cüzdan", index: 2),
              _buildTabItem(icon: Icons.person, label: "Profil", index: 3),
            ],
          ),
        ),
      ),
    );
  }

  // İkon ve Yazı Tasarımını Oluşturan Yardımcı Widget
  Widget _buildTabItem({required IconData icon, required String label, required int index}) {
    bool isSelected = _currentIndex == index;
    Color color = isSelected ? const Color(0xFF1DE9B6) : Colors.grey.shade400;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
              label,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              )
          ),
        ],
      ),
    );
  }
}