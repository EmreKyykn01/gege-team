import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../models/shipment_model.dart';

class LiveTrackingView extends StatefulWidget {
  final ShipmentModel shipment;

  const LiveTrackingView({super.key, required this.shipment});

  @override
  State<LiveTrackingView> createState() => _LiveTrackingViewState();
}

class _LiveTrackingViewState extends State<LiveTrackingView> {
  final Completer<GoogleMapController> _controller = Completer();

  late CameraPosition _initialPosition;
  final Set<Marker> _markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    // İlk konum pickup address'ten başla (örnek koordinat)
    _initialPosition = CameraPosition(
      target: const LatLng(40.9631, 29.0825), // Kadıköy
      zoom: 14.5,
    );
    _setMarkers();
  }

  void _setMarkers() {
    setState(() {
      // Pickup (Başlangıç)
      _markers.add(
        Marker(
          markerId: const MarkerId("pickup"),
          position: const LatLng(40.8021, 29.4370), // Gebze
          infoWindow: InfoWindow(title: "Kargo: ${widget.shipment.pickupAddress}"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      // Delivery (Hedef)
      _markers.add(
        Marker(
          markerId: const MarkerId("delivery"),
          position: const LatLng(40.9631, 29.0825), // Kadıköy
          infoWindow: InfoWindow(title: "Teslimat: ${widget.shipment.deliveryAddress}"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Courier (Kurye konumu - şu anda ortada)
      _markers.add(
        Marker(
          markerId: const MarkerId("courier"),
          position: const LatLng(40.8826, 29.2596), // Arası
          infoWindow: const InfoWindow(title: "Kurye Konumu"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Canlı Takip", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            onMapCreated: (controller) {
              _controller.complete(controller);
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // Alt panel: Kargo ve Kurye Bilgileri
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kargo ID ve Durum
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.shipment.id,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DE9B6).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.shipment.statusInTurkish,
                          style: const TextStyle(color: Color(0xFF1DE9B6), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pickup - Delivery
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nereden', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(
                              widget.shipment.pickupAddress,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.arrow_forward, color: Colors.grey),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nereye', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(
                              widget.shipment.deliveryAddress,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // İlerleme
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: widget.shipment.progressPercentage,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1DE9B6)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}