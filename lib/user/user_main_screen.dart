import 'package:flutter/material.dart';
import 'home.dart';
import 'package_details_view.dart';
import 'shipments_view.dart';
import 'wallet_view.dart';
import 'profile_view.dart';

class UserMainScreen extends StatefulWidget {
  final int initialIndex;

  const UserMainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeView(),        // 0 - Ana Sayfa
    ShipmentsView(),   // 1 - Gönderiler
    WalletView(),      // 2 - Cüzdan
    ProfileView(),     // 3 - Profil
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _pages[_currentIndex],

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1DE9B6),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.black, size: 32),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PackageDetailsView(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(icon: Icons.home_filled, label: "Ana Sayfa", index: 0),
              _buildTabItem(icon: Icons.inventory_2, label: "Gönderiler", index: 1),

              const SizedBox(width: 48),

              _buildTabItem(icon: Icons.account_balance_wallet, label: "Cüzdan", index: 2),
              _buildTabItem(icon: Icons.person, label: "Profil", index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;
    final Color color = isSelected ? const Color(0xFF1DE9B6) : Colors.grey.shade400;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}