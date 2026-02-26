import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:local_auth/local_auth.dart';

class CourierScreen extends StatefulWidget {
  const CourierScreen({super.key});

  @override
  State<CourierScreen> createState() => _CourierScreenState();
}

class _CourierScreenState extends State<CourierScreen> {
  // ──────────── Değişkenler ────────────
  final LocalAuthentication auth = LocalAuthentication();
  bool _isBiometricEnabled = false;

  int _currentIndex = 0;
  bool _isOnline = true;
  bool _isDarkMode = true;
  bool _isLoading = true;

  // ──────────── Dinamik Renk Paleti ────────────
  Color get bgColor => _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
  Color get cardColor => _isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  Color get textColor => _isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get subTextColor => _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  static const Color tealAccent = Color(0xFF2DD4BF);
  static const Color tealDark = Color(0xFF0D9488);

  @override
  void initState() {
    super.initState();
    _updateStatusBar();
    _simulateDataLoading();
  }

  void _simulateDataLoading() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isLoading = false);
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _updateStatusBar();
    });
  }

  void _updateStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: bgColor,
      systemNavigationBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
    ));
  }

  // ──────────── Biyometrik Doğrulama (FaceID / Parmak İzi) ────────────
  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      try {
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Güvenliği aktifleştirmek için yüzünüzü okutun',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (didAuthenticate) {
          setState(() => _isBiometricEnabled = true);
          _showStatusPopup('Başarılı', 'Biyometrik güvenlik aktifleştirildi!', success: true);
        }
      } catch (e) {
        _showStatusPopup('Hata', 'Cihazda biyometrik donanım bulunamadı veya ayarlanmamış.', success: false);
      }
    } else {
      setState(() => _isBiometricEnabled = false);
    }
  }

  // ──────────── Lottie Destekli Popup ────────────
  Future<void> _showStatusPopup(String title, String message, {required bool success}) async {
    if (!mounted) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 120,
                    child: success
                        ? Lottie.network('https://lottie.host/82df0fa0-7170-43f1-a1e4-3d8b139edcd5/f0s4gq7gXq.json', repeat: false)
                        : Lottie.network('https://lottie.host/9f506240-a19d-4054-9dbb-8b9f1d07c08a/gIeN9G3qJw.json', repeat: false),
                  ),
                  const SizedBox(height: 10),
                  Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center, style: TextStyle(color: subTextColor, fontSize: 15, height: 1.5)),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, __, child) {
        return ScaleTransition(scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack), child: child);
      },
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _showStatusPopup('Güle Güle!', 'Oturum kapatıldı.', success: true);
    } catch (e) {
      _showStatusPopup('Hata', 'Hata: $e', success: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: bgColor, body: _buildShimmerLoading(), bottomNavigationBar: _buildBottomNav());
    }

    final pages = [_buildHomePage(), _buildDeliveryPage(), _buildWalletPage(), _buildProfilePage()];

    return Scaffold(backgroundColor: bgColor, body: pages[_currentIndex], bottomNavigationBar: _buildBottomNav());
  }

  // ╔══════════════════════════════════════════════════════════════╗
  // ║                       SHIMMER YÜKLEME EKRANI                 ║
  // ╚══════════════════════════════════════════════════════════════╝
  Widget _buildShimmerLoading() {
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: _isDarkMode ? const Color(0xFF1E293B) : Colors.grey[300]!,
        highlightColor: _isDarkMode ? const Color(0xFF334155) : Colors.grey[100]!,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 60, height: 10, color: Colors.white), const SizedBox(height: 6), Container(width: 120, height: 15, color: Colors.white)]),
                ],
              ),
              const SizedBox(height: 24),
              Container(width: double.infinity, height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
              const SizedBox(height: 24),
              Container(width: double.infinity, height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
            ],
          ),
        ),
      ),
    );
  }

  // ╔══════════════════════════════════════════════════════════════╗
  // ║                       ANA SAYFA (HOME)                       ║
  // ╚══════════════════════════════════════════════════════════════╝
  Widget _buildHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                _buildCircleButton(Icons.person_outline, isProfile: true),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Merhaba,', style: TextStyle(color: subTextColor, fontSize: 13)),
                    Text('Ahmet Yılmaz', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleTheme,
                  child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle), child: Icon(_isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: _isDarkMode ? Colors.amber : textColor, size: 22)),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() => _isOnline = !_isOnline),
                  child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(30)), child: Row(children: [_buildToggleChip('OFF', !_isOnline), _buildToggleChip('ON', _isOnline)])),
                ),
              ],
            ),

            // Gamification (Lig Sistemi)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _isDarkMode ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)] : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.indigoAccent.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MEVCUT LİG', style: TextStyle(color: _isDarkMode ? Colors.indigoAccent : Colors.indigo, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                          const SizedBox(height: 4),
                          Text('ELMAS Kurye 💎', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor)),
                        ],
                      ),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Text('Top %5', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
                      Container(height: 10, width: MediaQuery.of(context).size.width * 0.6, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.indigoAccent, Colors.purpleAccent]), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 10)])),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('2.450 Puan', style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w600)), Text('Sonraki: EFSANE (3.000)', style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w600))],
                  ),
                ],
              ),
            ),

            // Yeni İş Teklifi Kartı
            Container(
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping_outlined, color: tealDark, size: 22),
                        const SizedBox(width: 10),
                        Text('Yeni İş Teklifi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                        const Spacer(),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text('45sn kaldı', style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(20), height: 140, width: double.infinity,
                    decoration: BoxDecoration(color: _isDarkMode ? const Color(0xFF0F172A).withOpacity(0.5) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(20)),
                    child: Stack(
                      children: [
                        Center(child: CustomPaint(size: const Size(200, 100), painter: _RoutePainter(color: subTextColor))),
                        Positioned(left: 30, top: 60, child: Icon(Icons.circle, color: tealAccent, size: 12)),
                        Positioned(right: 60, top: 30, child: Icon(Icons.location_on, color: Colors.redAccent, size: 24)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [_buildInfoColumn('Tahmini Kazanç', '₺145,00'), _buildInfoColumn('Tahmini Süre', '22 dk', isRight: true)],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildRoutePoint(color: tealAccent, label: 'ALIM NOKTASI', address: 'Lezzet Restoran – Beşiktaş', showLine: true),
                        _buildRoutePoint(color: Colors.redAccent, label: 'TESLİMAT NOKTASI', address: 'Mecidiyeköy İş Merkezi', showLine: false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: tealAccent, foregroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                        onPressed: () => _showStatusPopup('Harika!', 'İşi başarıyla kabul ettin. Lütfen yola çık.', success: true),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('İşi Kabul Et', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), SizedBox(width: 10), Icon(Icons.arrow_forward_rounded, size: 24)]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ╔══════════════════════════════════════════════════════════════╗
  // ║                  AKTİF TESLİMAT SAYFASI                      ║
  // ╚══════════════════════════════════════════════════════════════╝
  Widget _buildDeliveryPage() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _buildCircleButton(Icons.arrow_back_rounded),
                const Spacer(),
                Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)), child: Column(children: [Text('AKTİF TESLİMAT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: tealDark, letterSpacing: 1.2)), Text('#GE-88421', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor))])),
                const Spacer(),
                _buildCircleButton(Icons.more_vert_rounded),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A3A4A), borderRadius: BorderRadius.circular(28)),
              child: Stack(children: [const Center(child: Text("HARİTA MODÜLÜ (FAZ 2)", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold))), Positioned(right: 16, top: 16, child: Column(children: [_buildMapBtn(Icons.navigation_rounded), const SizedBox(height: 10), _buildMapBtn(Icons.layers_rounded)]))]),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(color: cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)]),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 50, height: 50, decoration: BoxDecoration(gradient: const LinearGradient(colors: [tealAccent, tealDark]), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.person, color: Colors.white)),
                        const SizedBox(width: 15),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Müşteri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)), Text('Kadıköy, İstanbul', style: TextStyle(color: subTextColor, fontSize: 13))]),
                        const Spacer(),
                        _buildCircleButton(Icons.phone_rounded, color: tealAccent),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildDeliveryStep(icon: Icons.check_circle_rounded, color: tealAccent, title: 'Paket Alındı', time: '14:20', isDone: true, showLine: true),
                    _buildDeliveryStep(icon: Icons.delivery_dining_rounded, color: tealAccent, title: 'Yolda', time: 'Tahmini: 8dk', isDone: false, isActive: true, showLine: true),
                    _buildDeliveryStep(icon: Icons.location_on_rounded, color: subTextColor, title: 'Teslimat Noktası', time: '--:--', isDone: false, showLine: false),
                    const SizedBox(height: 30),

                    // KAMERA BAĞLANTISI BURADA!
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: tealAccent, foregroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const QRScannerScreen()),
                          );
                          if (result != null) {
                            _showStatusPopup('Teslimat Başarılı!', 'Okunan Barkod: $result\nPaket teslim edildi.', success: true);
                          }
                        },
                        child: const Text('TESLİMATI TAMAMLA (QR)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ╔══════════════════════════════════════════════════════════════╗
  // ║                       CÜZDAN SAYFASI                         ║
  // ╚══════════════════════════════════════════════════════════════╝
  Widget _buildWalletPage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Cüzdan', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)), _buildCircleButton(Icons.history_rounded)],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [tealAccent, tealDark], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: tealAccent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]),
              child: Column(
                children: [
                  const Text('TOPLAM BAKİYE', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2)),
                  const SizedBox(height: 10),
                  const Text('₺2.450,60', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ╔══════════════════════════════════════════════════════════════╗
  // ║                       PROFİL SAYFASI                         ║
  // ╚══════════════════════════════════════════════════════════════╝
  Widget _buildProfilePage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(width: 100, height: 100, decoration: BoxDecoration(gradient: const LinearGradient(colors: [tealAccent, tealDark]), borderRadius: BorderRadius.circular(30)), child: const Icon(Icons.person_rounded, color: Colors.white, size: 50)),
            const SizedBox(height: 16),
            Text('Ahmet Yılmaz', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Align(alignment: Alignment.centerLeft, child: Text('Ayarlar', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 15),

            _buildSettingTile(_isDarkMode ? Icons.dark_mode : Icons.light_mode, 'Karanlık Mod', _isDarkMode, (v) => _toggleTheme()),
            _buildSettingTile(Icons.notifications, 'Bildirimler', true, (v){}),
            // FACE ID / PARMAK İZİ BAĞLANTISI BURADA!
            _buildSettingTile(Icons.security, 'Face ID / Parmak İzi', _isBiometricEnabled, _toggleBiometric),

            const SizedBox(height: 30),
            TextButton(onPressed: _logout, child: const Text('Çıkış Yap', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold))),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ──────────── WIDGET YARDIMCILARI ────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(color: bgColor, border: Border(top: BorderSide(color: subTextColor.withOpacity(0.1)))),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Ana Sayfa'),
          _buildNavItem(1, Icons.local_shipping_rounded, 'İşler'),
          _buildNavItem(2, Icons.account_balance_wallet_rounded, 'Cüzdan'),
          _buildNavItem(3, Icons.person_rounded, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? tealAccent : subTextColor, size: isActive ? 26 : 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isActive ? tealAccent : subTextColor, fontSize: 11, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, {Color? color, bool isProfile = false}) {
    return Container(width: 44, height: 44, decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), boxShadow: _isDarkMode ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]), child: isProfile ? const Icon(Icons.person, color: tealAccent) : Icon(icon, color: color ?? subTextColor, size: 22));
  }

  Widget _buildToggleChip(String label, bool isActive) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: isActive ? tealAccent : Colors.transparent, borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: isActive ? const Color(0xFF0F172A) : subTextColor, fontSize: 11, fontWeight: FontWeight.bold)));
  }

  Widget _buildStatItem(String label, String value, IconData? icon) {
    return Column(children: [Row(children: [Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor)), if(icon!=null) Icon(icon, color: Colors.amber, size: 18)]), const SizedBox(height: 2), Text(label, style: TextStyle(color: subTextColor, fontSize: 12))]);
  }

  Widget _buildInfoColumn(String label, String value, {bool isRight = false}) {
    return Column(crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: subTextColor, fontSize: 12)), const SizedBox(height: 4), Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textColor))]);
  }

  Widget _buildRoutePoint({required Color color, required String label, required String address, required bool showLine}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Column(children: [Icon(Icons.circle, color: color, size: 14), if (showLine) Container(width: 2, height: 30, color: subTextColor.withOpacity(0.3))]), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(address, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor))])]);
  }

  Widget _buildDeliveryStep({required IconData icon, required Color color, required String title, required String time, required bool isDone, bool isActive = false, required bool showLine}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Column(children: [Icon(icon, color: color, size: 28), if (showLine) Container(width: 2, height: 40, color: subTextColor.withOpacity(0.2))]), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isActive || isDone ? textColor : subTextColor)), Text(time, style: TextStyle(color: subTextColor, fontSize: 13))]))]);
  }

  Widget _buildMapBtn(IconData icon) {
    return Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF0F172A)));
  }

  Widget _buildSettingTile(IconData icon, String title, bool val, Function(bool) onChanged) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)), child: Row(children: [Icon(icon, color: subTextColor), const SizedBox(width: 15), Expanded(child: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600))), Switch(value: val, onChanged: onChanged, activeColor: tealAccent)]));
  }
}

