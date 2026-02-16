import 'package:flutter/material.dart';
import 'live_tracking_view.dart'; // LiveTrackingView için import eklendi

class ShipmentsView extends StatelessWidget {
  const ShipmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController ile üstte iki sekme (Aktif / Geçmiş) oluşturuyoruz
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // Sol üstteki geri butonunu gizler (Menüde olduğumuz için)
          title: const Text("Gönderilerim", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Color(0xFF1DE9B6),
            labelColor: Color(0xFF00BFA5),
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Aktif Gönderiler"),
              Tab(text: "Geçmiş İşlemler"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveShipmentsTab(context),
            _buildPastShipmentsTab(context),
          ],
        ),
      ),
    );
  }

  // 1. Sekme: Aktif Gönderiler
  Widget _buildActiveShipmentsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildShipmentCard(
          context: context,
          id: "#GE-88421",
          status: "Kurye Yolda",
          statusColor: const Color(0xFF1DE9B6),
          date: "Bugün, 14:30",
          from: "Levent, Beşiktaş",
          to: "Caddebostan, Kadıköy",
          isActive: true,
        ),
        // Birden fazla aktif sipariş varsa buraya eklenebilir
      ],
    );
  }

  // 2. Sekme: Geçmiş İşlemler
  Widget _buildPastShipmentsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildShipmentCard(
          context: context,
          id: "#GE-88400",
          status: "Teslim Edildi",
          statusColor: Colors.grey.shade600,
          date: "Dün, 09:15",
          from: "Maslak, Sarıyer",
          to: "Şişli Merkez",
          isActive: false,
        ),
        _buildShipmentCard(
          context: context,
          id: "#GE-88392",
          status: "İptal Edildi",
          statusColor: Colors.redAccent,
          date: "12 Şubat, 16:45",
          from: "Kavacık, Beykoz",
          to: "Ümraniye",
          isActive: false,
        ),
      ],
    );
  }

  // Gönderi Kartı Tasarımı
  Widget _buildShipmentCard({
    required BuildContext context,
    required String id,
    required String status,
    required Color statusColor,
    required String date,
    required String from,
    required String to,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Kısım: ID ve Durum
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Orta Kısım: Tarih ve Adresler
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.grey, size: 14),
              const SizedBox(width: 6),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),

          // Adres Bilgileri (Nereden - Nereye)
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, color: Color(0xFF1DE9B6), size: 12),
                  Container(height: 20, width: 2, color: Colors.grey.shade300),
                  const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(from, style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 18), // Çizgi ile hizalamak için boşluk
                    Text(to, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            ],
          ),

          // Sadece Aktif siparişlerde "Canlı Takip" butonu görünsün
          if (isActive) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LiveTrackingView()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00BFA5),
                  side: const BorderSide(color: Color(0xFF1DE9B6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Canlı Takip Et"),
              ),
            )
          ]
        ],
      ),
    );
  }
}