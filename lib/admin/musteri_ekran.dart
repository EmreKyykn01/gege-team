import 'package:flutter/material.dart';

class MusteriEkran extends StatefulWidget {
  const MusteriEkran({super.key});

  @override
  State<MusteriEkran> createState() => _MusteriEkranState();
}

class _MusteriEkranState extends State<MusteriEkran> {
  final List<Map<String, dynamic>> musteriler = [
    {"name": "Burak Yılmaz", "orders": "42 Sipariş", "status": "VIP", "img": "11"},
    {"name": "Ayşe Demir", "orders": "12 Sipariş", "status": "Yeni", "img": "12"},
    {"name": "Murat Kaya", "orders": "28 Sipariş", "status": "Sadık", "img": "13"},
    {"name": "Selin Yıldız", "orders": "85 Sipariş", "status": "VIP", "img": "14"},
  ];

  @override
  Widget build(BuildContext context) {
    // Tema kontrolü
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 10),
          _buildSearchField(isDark),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: musteriler.length,
              itemBuilder: (context, index) {
                final m = musteriler[index];
                return _musteriCard(m['name'], m['orders'], m['status'], m['img'], isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5E5),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: const Color(0xFF00E5E5).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.people_outline, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Müşteri Listesi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const Text("MÜŞTERİ YÖNETİMİ",
                  style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: TextField(
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: "Müşteri ismi veya telefon ara...",
            hintStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF00E5E5) : Colors.grey),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: isDark ? BorderSide(color: Colors.white.withOpacity(0.1)) : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: isDark ? BorderSide(color: Colors.white.withOpacity(0.1)) : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _musteriCard(String name, String orders, String status, String imgId, bool isDark) {
    Color statusColor = status == "VIP" ? Colors.purple : (status == "Yeni" ? Colors.blue : Colors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E26) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.05)) : null,
        boxShadow: [
          BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8)
          )
        ],
      ),
      child: Row(
        children: [
          // Müşteri Avatarı
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [const Color(0xFF00E5E5), statusColor]),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
              child: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$imgId"),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 14, color: isDark ? Colors.grey : Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(orders, style: TextStyle(color: isDark ? Colors.grey : Colors.grey[700], fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    shadows: isDark ? [Shadow(color: statusColor, blurRadius: 8)] : [],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Icon(Icons.more_vert_rounded, color: isDark ? Colors.grey[700] : Colors.grey[300]),
            ],
          ),
        ],
      ),
    );
  }
}