class _RoutePainter extends CustomPainter {
  final Color color;
  _RoutePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2DD4BF)..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(30, 60);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.9, size.width - 60, 40);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ──────────── QR KOD TARAYICI EKRANI ────────────
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Paket Barkodunu Tara', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          ValueListenableBuilder(
            valueListenable: cameraController,
            builder: (context, state, child) {
              final torchState = state.torchState;
              IconData iconData;
              Color iconColor;

              switch (torchState) {
                case TorchState.off:
                  iconData = Icons.flash_off;
                  iconColor = Colors.grey;
                  break;
                case TorchState.on:
                  iconData = Icons.flash_on;
                  iconColor = Colors.yellow;
                  break;
                case TorchState.auto:
                  iconData = Icons.flash_auto;
                  iconColor = Colors.yellow;
                  break;
                case TorchState.unavailable:
                default:
                  iconData = Icons.flash_off;
                  iconColor = Colors.white30;
                  break;
              }

              return IconButton(icon: Icon(iconData, color: iconColor), iconSize: 32.0, onPressed: () => cameraController.toggleTorch());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  cameraController.stop();
                  Navigator.pop(context, barcode.rawValue);
                  break;
                }
              }
            },
          ),
          Center(child: Container(width: 250, height: 250, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2DD4BF), width: 3), borderRadius: BorderRadius.circular(20))))
        ],
      ),
    );
  }
}