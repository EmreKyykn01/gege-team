import 'package:flutter/material.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() => _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  bool orderUpdates = true;
  bool promotions = false;
  bool smsNotifications = true;

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
        title: const Text("Bildirim Ayarları", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSwitchTile("Sipariş Durumu", "Kargom nerede, yola çıktı mı?", orderUpdates, (val) => setState(() => orderUpdates = val)),
              const Divider(height: 1),
              _buildSwitchTile("Kampanyalar ve Fırsatlar", "İndirimlerden haberdar ol", promotions, (val) => setState(() => promotions = val)),
              const Divider(height: 1),
              _buildSwitchTile("SMS Bildirimleri", "Önemli güncellemeleri SMS ile al", smsNotifications, (val) => setState(() => smsNotifications = val)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF1DE9B6),
    );
  }
}