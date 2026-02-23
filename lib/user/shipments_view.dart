import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shipment_model.dart';
import '../services/firestore_service.dart';
import 'live_tracking_view.dart';

class ShipmentsView extends StatefulWidget {
  const ShipmentsView({super.key});

  @override
  State<ShipmentsView> createState() => _ShipmentsViewState();
}

class _ShipmentsViewState extends State<ShipmentsView> {
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
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

  // AKTIF GÖNDERILER - Real-time Firestore'dan
  Widget _buildActiveShipmentsTab(BuildContext context) {
    return StreamBuilder<List<ShipmentModel>>(
      stream: FirestoreService().getUserActiveShipments(_currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final shipments = snapshot.data ?? [];

        if (shipments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Aktif kargo yok', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: shipments.length,
          itemBuilder: (context, index) {
            final shipment = shipments[index];
            return _buildShipmentCard(context, shipment);
          },
        );
      },
    );
  }

  // GEÇMİŞ İŞLEMLER - Delivered/Cancelled
  Widget _buildPastShipmentsTab(BuildContext context) {
    return StreamBuilder<List<ShipmentModel>>(
      stream: FirestoreService().getUserAllShipments(_currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final allShipments = snapshot.data ?? [];
        final pastShipments = allShipments
            .where((s) => s.status == 'delivered' || s.status == 'cancelled')
            .toList();

        if (pastShipments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Geçmiş işlem yok', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pastShipments.length,
          itemBuilder: (context, index) {
            final shipment = pastShipments[index];
            return _buildShipmentCard(context, shipment);
          },
        );
      },
    );
  }

  // KARGO KARTI - Dinamik
  Widget _buildShipmentCard(BuildContext context, ShipmentModel shipment) {
    Color statusColor = _getStatusColor(shipment.status);

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
      child: GestureDetector(
        onTap: () {
          if (shipment.status == 'in_transit') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LiveTrackingView(shipment: shipment)),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst: ID ve Durum
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(shipment.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    shipment.statusInTurkish,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tarih
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey, size: 14),
                const SizedBox(width: 6),
                Text(
                  _formatDate(shipment.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),

            // Adres: Nereden → Nereye
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nereden', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(shipment.pickupAddress, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.arrow_forward, color: Colors.grey[400], size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nereye', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(shipment.deliveryAddress, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // İlerleme Çubuğu
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: shipment.progressPercentage,
                minHeight: 6,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 12),

            // Alt: Fiyat ve Harita Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₺${shipment.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (shipment.status == 'in_transit')
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LiveTrackingView(shipment: shipment)),
                      );
                    },
                    icon: const Icon(Icons.location_on_outlined),
                    label: const Text('Takip Et'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Yardımcı: Durum Rengini Belirle
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'in_transit':
        return const Color(0xFF1DE9B6);
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Yardımcı: Tarihi Formatla
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Dün, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day} ${_getMonthName(date.month)}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  // Yardımcı: Ay Adını Türkçeleştir
  String _getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }
}
