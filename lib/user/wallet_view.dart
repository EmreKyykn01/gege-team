import 'package:flutter/material.dart';

class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Menüdeyiz, geri butonuna gerek yok
        title: const Text("Cüzdanım", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 32),
            const Text("Son İşlemler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  // Üstteki Ana Bakiye Kartı
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1DE9B6), Color(0xFF00BFA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00BFA5).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Toplam Bakiye", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
          const SizedBox(height: 8),
          const Text("₺ 120.50", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Bakiye yükleme ekranı eklenebilir
                  },
                  icon: const Icon(Icons.add, color: Colors.black, size: 18),
                  label: const Text("Bakiye Yükle", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Hızlı İşlem Butonları (Para Gönder, Kartlarım vb.)
  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionIcon(Icons.send_rounded, "Para Gönder", const Color(0xFFE3F2FD), Colors.blue),
        _buildActionIcon(Icons.credit_card, "Kartlarım", const Color(0xFFF3E5F5), Colors.purple),
        _buildActionIcon(Icons.receipt_long, "Faturalar", const Color(0xFFFFF3E0), Colors.orange),
        _buildActionIcon(Icons.more_horiz, "Diğer", Colors.grey.shade200, Colors.black54),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, String label, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // Son İşlemler Listesi
  Widget _buildTransactionsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildTransactionItem(
            title: "Kurye Ödemesi",
            date: "Bugün, 14:35",
            amount: "- ₺49.50",
            isIncome: false,
            icon: Icons.local_shipping,
            iconColor: Colors.orange,
          ),
          const Divider(height: 24),
          _buildTransactionItem(
            title: "Bakiye Yükleme",
            date: "12 Şubat, 10:15",
            amount: "+ ₺100.00",
            isIncome: true,
            icon: Icons.account_balance_wallet,
            iconColor: const Color(0xFF00BFA5),
          ),
          const Divider(height: 24),
          _buildTransactionItem(
            title: "Kurye Ödemesi",
            date: "10 Şubat, 09:30",
            amount: "- ₺85.00",
            isIncome: false,
            icon: Icons.local_shipping,
            iconColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String date,
    required String amount,
    required bool isIncome,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isIncome ? const Color(0xFF00BFA5) : Colors.black87,
          ),
        ),
      ],
    );
  }
}