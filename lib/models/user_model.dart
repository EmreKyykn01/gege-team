/// 👤 Firestore Kullanıcı Modeli
/// Bu model Firestore'daki 'users' koleksiyonunun yapısını tanımlar

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role; // 'user', 'courier', 'admin'
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool isActive;
  final List<Map<String, dynamic>>? addresses;
  final List<Map<String, dynamic>>? paymentMethods;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
    this.isActive = true,
    this.addresses,
    this.paymentMethods,
  });

  /// Firestore belgesinden UserModel oluştur
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? 'İsimsiz Kullanıcı',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'user',
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      addresses: (data['addresses'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      paymentMethods: (data['paymentMethods'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  /// UserModel'ı Map'e dönüştür (Firestore için)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'addresses': addresses,
      'paymentMethods': paymentMethods,
    };
  }

  /// UserModel'ı kopyala ve bazı alanları değiştir
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? isActive,
    List<Map<String, dynamic>>? addresses,
    List<Map<String, dynamic>>? paymentMethods,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}
