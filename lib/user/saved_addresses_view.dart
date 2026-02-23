import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class SavedAddressesView extends StatefulWidget {
  const SavedAddressesView({super.key});

  @override
  State<SavedAddressesView> createState() => _SavedAddressesViewState();
}

class _SavedAddressesViewState extends State<SavedAddressesView> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  List<Map<String, dynamic>> addresses = [];
  bool isLoading = true;

  // Tema renkleri
  static const Color _primaryGreen = Color(0xFF12D6C5);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _errorColor = Color(0xFFEF4444);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userData = await FirestoreService().getUserById(user.uid);
    setState(() {
      addresses = userData?.addresses ?? [];
      isLoading = false;
    });
  }

  Future<void> _addAddress(Map<String, dynamic> address) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirestoreService().addUserAddress(user.uid, address);
    await _loadAddresses();
  }

  Future<void> _updateAddress(int index, Map<String, dynamic> address) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirestoreService().updateUserAddress(user.uid, index, address);
    await _loadAddresses();
  }

  Future<void> _deleteAddress(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirestoreService().deleteUserAddress(user.uid, index);
    await _loadAddresses();
  }

  // Modern temalı popup
  Future<void> _showThemedPopup(String title, String message, {required bool success, bool warning = false, int durationMs = 2000}) async {
    if (!mounted) return;
    final Color iconColor = success
        ? _successColor
        : warning
          ? _primaryGreen
          : _errorColor;
    final IconData icon = success
        ? Icons.check_circle_rounded
        : warning
          ? Icons.info_rounded
          : Icons.error_rounded;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
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
                    color: _primaryGreen.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 36, color: iconColor),
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: _textMuted)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    ),
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    child: const Text('Tamam', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    await Future.delayed(Duration(milliseconds: durationMs));
  }

  // Adres ekleme dialog'u
  void _showAddAddressDialog() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
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
                    color: _primaryGreen.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('📍 Yeni Adres Ekle', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _nameController, hint: 'Adres Adı (Ev, İş, vb.)', icon: Icons.label_outline),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _addressController, hint: 'Sokak, No, Mahalle', icon: Icons.location_on_outlined, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _phoneController, hint: 'Telefon Numarası', icon: Icons.phone_outlined),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton('İptal', Colors.grey[300]!, Colors.grey[700]!, () => Navigator.pop(context)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildButton('Ekle', _primaryGreen, Colors.white, () async {
                          if (_nameController.text.isNotEmpty && _addressController.text.isNotEmpty) {
                            final newAddress = {
                              'id': DateTime.now().toString(),
                              'title': _nameController.text,
                              'address': _addressController.text,
                              'phone': _phoneController.text,
                              'icon': Icons.location_on_rounded.codePoint,
                              'isDefault': false,
                            };
                            await _addAddress(newAddress);
                            Navigator.pop(context);
                            await _showThemedPopup('Başarılı', 'Adres başarıyla eklendi!', success: true);
                          } else {
                            await _showThemedPopup('Eksik Bilgi', 'Adres adı ve adres alanı zorunludur.', success: false, warning: true);
                          }
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Adres güncelleme dialog'u
  void _showEditAddressDialog(int index) {
    _nameController.text = addresses[index]['title'];
    _addressController.text = addresses[index]['address'];
    _phoneController.text = addresses[index]['phone'];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
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
                    color: _primaryGreen.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('✏️ Adresi Güncelle', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _nameController, hint: 'Adres Adı', icon: Icons.label_outline),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _addressController, hint: 'Sokak, No, Mahalle', icon: Icons.location_on_outlined, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _phoneController, hint: 'Telefon Numarası', icon: Icons.phone_outlined),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton('İptal', Colors.grey[300]!, Colors.grey[700]!, () => Navigator.pop(context)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildButton('Güncelle', _primaryGreen, Colors.white, () async {
                          final updatedAddress = {
                            'id': addresses[index]['id'],
                            'title': _nameController.text,
                            'address': _addressController.text,
                            'phone': _phoneController.text,
                            'icon': Icons.location_on_rounded.codePoint,
                            'isDefault': addresses[index]['isDefault'] ?? false,
                          };
                          await _updateAddress(index, updatedAddress);
                          Navigator.pop(context);
                          await _showThemedPopup('Başarılı', 'Adres başarıyla güncellendi!', success: true);
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Adres silme dialog'u
  void _showDeleteAddressDialog(int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
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
                    color: _primaryGreen.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚠️ Adresi Sil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark)),
                  const SizedBox(height: 16),
                  const Text('Bu adresi silmek istediğinizden emin misiniz?', textAlign: TextAlign.center, style: TextStyle(color: _textMuted, fontSize: 14, height: 1.5)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton('İptal', Colors.grey[300]!, Colors.grey[700]!, () => Navigator.pop(context)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildButton('Sil', Colors.red[400]!, Colors.white, () async {
                          await _deleteAddress(index);
                          Navigator.pop(context);
                          await _showThemedPopup('Başarılı', 'Adres silindi!', success: true);
                        }),
                      ),
                    ],
                  ),
                ],
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
        title: const Text("Kayıtlı Adreslerim", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_rounded, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Henüz adres eklenmemiş', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildAddressCard(index, address),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAddressDialog,
        backgroundColor: const Color(0xFF12D6C5),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Yeni Adres Ekle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAddressCard(int index, Map<String, dynamic> address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address['isDefault'] == true ? const Color(0xFF12D6C5) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF12D6C5).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(IconData(address['icon'], fontFamily: 'MaterialIcons'), color: const Color(0xFF00BFA5), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(address['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (address['isDefault'])
                      const Text("Varsayılan", style: TextStyle(color: Color(0xFF00BFA5), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(address['address'], style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
                const SizedBox(height: 6),
                Text(address['phone'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditAddressDialog(index);
              } else if (value == 'delete') {
                _showDeleteAddressDialog(index);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: const Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20, color: Color(0xFF12D6C5)),
                    SizedBox(width: 12),
                    Text('Düzenle'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Sil'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert, color: Colors.grey, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        prefixIcon: Icon(icon, color: const Color(0xFF12D6C5), size: 20),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF12D6C5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }

  Widget _buildButton(String text, Color bgColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}