import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class LiveTrackingView extends StatefulWidget {
  const LiveTrackingView({super.key});

  @override
  State<LiveTrackingView> createState() => _LiveTrackingViewState();
}

class _LiveTrackingViewState extends State<LiveTrackingView> {
  final Completer<GoogleMapController> _controller = Completer();

  // Kuryenin başlangıç konumu (Gebze)
  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(40.8021, 29.4370), // Gebze
    zoom: 14.5,
  );

  // Harita üzerindeki pinler
  final Set<Marker> _markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    _setMarkers();
  }

  void _setMarkers() {
    setState(() {
      // Kurye Pini (Gebze)
      _markers.add(
        Marker(
          markerId: const MarkerId("courier"),
          position: const LatLng(40.8021, 29.4370), // Gebze
          infoWindow: const InfoWindow(title: "Kurye Konumu"),
        ),
      );
      // Teslimat Noktası Pini (örnek: Kadıköy)
      _markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: const LatLng(40.9631, 29.0825), // Kadıköy
          infoWindow: const InfoWindow(title: "Teslimat Noktası"),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Harita Katmanı
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationButtonEnabled: false, // Kendi konum butonunu gizler
            zoomControlsEnabled: false, // Ekrandaki + / - butonlarını gizler
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          // 2. Üst Geri Butonu (Harita üzerinde yüzen buton)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 24,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                  onPressed: () => Navigator.pop(context), // Ana menüye veya ödemeye döner
                ),
              ),
            ),
          ),

          // 3. Alt Kurye Bilgi Kartı
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCourierCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildCourierCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Üstteki küçük gri çubuk
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 20),

          // Durum ve Tahmini Süre
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Kurye Yolda", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF1DE9B6).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text("15 dk", style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Kurye Profil Bilgileri
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFF8F9FA),
                backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/512/3135/3135715.png"), // Temsili kurye resmi
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Ahmet Yılmaz", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        const Text("4.9", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text("• 34 ABC 123", style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),

              // Arama Butonu
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.call, color: Colors.black),
                  onPressed: () {
                    // TODO: Telefon araması tetiklenecek
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Mesajlaşma Butonu
              Container(
                decoration: BoxDecoration(color: const Color(0xFF1DE9B6), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  onPressed: () {
                    // TODO: Sohbet ekranı açılacak
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Alt boşluk
        ],
      ),
    );
  }
}