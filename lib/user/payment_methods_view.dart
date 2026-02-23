import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class PaymentMethodsView extends StatefulWidget {
  const PaymentMethodsView({super.key});

  @override
  State<PaymentMethodsView> createState() => _PaymentMethodsViewState();
}

class _PaymentMethodsViewState extends State<PaymentMethodsView> {
  List<Map<String, dynamic>> paymentMethods = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userData = await FirestoreService().getUserById(user.uid);
    setState(() {
      paymentMethods = userData?.paymentMethods ?? [];
      isLoading = false;
    });
  }

  Future<void> _addPaymentMethod(Map<String, dynamic> method) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirestoreService().addUserPaymentMethod(user.uid, method);
    await _loadPaymentMethods();
  }

  Future<void> _updatePaymentMethod(int index, Map<String, dynamic> method) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirestoreService().updateUserPaymentMethod(user.uid, index, method);
    await _loadPaymentMethods();
  }

  Future<void> _deletePaymentMethod(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirestoreService().deleteUserPaymentMethod(user.uid, index);
    await _loadPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme Yöntemleri'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                return ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: Text(method['cardNumber'] ?? 'Kart'),
                  subtitle: Text(method['cardHolder'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePaymentMethod(index),
                  ),
                  onTap: () {
                    // Düzenleme dialogu açılabilir
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni kart ekleme dialogu açılabilir
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

