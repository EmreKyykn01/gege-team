import 'package:flutter/material.dart';
import 'call_courier_view.dart';

class PackageDetailsView extends StatefulWidget {
  const PackageDetailsView({super.key});

  @override
  State<PackageDetailsView> createState() => _PackageDetailsViewState();
}

class _PackageDetailsViewState extends State<PackageDetailsView> {
  // Form Controllers
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();

  String selectedSize = "Küçük";
  bool isFragile = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _deliveryController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
            // Nereden - Nereye
            const Text("Kargo Yolculuğu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildAddressField("Nereden", "Çıkış noktası", Icons.location_on, _pickupController),
            const SizedBox(height: 12),
            _buildAddressField("Nereye", "Varış noktası", Icons.location_on_outlined, _deliveryController),
            const SizedBox(height: 24),

            // Paket Boyutu
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

            // Ağırlık
            _buildWeightInput(),
            const SizedBox(height: 16),

            // Açıklama
            _buildContentInput(),
            const SizedBox(height: 16),

            // Hassas Paket
            _buildFragileSwitch(),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  // NEREDEN / NEREYE ADRES ALANLARI
  Widget _buildAddressField(String label, String hint, IconData icon, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  // BOYUT KARTLARI
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

  // AĞIRLIK ALANI
  Widget _buildWeightInput() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        controller: _weightController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  // İÇERİK AÇIKLAMASI
  Widget _buildContentInput() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        controller: _descriptionController,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: "İÇERİK AÇIKLAMASI",
          labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: 40.0),
            child: Icon(Icons.description_outlined, color: Colors.grey),
          ),
          hintText: "Paket içerisinde ne var?",
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  // HASSAS PAKET
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

  // DEVAM ET BUTONU
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
              onPressed: _validateAndContinue,
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

  // VALIDASYON VE NAVİGASYON
  void _validateAndContinue() {
    if (_pickupController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen çıkış noktasını girin')),
      );
      return;
    }
    if (_deliveryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen varış noktasını girin')),
      );
      return;
    }
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen paket açıklaması girin')),
      );
      return;
    }

    // Verileri Call Courier View'e gönder
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallCourierView(
          pickupAddress: _pickupController.text,
          deliveryAddress: _deliveryController.text,
          description: _descriptionController.text,
          weight: double.tryParse(_weightController.text) ?? 1.0,
          size: selectedSize,
          isFragile: isFragile,
        ),
      ),
    );
  }
}