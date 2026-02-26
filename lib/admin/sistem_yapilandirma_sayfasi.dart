import 'package:flutter/material.dart';

class SistemYapilandirmaSayfasi extends StatefulWidget {
  const SistemYapilandirmaSayfasi({super.key});

  @override
  State<SistemYapilandirmaSayfasi> createState() => _SistemYapilandirmaSayfasiState();
}

class _SistemYapilandirmaSayfasiState extends State<SistemYapilandirmaSayfasi> {
  // Değerler
  double acilisUcreti = 45.00;
  double kmUcreti = 12.50;
  bool geceTarifesi = true;
  double siparisLimiti = 3;
  double teslimatYaricapi = 10;
  bool pazarKapali = true;

  final Color primaryColor = const Color(0xFF00E5E5);

  @override
  Widget build(BuildContext context) {
    // Senin ana temandaki Brightness kontrolü
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Arka plan senin ana rengin
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context, isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Fiyatlandırma ---
            _sectionLabel("FİYATLANDIRMA (KM BAZLI)"),
            _buildGegeCard(
              isDark: isDark,
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildInputBox("AÇILIŞ ÜCRETİ", "₺ 45.00", isDark),
                      const SizedBox(width: 15),
                      _buildInputBox("KM BAŞI ÜCRET", "₺ 12.50", isDark),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSwitchRow("Gece Tarifesi", "22:00 - 06:00 arası %25 ek ücret", geceTarifesi, isDark, (v) => setState(() => geceTarifesi = v)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Çalışma Saatleri ---
            _sectionLabel("ÇALIŞMA SAATLERİ"),
            _buildGegeCard(
              isDark: isDark,
              child: Column(
                children: [
                  _buildTimeRow("Hafta İçi", "08:00 AM", "11:00 PM", isDark),
                  const SizedBox(height: 15),
                  _buildTimeRow("Cumartesi", "09:00 AM", "10:00 PM", isDark),
                  const SizedBox(height: 15),
                  _buildPazarRow(isDark),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Kurye Limitleri ---
            _sectionLabel("KURYE LİMİTLERİ"),
            _buildGegeCard(
              isDark: isDark,
              child: Column(
                children: [
                  _buildSliderItem("Eş Zamanlı Sipariş", "${siparisLimiti.toInt()} Sipariş", siparisLimiti, 1, 10, isDark, (v) => setState(() => siparisLimiti = v)),
                  const SizedBox(height: 25),
                  _buildSliderItem("Teslimat Yarıçapı", "${teslimatYaricapi.toInt()} KM", teslimatYaricapi, 1, 50, isDark, (v) => setState(() => teslimatYaricapi = v)),
                ],
              ),
            ),

            const SizedBox(height: 25),
            _buildInfoNote(isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Gege Temalı AppBar ---
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Operasyonel Ayarlar", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 18)),
              const Text("SİSTEM YAPILANDIRMASI", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(backgroundColor: primaryColor.withOpacity(0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text("Kaydet", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900)),
          ),
        )
      ],
    );
  }

  // --- Gege Temalı Beyaz Kart ---
  Widget _buildGegeCard({required Widget child, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: child,
    );
  }

  Widget _buildInputBox(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Container(
            height: 50,
            decoration: BoxDecoration(color: isDark ? Colors.black26 : const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(15)),
            child: Center(child: Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900))),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String t, String s, bool v, bool isDark, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          Text(s, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ]),
        Switch.adaptive(value: v, onChanged: onChanged, activeColor: primaryColor),
      ],
    );
  }

  Widget _buildTimeRow(String day, String s, String e, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: TextStyle(color: isDark ? Colors.white : Colors.black54, fontWeight: FontWeight.w600)),
        Row(
          children: [
            _timeBadge(s, isDark),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("-", style: TextStyle(color: Colors.grey))),
            _timeBadge(e, isDark),
          ],
        )
      ],
    );
  }

  Widget _timeBadge(String t, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: isDark ? Colors.black26 : const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(12)),
      child: Text(t, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildPazarRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Pazar", style: TextStyle(color: Colors.grey)),
        const Text("KAPALI", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildSliderItem(String t, String valStr, double val, double min, double max, bool isDark, Function(double) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(t, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900)),
            Text(valStr, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 13)),
          ],
        ),
        Slider(value: val, min: min, max: max, activeColor: primaryColor, inactiveColor: isDark ? Colors.white10 : Colors.black12, onChanged: onChanged),
      ],
    );
  }

  Widget _buildInfoNote(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          const Expanded(child: Text("Ayarlar İstanbul bölgesi için geçerlidir.", style: TextStyle(color: Colors.grey, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }
}