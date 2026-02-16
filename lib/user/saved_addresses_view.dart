import 'package:flutter/material.dart';

class SavedAddressesView extends StatefulWidget {
  const SavedAddressesView({super.key});

  @override
  State<SavedAddressesView> createState() => _SavedAddressesViewState();
}

class _SavedAddressesViewState extends State<SavedAddressesView> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  List<Map<String, dynamic>> addresses = [
    {
      'id': '1',
      'title': 'Ev',
      'address': 'Levent Mah. Çiçek Sok. No: 12 D: 4\nBeşiktaş / İstanbul',
      'phone': '+90 555 123 4567',
      'icon': Icons.home_rounded,
      'isDefault': true,
    },
    {
      'id': '2',
      'title': 'İş',
      'address': 'Maslak Mah. Meydan Sok. Plaza Kat: 5\nSarıyer / İstanbul',
      'phone': '+90 555 987 6543',
      'icon': Icons.work_rounded,
      'isDefault': false,
    },
  ];

  // Premium Popup göster
  void _showPremiumDialog(String title, Widget content) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
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
                    const SizedBox(height: 24),
                    // İçerik
                    content,
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Adres ekleme dialog'u
  void _showAddAddressDialog() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();

    _showPremiumDialog(
      '📍 Yeni Adres Ekle',
      Column(
        children: [
          _buildTextField(
            controller: _nameController,
            hint: 'Adres Adı (Ev, İş, vb.)',
            icon: Icons.label_outline,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            hint: 'Sokak, No, Mahalle',
            icon: Icons.location_on_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            hint: 'Telefon Numarası',
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  'İptal',
                  Colors.grey[300]!,
                  Colors.grey[700]!,
                  () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildButton(
                  'Ekle',
                  const Color(0xFF12D6C5),
                  Colors.white,
                  () {
                    if (_nameController.text.isNotEmpty &&
                        _addressController.text.isNotEmpty) {
                      setState(() {
                        addresses.add({
                          'id': DateTime.now().toString(),
                          'title': _nameController.text,
                          'address': _addressController.text,
                          'phone': _phoneController.text,
                          'icon': Icons.location_on_rounded,
                          'isDefault': false,
                        });
                      });
                      Navigator.pop(context);
                      _showSuccessPopup('Adres başarıyla eklendi!');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Adres güncelleme dialog'u
  void _showEditAddressDialog(int index) {
    _nameController.text = addresses[index]['title'];
    _addressController.text = addresses[index]['address'];
    _phoneController.text = addresses[index]['phone'];

    _showPremiumDialog(
      '✏️ Adresi Güncelle',
      Column(
        children: [
          _buildTextField(
            controller: _nameController,
            hint: 'Adres Adı',
            icon: Icons.label_outline,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            hint: 'Sokak, No, Mahalle',
            icon: Icons.location_on_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            hint: 'Telefon Numarası',
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  'İptal',
                  Colors.grey[300]!,
                  Colors.grey[700]!,
                  () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildButton(
                  'Güncelle',
                  const Color(0xFF12D6C5),
                  Colors.white,
                  () {
                    setState(() {
                      addresses[index]['title'] = _nameController.text;
                      addresses[index]['address'] = _addressController.text;
                      addresses[index]['phone'] = _phoneController.text;
                    });
                    Navigator.pop(context);
                    _showSuccessPopup('Adres başarıyla güncellendi!');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Adres silme dialog'u
  void _showDeleteAddressDialog(int index) {
    _showPremiumDialog(
      '⚠️ Adresi Sil',
      Column(
        children: [
          const Text(
            'Bu adresi silmek istediğinizden emin misiniz?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  'İptal',
                  Colors.grey[300]!,
                  Colors.grey[700]!,
                  () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildButton(
                  'Sil',
                  Colors.red[400]!,
                  Colors.white,
                  () {
                    setState(() {
                      addresses.removeAt(index);
                    });
                    Navigator.pop(context);
                    _showSuccessPopup('Adres silindi!');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Başarı popup'ı
  void _showSuccessPopup(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
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
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 36,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
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
      body: addresses.isEmpty
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
          color: address['isDefault'] ? const Color(0xFF12D6C5) : Colors.transparent,
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
            child: Icon(address['icon'], color: const Color(0xFF00BFA5), size: 24),
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
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20, color: Color(0xFF12D6C5)),
                    SizedBox(width: 12),
                    Text('Düzenle'),
                  ],
                ),
                onTap: () => _showEditAddressDialog(index),
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Sil'),
                  ],
                ),
                onTap: () => _showDeleteAddressDialog(index),
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