import 'package:flutter/material.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

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
        title: const Text("Yardım ve Destek", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: _buildContactCard(Icons.chat_bubble_outline, "Canlı Destek", const Color(0xFF1DE9B6))),
              const SizedBox(width: 16),
              Expanded(child: _buildContactCard(Icons.email_outlined, "Bize Yazın", Colors.blueAccent)),
            ],
          ),
          const SizedBox(height: 32),
          const Text("Sıkça Sorulan Sorular", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFaqItem("Kurye çağırdıktan sonra iptal edebilir miyim?", "Evet, kurye yola çıkmadan önce ücretsiz iptal edebilirsiniz."),
          _buildFaqItem("Gönderim ücretleri nasıl hesaplanıyor?", "Ücretler, seçtiğiniz araç tipine ve mesafeye göre sistem tarafından otomatik hesaplanır."),
          _buildFaqItem("Hangi saatlerde hizmet veriyorsunuz?", "Şu an için 08:00 - 22:00 saatleri arasında kesintisiz hizmet vermekteyiz."),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        iconColor: const Color(0xFF00BFA5),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: const TextStyle(color: Colors.grey, height: 1.5)),
          ),
        ],
      ),
    );
  }
}