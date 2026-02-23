/// 📦 Firestore Kargo Modeli
/// Bu model Firestore'daki 'shipments' koleksiyonunun yapısını tanımlar

import 'package:cloud_firestore/cloud_firestore.dart';

class ShipmentModel {
  final String id;
  final String senderId;
  final String? courierId;
  final String recipientName;
  final String recipientPhone;
  final String pickupAddress;
  final String deliveryAddress;
  final String status;
  final double price;
  final String description;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final double? weight;
  final String trackingNumber;
  final List<String>? imageUrls;

  ShipmentModel({
    required this.id,
    required this.senderId,
    this.courierId,
    required this.recipientName,
    required this.recipientPhone,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.status,
    required this.price,
    required this.description,
    required this.createdAt,
    this.deliveredAt,
    this.weight,
    String? trackingNumber,
    this.imageUrls,
  }) : trackingNumber = trackingNumber ?? _generateTrackingNumber();

  /// Eşsiz 10 karakterli takip numarası oluştur
  static String _generateTrackingNumber() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String result = 'GE-';

    for (int i = 0; i < 7; i++) {
      result += chars[(random + i) % chars.length];
    }

    return result;
  }

  /// Firestore belgesinden ShipmentModel oluştur
  factory ShipmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShipmentModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      courierId: data['courierId'],
      recipientName: data['recipientName'] ?? 'Alıcı Adı',
      recipientPhone: data['recipientPhone'] ?? '',
      pickupAddress: data['pickupAddress'] ?? '',
      deliveryAddress: data['deliveryAddress'] ?? '',
      status: data['status'] ?? 'pending',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
      weight: (data['weight'] as num?)?.toDouble(),
      trackingNumber: data['trackingNumber'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  /// ShipmentModel'ı Map'e dönüştür (Firestore için)
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'courierId': courierId,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'pickupAddress': pickupAddress,
      'deliveryAddress': deliveryAddress,
      'status': status,
      'price': price,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'weight': weight,
      'trackingNumber': trackingNumber,
      'imageUrls': imageUrls ?? [],
    };
  }

  /// ShipmentModel'ı kopyala
  ShipmentModel copyWith({
    String? id,
    String? senderId,
    String? courierId,
    String? recipientName,
    String? recipientPhone,
    String? pickupAddress,
    String? deliveryAddress,
    String? status,
    double? price,
    String? description,
    DateTime? createdAt,
    DateTime? deliveredAt,
    double? weight,
    String? trackingNumber,
    List<String>? imageUrls,
  }) {
    return ShipmentModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      courierId: courierId ?? this.courierId,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      price: price ?? this.price,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      weight: weight ?? this.weight,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  /// Kargo durumunun türkçe metni
  String get statusInTurkish {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'assigned':
        return 'Kurye Atandı';
      case 'in_transit':
        return 'Kurye Yolda';
      case 'delivered':
        return 'Teslim Edildi';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return 'Bilinmiyor';
    }
  }

  /// İlerleme yüzdesini döndür (0.0 - 1.0)
  double get progressPercentage {
    switch (status) {
      case 'pending':
        return 0.0;
      case 'assigned':
        return 0.33;
      case 'in_transit':
        return 0.66;
      case 'delivered':
        return 1.0;
      case 'cancelled':
        return 0.0;
      default:
        return 0.0;
    }
  }
}

