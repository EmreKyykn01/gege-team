import 'package:flutter/material.dart';
import 'payment_view.dart';

class CallCourierView extends StatefulWidget {
  final String pickupAddress;
  final String deliveryAddress;
  final String description;
  final double weight;
  final String size;
  final bool isFragile;

  const CallCourierView({
    super.key,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.description,
    required this.weight,
    required this.size,
    required this.isFragile,
  });

  @override
  State<CallCourierView> createState() => _CallCourierViewState();
}

class _CallCourierViewState extends State<CallCourierView> {
  int _selectedVehicle = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Arka plandaki yumuşak turkuaz gradyan
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB2DFDB), Color(0xFFE0F2F1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 10),
                _buildLocationCard(),
                const SizedBox(height: 20),
                Expanded(child: _buildBottomContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Şeffaf AppBar
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Kurye Çağır",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 48), // Ortalama için boşluk
        ],
      ),
    );
  }

  // Nereden - Nereye Kartı
  Widget _buildLocationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İkonlar ve kesik çizgi
          Column(
            children: [
              const Icon(Icons.radio_button_checked, color: Color(0xFF1DE9B6), size: 20),
              Container(
                height: 30,
                width: 2,
                margin: const EdgeInsets.symmetric(vertical: 4),
                // Kesik çizgi görünümü için basit bir çözüm
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) => Container(width: 2, height: 3, color: Colors.grey.shade300)),
                ),
              ),
              const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
            ],
          ),
          const SizedBox(width: 16),
          // Adres Metinleri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("NEREDEN?", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(widget.pickupAddress, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                const Text("NEREYE?", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(widget.deliveryAddress, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Alt Kısımdaki Beyaz Alan (Araç Seçimi ve Buton)
  Widget _buildBottomContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DÜZELTİLMİŞ KISIM (const kelimesini Center'dan alıp BoxDecoration'a verdik)
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("Araç Tipi Seçin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Araç Listesi
          _buildVehicleOption(
            index: 0,
            title: "Motor Kurye",
            time: "12 - 18 dk",
            price: "₺45.00",
            icon: Icons.two_wheeler,
            tag: "EN HIZLI",
            tagColor: const Color(0xFF00BFA5),
          ),
          _buildVehicleOption(
            index: 1,
            title: "Araç Kurye",
            time: "25 - 35 dk",
            price: "₺85.00",
            icon: Icons.directions_car,
          ),
          _buildVehicleOption(
            index: 2,
            title: "Panelvan",
            time: "40 - 55 dk",
            price: "₺150.00",
            icon: Icons.local_shipping,
            tag: "BÜYÜK PAKET",
            tagColor: Colors.grey,
          ),

          const Spacer(),
          // Devam Et Butonu
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _goToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DE9B6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Devam Et", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.black),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Seçilebilir Araç Kartı Widget'ı
  Widget _buildVehicleOption({
    required int index,
    required String title,
    required String time,
    required String price,
    required IconData icon,
    String? tag,
    Color? tagColor,
  }) {
    bool isSelected = _selectedVehicle == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedVehicle = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1DE9B6) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // İkon Kutusu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1DE9B6) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade700, size: 28),
            ),
            const SizedBox(width: 16),
            // Başlık ve Zaman
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(time, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            // Fiyat ve Etiket (Örn: EN HIZLI)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (tag != null) ...[
                  const SizedBox(height: 4),
                  Text(tag, style: TextStyle(color: tagColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  // Ödeme ekranına git - tüm verileri gönder
  void _goToPayment() {
    String vehicleType = '';
    double price = 0;

    if (_selectedVehicle == 0) {
      vehicleType = 'Motor Kurye';
      price = 45.0;
    } else if (_selectedVehicle == 1) {
      vehicleType = 'Araç Kurye';
      price = 85.0;
    } else {
      vehicleType = 'Panelvan';
      price = 150.0;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentView(
          pickupAddress: widget.pickupAddress,
          deliveryAddress: widget.deliveryAddress,
          description: widget.description,
          weight: widget.weight,
          size: widget.size,
          isFragile: widget.isFragile,
          vehicleType: vehicleType,
          vehiclePrice: price,
        ),
      ),
    );
  }
}
