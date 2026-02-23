import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shipment_model.dart';
import '../services/firestore_service.dart';
import '../utils/error_handler.dart';
import 'user_main_screen.dart';

class PaymentView extends StatefulWidget {
  final String pickupAddress;
  final String deliveryAddress;
  final String description;
  final double weight;
  final String size;
  final bool isFragile;
  final String vehicleType;
  final double vehiclePrice;

  const PaymentView({
    super.key,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.description,
    required this.weight,
    required this.size,
    required this.isFragile,
    required this.vehicleType,
    required this.vehiclePrice,
  });

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  int _selectedPaymentMethod = 0;
  bool _isProcessing = false;

  // Kargo oluşturma fonksiyonu
  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showErrorDialog('Hata', 'Oturum açmış değilsiniz');
        setState(() => _isProcessing = false);
        return;
      }

      // Eşsiz takip numarası otomatik oluşturulacak
      final shipment = ShipmentModel(
        id: '', // Firestore auto-generate
        senderId: currentUser.uid,
        courierId: null,
        recipientName: 'Alıcı', // TODO: Formdan al
        recipientPhone: '05301234567', // TODO: Formdan al
        pickupAddress: widget.pickupAddress,
        deliveryAddress: widget.deliveryAddress,
        status: 'pending',
        price: widget.vehiclePrice,
        description: widget.description,
        weight: widget.weight,
        createdAt: DateTime.now(),
        // trackingNumber otomatik oluşturulacak
      );

      // Firestore'a kaydet
      final shipmentId = await FirestoreService().createShipment(shipment);

      // Firestore'dan takip numarasını al
      final savedShipment = await FirestoreService().getShipmentById(shipmentId);

      setState(() => _isProcessing = false);

      // Başarılı mesajı
      _showSuccessDialog(
        'Başarılı!',
        'Kargonuz oluşturuldu.\nTakip No: ${savedShipment?.trackingNumber ?? "GE-XXXXX"}\n\nAraç: ${widget.vehicleType}',
      );

      // 2 saniye sonra ana ekrana dön
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const UserMainScreen(initialIndex: 1)),
          (route) => false,
        );
      }
    } on FirebaseException catch (e) {
      setState(() => _isProcessing = false);
      final msg = ErrorHandler.getFirestoreErrorMessage(e.message ?? '');
      _showErrorDialog('Veritabanı Hatası', msg);
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorDialog('Hata', ErrorHandler.getGeneralErrorMessage(e.toString()));
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam', style: TextStyle(color: Color(0xFF1DE9B6))),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam', style: TextStyle(color: Color(0xFF1DE9B6))),
          ),
        ],
      ),
    );
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
        title: const Text("Ödeme", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(),
            const SizedBox(height: 24),
            const Text("Ödeme Yöntemi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPaymentOptions(),
            const SizedBox(height: 24),
            // Sadece kredi kartı seçiliyse kart bilgilerini göster
            if (_selectedPaymentMethod == 0) _buildCreditCardForm(),
            const SizedBox(height: 100), // Alt bar için boşluk
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  // Sipariş Özeti Kartı
  Widget _buildOrderSummary() {
    final serviceFee = widget.vehiclePrice * 0.1; // %10 hizmet bedeli
    final total = widget.vehiclePrice + serviceFee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sipariş Özeti", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),

          // Araç Tipi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Araç Tipi", style: TextStyle(color: Colors.grey)),
              Text(widget.vehicleType, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),

          // Teslimat Ücreti
          _buildSummaryRow("Teslimat Ücreti", "₺${widget.vehiclePrice.toStringAsFixed(2)}"),
          const SizedBox(height: 8),

          // Hizmet Bedeli
          _buildSummaryRow("Hizmet Bedeli", "₺${serviceFee.toStringAsFixed(2)}"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),

          // Toplam
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Toplam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("₺${total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF00BFA5))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  // Ödeme Seçenekleri (Kart veya Cüzdan)
  Widget _buildPaymentOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildPaymentMethodCard(
            index: 0,
            title: "Kredi Kartı",
            icon: Icons.credit_card,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPaymentMethodCard(
            index: 1,
            title: "Cüzdan",
            icon: Icons.account_balance_wallet,
            subtitle: "Bakiye: ₺120.00",
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({required int index, required String title, required IconData icon, String? subtitle}) {
    bool isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F7FA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF1DE9B6) : Colors.grey.shade200, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF00BFA5) : Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ]
          ],
        ),
      ),
    );
  }

  // Kredi Kartı Bilgi Formu
  Widget _buildCreditCardForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Kart Bilgileri", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildTextField("Kart Numarası", "0000 0000 0000 0000", Icons.credit_card),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField("Son Kul. (AA/YY)", "MM/YY", null)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField("CVV", "123", null)),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField("Kart Üzerindeki İsim", "Ad Soyad", Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData? icon) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  // Onayla ve Öde Butonu
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            disabledBackgroundColor: Colors.grey[400],
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "₺${(widget.vehiclePrice * 1.1).toStringAsFixed(2)} Öde",
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}