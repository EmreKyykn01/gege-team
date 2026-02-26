import 'package:flutter/material.dart';

class KuryeEkran extends StatefulWidget {
  const KuryeEkran({super.key});

  @override
  State<KuryeEkran> createState() => _KuryeEkranState();
}

class _KuryeEkranState extends State<KuryeEkran> {
  List<Map<String, dynamic>> kuryeler = [
    {"name": "Ahmet Yılmaz", "status": "Aktif", "rating": "4.9", "img": "1"},
    {"name": "Mehmet Demir", "status": "Meşgul", "rating": "4.7", "img": "2"},
    {"name": "Selin Aksoy", "status": "İnaktif", "rating": "5.0", "img": "3"},
    {"name": "Caner Öz", "status": "Aktif", "rating": "4.5", "img": "4"},
  ];

  void _updateKuryeStatus(int index, String newStatus) {
    setState(() => kuryeler[index]['status'] = newStatus);
  }

  @override
  Widget build(BuildContext context) {
    // 1. ADIM: Tema durumunu yakala
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: kuryeler.length,
              itemBuilder: (context, index) {
                final kurye = kuryeler[index];
                return _kuryeCard(index, kurye['name'], kurye['status'], kurye['rating'], kurye['img'], isDark);
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
                BoxShadow(
                  color: const Color(0xFF00E5E5).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: const Icon(Icons.moped, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Kurye Yönetimi",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87
                  )),
              const Text("PERSONEL DURUMU",
                  style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kuryeCard(int index, String name, String status, String rating, String imgId, bool isDark) {
    Color statusColor = status == "Aktif" ? Colors.green : (status == "Meşgul" ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // Karanlıkta derin gri, aydınlıkta saf beyaz
        color: isDark ? const Color(0xFF1E1E26) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.05), width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          // Avatar kısmı neon bir çerçeve ile
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00E5E5).withOpacity(0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$imgId"),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87
                    )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          // MESAJ BUTONU - Karanlıkta parlar
          IconButton(
            onPressed: () => _showChatDialog(name, isDark),
            icon: Icon(Icons.chat_bubble_rounded,
              color: const Color(0xFF00E5E5),
              size: 24,
              shadows: isDark ? [const Shadow(color: Color(0xFF00E5E5), blurRadius: 10)] : [],
            ),
          ),
          const SizedBox(width: 5),
          // DURUM BUTONU
          GestureDetector(
            onTap: () => _showStatusPicker(index, isDark),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
              ),
              child: Text(status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(int index, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("Durum Güncelle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 20),
            ...["Aktif", "Meşgul", "İnaktif"].map((s) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              leading: CircleAvatar(
                  backgroundColor: s == "Aktif" ? Colors.green : (s == "Meşgul" ? Colors.orange : Colors.red),
                  radius: 8
              ),
              title: Text(s, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
              onTap: () { _updateKuryeStatus(index, s); Navigator.pop(context); },
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _showChatDialog(String name, bool isDark) {
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1E1E26) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: Text("$name", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      content: TextField(
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: "Mesaj gönder...",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: isDark ? Colors.black26 : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          )
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E5E5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 8,
            shadowColor: const Color(0xFF00E5E5).withOpacity(0.4),
          ),
          child: const Text("Gönder", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        )
      ],
    ));
  }
}