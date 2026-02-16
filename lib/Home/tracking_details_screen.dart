import 'package:flutter/material.dart';

class TrackingDetailsScreen extends StatelessWidget {
  const TrackingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF111827);
    const Color cardBg = Color(0xFF1F2937);
    const Color primaryYellow = Color(0xFFEAB308);

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // 1. HARİTA ALANI (Placeholder)
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://i.stack.imgur.com/HILXv.png'), // Geçici harita görseli
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                ),
              ),
            ),
          ),

          // 2. ÜST BUTONLAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleBtn(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                  const Text('Takip Detayları', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildCircleBtn(Icons.more_horiz, () {}),
                ],
              ),
            ),
          ),

          // 3. DETAY PANELİ (Draggable Sheet)
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.55,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF111827),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10)))),
                      const SizedBox(height: 25),
                      _buildShipmentStatus(primaryYellow),
                      const SizedBox(height: 30),
                      _buildCourierSection(cardBg, primaryYellow),
                      const SizedBox(height: 30),
                      const Text('Gönderi Geçmişi', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _buildTimelineItem("Teslim Edildi", "14:20", "Paketiniz adrese ulaştırıldı.", true, primaryYellow),
                      _buildTimelineItem("Dağıtıma Çıktı", "11:05", "Kurye teslimat için yola çıktı.", true, primaryYellow),
                      _buildTimelineItem("Şubeye Vardı", "08:30", "Paket yerel merkeze ulaştı.", false, primaryYellow),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildShipmentStatus(Color yellow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: yellow, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('YOLDA', style: TextStyle(color: yellow, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ],
        ),
        const Text('Bugün Geliyor', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        Text('Tahmini Varış: 16:00', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
      ],
    );
  }

  Widget _buildCourierSection(Color bg, Color yellow) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const CircleAvatar(radius: 25, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=9')),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Michael V.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Mercedes Sprinter • 34 ABC 123', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: yellow, shape: BoxShape.circle),
            child: const Icon(Icons.phone, color: Colors.black, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, String desc, bool isDone, Color yellow) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                color: isDone ? yellow : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isDone ? yellow : Colors.grey, width: 2),
              ),
            ),
            Container(width: 2, height: 50, color: Colors.grey[800]),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(color: isDone ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Text(desc, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}