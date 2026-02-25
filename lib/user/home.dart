import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gg/user/package_details_view.dart';
import '../services/firestore_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String userName = 'Yönetici'; // Varsayılan isim

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Firestore'dan kullanıcı adını yükle ve sadece ilk ismi al
  Future<void> _loadUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc['name'] != null) {
          // Sadece ilk ismi al (boşluktan öncesini)
          String fullName = doc['name'];
          String firstName = fullName.split(' ').first;

          setState(() {
            userName = firstName;
          });
        }
      }
    } catch (e) {
      debugPrint('Kullanıcı adı yüklenirken hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildCallCourierCard(context),
              _buildActiveShipmentsHeader(),
              _buildActiveShipmentsCarousel(),
              _buildBottomActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // Üst Karşılama Bölümü (Dinamik isim ile)
  Widget _buildHeader() {
    return ListTile(
      title: const Text("Hoş geldin,", style: TextStyle(color: Colors.grey)),
      subtitle: Text("Merhaba, $userName! 👋",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
      trailing: CircleAvatar(
        backgroundColor: Colors.grey[100],
        child: const Icon(Icons.notifications_none, color: Colors.black),
      ),
    );
  }

  // 1. Arama Çubuğu (Kargom Nerede?)
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: "Kargom Nerede?",
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            suffixIcon: Icon(Icons.qr_code_scanner, color: Color(0xFF1DE9B6)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  // Turkuaz Kurye Çağır Kartı
  Widget _buildCallCourierCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1DE9B6), Color(0xFF00BFA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Kurye Çağır",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Hızlı, güvenilir ve temassız teslimat kapınızda.",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PackageDetailsView()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Hemen Başla →", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
          Icon(Icons.local_shipping, size: 80, color: Colors.white.withValues(alpha: 0.3)),
        ],
      ),
    );
  }

  // 2. Aktif Gönderiler Başlığı ve Tümünü Gör Butonu
  Widget _buildActiveShipmentsHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Aktif Gönderiler",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () {
              // Gönderiler sekmesine yönlendirme yapılabilir
            },
            child: const Text("Tümünü Gör", style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Aktif Gönderiler Carousel (Kaydırmalı Kartlar) - Dinamik Verilerle
  Widget _buildActiveShipmentsCarousel() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Kullanıcı oturumu yok", style: TextStyle(color: Colors.grey)),
      );
    }

    return StreamBuilder(
      stream: FirestoreService().getUserActiveShipments(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Aktif gönderi yok",
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final shipments = snapshot.data!;

        return CarouselSlider(
          options: CarouselOptions(
            height: 200,
            viewportFraction: 0.85,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
          ),
          items: shipments.map((shipment) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.local_shipping, size: 40, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                shipment.pickupAddress,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              const Text("→", style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                shipment.deliveryAddress,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              shipment.trackingNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(shipment.status).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _getStatusText(shipment.status),
                                style: TextStyle(
                                  color: _getStatusColor(shipment.status),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₺${shipment.price.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Durum rengini döndür
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
      case 'in_transit':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Durum metnini döndür (Türkçe)
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'BEKLEMEDE';
      case 'assigned':
        return 'ATANDI';
      case 'in_transit':
        return 'YOLDA';
      case 'delivered':
        return 'TESLİM EDİLDİ';
      case 'cancelled':
        return 'İPTAL EDİLDİ';
      default:
        return status.toUpperCase();
    }
  }

  // 3. En Alttaki Aksiyon Butonları (Paket Gönder & İşlem Geçmişi)
  Widget _buildBottomActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              title: "Paket Gönder",
              icon: Icons.inventory_2_outlined,
              iconColor: Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionCard(
              title: "İşlem Geçmişi",
              icon: Icons.history,
              iconColor: Colors.indigoAccent,
            ),
          ),
        ],
      ),
    );
  }

  // 3.1 Alt Butonların İç Tasarımı (Yardımcı Widget)
  Widget _buildActionCard({required String title, required IconData icon, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}