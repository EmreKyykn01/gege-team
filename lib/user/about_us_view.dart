import 'package:flutter/material.dart';

class AboutUsView extends StatefulWidget {
  const AboutUsView({super.key});

  @override
  State<AboutUsView> createState() => _AboutUsViewState();
}

class _AboutUsViewState extends State<AboutUsView> {
  // Premium Popup göster
  void _showPremiumDialog(String title, String content) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(28),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF12D6C5).withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // İçerik
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Kapat Butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF12D6C5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Tamam',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
        title: const Text("Hakkımızda", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo ve App Adı
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF12D6C5).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping,
                size: 48,
                color: Color(0xFF00BFA5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'GEGE',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gelirken Getir',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Versiyon 1.0.0',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 40),

            // Bilgiler
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.business_rounded, 'Şirket', 'GEGE Lojistik A.Ş.'),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.language_rounded, 'Web Sitesi', 'www.gege.com.tr'),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.mail_rounded, 'Email', 'info@gege.com.tr'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hukuki Bölüm
            const Text(
              'Hukuki',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            _buildListTile(
              'Kullanıcı Sözleşmesi',
              Icons.description_outlined,
              () => _showPremiumDialog(
                '📋 Kullanıcı Sözleşmesi',
                'GEGE Lojistik hizmetlerini kullanarak, aşağıdaki şartları kabul etmiş sayılırsınız:\n\n'
                    '• Bu platform yalnızca yasal amaçlar için kullanılabilir\n'
                    '• Kargo bilgilerinin gizliliği en üst düzeyde korunur\n'
                    '• Hizmet kullanıcıları tüm sorumlulukları kabul eder\n'
                    '• GEGE, hizmet kalitesini geliştirmek için en iyi çabayı gösterir\n'
                    '• Anlaşmazlıklarda Türkiye mahkemeleri yetkilidir\n\n'
                    'Son güncelleme: Şubat 2026',
              ),
            ),
            const SizedBox(height: 8),
            _buildListTile(
              'Gizlilik Politikası',
              Icons.privacy_tip_outlined,
              () => _showPremiumDialog(
                '🔒 Gizlilik Politikası',
                'GEGE, kullanıcı gizliliğine önem verir:\n\n'
                    '• Kişisel veriler yalnızca hizmet sunumu için kullanılır\n'
                    '• Verileriniz üçüncü taraflarla paylaşılmaz\n'
                    '• Şifreleriniz güvenli veri tabanlarında saklanır\n'
                    '• İstediğiniz zaman verilerinizi sildirebilirsiniz\n'
                    '• Çerezler ve izleme teknolojileri kullanılabilir\n'
                    '• GDPR ve yerel yasalara uyum gösterilir\n\n'
                    'Son güncelleme: Şubat 2026',
              ),
            ),
            const SizedBox(height: 8),
            _buildListTile(
              'Açık Kaynak Lisansları',
              Icons.code_rounded,
              () => _showPremiumDialog(
                '📝 Açık Kaynak Lisansları',
                'GEGE, aşağıdaki açık kaynak kütüphaneleri kullanmaktadır:\n\n'
                    '• Flutter - BSD License\n'
                    '• Firebase - Google License\n'
                    '• Google Maps Flutter - BSD License\n'
                    '• Carousel Slider - MIT License\n\n'
                    'Bu projeler orijinal sahibi/lisans sahipleri tarafından yazılmış olup, sorumluluğu orijinal geliştiricilere aittir.',
              ),
            ),
            const SizedBox(height: 32),

            // Sosyal Medya
            const Text(
              'Bize Takip Edin',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(Icons.facebook_rounded, Colors.blue),
                const SizedBox(width: 12),
                _buildSocialButton(Icons.tiktok_rounded, Colors.black),
                const SizedBox(width: 12),
                _buildSocialButton(Icons.language, Colors.orange),
                const SizedBox(width: 12),
                _buildSocialButton(Icons.mail_rounded, Colors.red),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF12D6C5).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF00BFA5), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF12D6C5).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF00BFA5), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}