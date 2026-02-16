import 'package:flutter/material.dart';
import 'shipments_view.dart';
import 'user_main_screen.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  int _selectedPaymentMethod = 0; // 0: Kredi Kartı, 1: Cüzdan

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
          _buildSummaryRow("Teslimat Ücreti", "₺45.00"),
          const SizedBox(height: 8),
          _buildSummaryRow("Hizmet Bedeli", "₺4.50"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Toplam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("₺49.50", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF00BFA5))),
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
          onPressed: () {
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: 'Sipariş Popup',
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) {
                return Center(
                  child: Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1DE9B6).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(18),
                            child: const Icon(Icons.check_circle, color: Color(0xFF00BFA5), size: 48),
                          ),
                          const SizedBox(height: 24),
                          const Text("Siparişiniz başarıyla oluşturuldu!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 12),
                          const Text("Siparişiniz alınmıştır. Takip ve güncellemeler için gönderiler ekranını kullanabilirsiniz.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Dialog kapanır

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const UserMainScreen(initialIndex: 1), // Gönderiler sekmesi
                                  ),
                                      (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00BFA5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Tamam",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A1A), // Siyah şık buton
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.lock_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text("₺49.50 Öde", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}