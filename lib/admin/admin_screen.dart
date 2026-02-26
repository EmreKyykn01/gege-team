import 'package:flutter/material.dart';
import 'package:gg/main.dart'; // main.dart içinde themeNotifier tanımlı olmalı
import 'kurye_ekran.dart';
import 'canli_takip.dart';
import 'musteri_ekran.dart';
import 'ayarlar_ekran.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      _GenelBakisIcerik(isDark: isDark),
      const KuryeEkran(),
      const CanliTakipEkran(),
      const MusteriEkran(),
      const AyarlarEkran(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00E5E5),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Genel"),
          BottomNavigationBarItem(icon: Icon(Icons.moped), label: "Kuryeler"),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "Canlı"),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "Müşteri"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Ayarlar"),
        ],
      ),
    );
  }
}

class _GenelBakisIcerik extends StatelessWidget {
  final bool isDark;
  const _GenelBakisIcerik({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 25),
            _buildStatCard(
                "Toplam Günlük Teslimat", "1,284", "+12%", Icons.inventory_2_outlined),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildSmallCard("Aktif Kurye", "86", Icons.moped, Colors.blue),
                const SizedBox(width: 15),
                _buildSmallCard("Günlük Gelir", "₺14.2k",
                    Icons.account_balance_wallet, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF00E5E5),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.grid_view_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(
          "Gege Admin",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            themeNotifier.value =
            isDark ? ThemeMode.light : ThemeMode.dark;
          },
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode_outlined,
            color: isDark ? Colors.amber : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String val, String trend, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Toplam Günlük Teslimat",
                  style: TextStyle(color: Colors.grey)),
              Text(
                val,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          Icon(icon, color: const Color(0xFF00E5E5), size: 40),
        ],
      ),
    );
  }

  Widget _buildSmallCard(
      String title, String val, IconData icon, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Icon(icon, color: col),
            const SizedBox(height: 8),
            Text(title,
                style:
                const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              val,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}