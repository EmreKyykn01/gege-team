import 'package:flutter/material.dart';
import 'call_courier_view.dart';
class PackageDetailsView extends StatefulWidget {
  const PackageDetailsView({super.key});

  @override
  State<PackageDetailsView> createState() => _PackageDetailsViewState();
}

class _PackageDetailsViewState extends State<PackageDetailsView> {
  String selectedSize = "Küçük"; // Varsayılan seçim
  bool isFragile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Açık gri arka plan
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Paket Detayları", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Paket Boyutu Seçin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSizeCard("Küçük", "S", Icons.inventory_2_outlined),
                _buildSizeCard("Orta", "M", Icons.widgets_outlined),
                _buildSizeCard("Büyük", "L", Icons.all_out_outlined),
              ],
            ),
            const SizedBox(height: 24),
            _buildWeightInput(),
            const SizedBox(height: 16),
            _buildContentInput(),
            const SizedBox(height: 16),
            _buildFragileSwitch(),
            const SizedBox(height: 120), // Alt barın üstüne binmemesi için boşluk
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  // Boyut Seçim Kartları
  Widget _buildSizeCard(String title, String size, IconData icon) {
    bool isSelected = selectedSize == title;
    return GestureDetector(
      onTap: () => setState(() => selectedSize = title),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F7FA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF1DE9B6) : Colors.grey.shade200, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF00BFA5) : Colors.grey, size: 36),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(size, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // Ağırlık Giriş Alanı
  Widget _buildWeightInput() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: "AĞIRLIK (KG)",
          labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
          prefixIcon: Icon(Icons.scale, color: Colors.grey),
          hintText: "Örn: 2.5",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  // İçerik Açıklaması Alanı
  Widget _buildContentInput() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: const TextField(
        maxLines: 3,
        decoration: InputDecoration(
          labelText: "İÇERİK AÇIKLAMASI",
          labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: 40.0), // İkonu yukarı hizalamak için
            child: Icon(Icons.description_outlined, color: Colors.grey),
          ),
          hintText: "Paket içerisinde ne var?",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  // Hassas Paket Anahtarı (Switch)
  Widget _buildFragileSwitch() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: SwitchListTile(
        value: isFragile,
        onChanged: (val) => setState(() => isFragile = val),
        title: const Text("Hassas Paket", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Kırılabilir veya narin içerik", style: TextStyle(color: Colors.grey, fontSize: 12)),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
        ),
        activeColor: const Color(0xFF1DE9B6),
      ),
    );
  }

  // En Alttaki Fiyat ve Devam Et Butonu
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tahmini Ücret:", style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text("₺55.00", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // ARAÇ SEÇİMİ (call_courier_view.dart) EKRANINA YÖNLENDİRME
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CallCourierView()),
                );
              },
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
        ],
      ),
    );
  }
}