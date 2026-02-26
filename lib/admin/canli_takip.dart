import 'package:flutter/material.dart';
import 'dart:ui'; // Blur efekti için lazım

class CanliTakipEkran extends StatelessWidget {
  const CanliTakipEkran({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema kontrolü
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. ARKA PLAN: HARİTA (Dark Mode'da hafif karartılmış)
          _buildMapBackground(isDark),

          // 2. ÜST BAR
          _buildTopBar(context, isDark),

          // 3. HARİTA ÜZERİNDEKİ KURYE BALONCUĞU
          _buildCourierMarker(
            top: 350,
            left: 100,
            name: "AHMET YILMAZ",
            speed: "42 km/h",
            location: "Beşiktaş",
            isDark: isDark,
          ),

          // 4. ALT KART: AKTİF OPERASYON ÖZETİ
          _buildOperationSummaryCard(isDark),
        ],
      ),
    );
  }

  Widget _buildMapBackground(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ColorFiltered(
        // Karanlık modda haritayı biraz daha "gece haritası" havasına sokar
        colorFilter: isDark
            ? ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)
            : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
        child: Image.network(
          "https://miro.medium.com/v2/resize:fit:1400/1*q3_S673V6S_vYV_9IeA97Q.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Blur efektli başlık barı
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios, size: 18, color: isDark ? Colors.white : Colors.black),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Canlı Takip",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                        Row(
                          children: [
                            const CircleAvatar(backgroundColor: Colors.red, radius: 3),
                            const SizedBox(width: 5),
                            const Text("CANLI OPERASYON",
                                style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Filtre Butonu (Neon parlamalı)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1D21) : const Color(0xFFE0FBFB),
              shape: BoxShape.circle,
              boxShadow: isDark ? [BoxShadow(color: const Color(0xFF00E5E5).withOpacity(0.2), blurRadius: 10)] : [],
            ),
            child: const Icon(Icons.tune, color: Color(0xFF00E5E5)),
          ),
        ],
      ),
    );
  }

  Widget _buildCourierMarker({required double top, required double left, required String name, required String speed, required String location, required bool isDark}) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E26) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              border: isDark ? Border.all(color: const Color(0xFF00E5E5).withOpacity(0.3)) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Color(0xFF00E5E5), fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.speed, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(speed, style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black87)),
                    const SizedBox(width: 8),
                    const Icon(Icons.navigation, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(location, style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black87)),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_drop_down, color: isDark ? const Color(0xFF1E1E26) : Colors.white, size: 30),
          // Kurye İkonu (Neon)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5E5),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF00E5E5).withOpacity(0.5), blurRadius: 15)],
            ),
            child: const Icon(Icons.moped, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationSummaryCard(bool isDark) {
    return Positioned(
      bottom: 20,
      left: 15,
      right: 15,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16181D).withOpacity(0.85) : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black12),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.analytics_outlined, color: Color(0xFF00E5E5)),
                        const SizedBox(width: 10),
                        Text("Aktif Operasyon Özeti",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                      ],
                    ),
                    const Text("ŞİMDİ", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildSummaryItem("YOLDAKİ", "82", "^4", isDark ? Colors.black26 : const Color(0xFFE0FBFB), isDark),
                    const SizedBox(width: 15),
                    _buildSummaryItem("BEKLEYEN", "24", "⌛", isDark ? Colors.black26 : Colors.grey.shade100, isDark),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Avatar grubu
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: Stack(
                        children: List.generate(3, (index) => Positioned(
                          left: index * 20.0,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
                            child: CircleAvatar(
                              radius: 13,
                              backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=a$index"),
                            ),
                          ),
                        ))..add(Positioned(left: 60, child: const CircleAvatar(radius: 15, backgroundColor: Color(0xFF00E5E5), child: Text("+78", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))))),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Row(
                        children: [
                          Text("Detayları Gör", style: TextStyle(color: Color(0xFF00E5E5), fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_forward_ios, color: Color(0xFF00E5E5), size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String val, String trend, Color bgColor, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(22),
          border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(width: 5),
                Text(trend, style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}