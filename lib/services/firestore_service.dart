/// 🔥 Firestore Servis
/// Tüm Firestore işlemlerini merkezi bir yerde yönet

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/shipment_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== USER OPERATIONS ====================

  /// Yeni kullanıcı kaydını Firestore'a ekle
  Future<void> createUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Kullanıcı oluşturulamadı: $e');
    }
  }

  /// Kullanıcı bilgilerini getir
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Kullanıcı bilgisi alınamadı: $e');
    }
  }

  /// Mevcut kullanıcının bilgilerini getir
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;
    return getUserById(currentUser.uid);
  }

  /// Kullanıcı bilgilerini güncelle
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Kullanıcı güncellenemedi: $e');
    }
  }

  /// Kullanıcının profilini güncelle
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    String? profileImageUrl,
  }) async {
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (phone != null) updateData['phone'] = phone;
    if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;

    if (updateData.isEmpty) return;

    await updateUser(uid, updateData);
  }

  /// Kullanıcıya adres ekle
  Future<void> addUserAddress(String uid, Map<String, dynamic> address) async {
    final userRef = _db.collection('users').doc(uid);
    await userRef.update({
      'addresses': FieldValue.arrayUnion([address])
    });
  }

  /// Kullanıcı adresini güncelle
  Future<void> updateUserAddress(String uid, int index, Map<String, dynamic> address) async {
    final userDoc = await _db.collection('users').doc(uid).get();
    if (!userDoc.exists) return;
    final data = userDoc.data() as Map<String, dynamic>;
    final addresses = (data['addresses'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
    if (index < 0 || index >= addresses.length) return;
    addresses[index] = address;
    await userDoc.reference.update({'addresses': addresses});
  }

  /// Kullanıcı adresini sil
  Future<void> deleteUserAddress(String uid, int index) async {
    final userDoc = await _db.collection('users').doc(uid).get();
    if (!userDoc.exists) return;
    final data = userDoc.data() as Map<String, dynamic>;
    final addresses = (data['addresses'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
    if (index < 0 || index >= addresses.length) return;
    addresses.removeAt(index);
    await userDoc.reference.update({'addresses': addresses});
  }

  /// Kullanıcıya ödeme yöntemi ekle
  Future<void> addUserPaymentMethod(String uid, Map<String, dynamic> method) async {
    final userRef = _db.collection('users').doc(uid);
    await userRef.update({
      'paymentMethods': FieldValue.arrayUnion([method])
    });
  }

  /// Kullanıcı ödeme yöntemini güncelle
  Future<void> updateUserPaymentMethod(String uid, int index, Map<String, dynamic> method) async {
    final userDoc = await _db.collection('users').doc(uid).get();
    if (!userDoc.exists) return;
    final data = userDoc.data() as Map<String, dynamic>;
    final methods = (data['paymentMethods'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
    if (index < 0 || index >= methods.length) return;
    methods[index] = method;
    await userDoc.reference.update({'paymentMethods': methods});
  }

  /// Kullanıcı ödeme yöntemini sil
  Future<void> deleteUserPaymentMethod(String uid, int index) async {
    final userDoc = await _db.collection('users').doc(uid).get();
    if (!userDoc.exists) return;
    final data = userDoc.data() as Map<String, dynamic>;
    final methods = (data['paymentMethods'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
    if (index < 0 || index >= methods.length) return;
    methods.removeAt(index);
    await userDoc.reference.update({'paymentMethods': methods});
  }

  // ==================== SHIPMENT OPERATIONS ====================

  /// Yeni kargo oluştur
  Future<String> createShipment(ShipmentModel shipment) async {
    try {
      final docRef = await _db.collection('shipments').add(shipment.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Kargo oluşturulamadı: $e');
    }
  }

  /// Kargo bilgisini ID ile getir
  Future<ShipmentModel?> getShipmentById(String shipmentId) async {
    try {
      final doc = await _db.collection('shipments').doc(shipmentId).get();
      if (doc.exists) {
        return ShipmentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Kargo bilgisi alınamadı: $e');
    }
  }

  /// Kargo durumunu güncelle
  Future<void> updateShipmentStatus(String shipmentId, String newStatus) async {
    try {
      final Map<String, dynamic> updateData = {'status': newStatus};
      if (newStatus == 'delivered') {
        updateData['deliveredAt'] = Timestamp.now();
      }
      await _db.collection('shipments').doc(shipmentId).update(updateData);
    } catch (e) {
      throw Exception('Kargo durumu güncellenemedi: $e');
    }
  }

  /// Kargoyu kuryeye ata
  Future<void> assignShipmentToCourier(String shipmentId, String courierId) async {
    try {
      await _db.collection('shipments').doc(shipmentId).update({
        'courierId': courierId,
        'status': 'assigned',
      });
    } catch (e) {
      throw Exception('Kargo kuryeye atanamadı: $e');
    }
  }

  /// Kullanıcının aktif kargolarını getir (stream)
  Stream<List<ShipmentModel>> getUserActiveShipments(String userId) {
    return _db
        .collection('shipments')
        .where('senderId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'assigned', 'in_transit'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShipmentModel.fromFirestore(doc))
            .toList());
  }

  /// Kullanıcının tüm kargolarını getir (stream)
  Stream<List<ShipmentModel>> getUserAllShipments(String userId) {
    return _db
        .collection('shipments')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShipmentModel.fromFirestore(doc))
            .toList());
  }

  /// Kuryenin atanan kargolarını getir (stream)
  Stream<List<ShipmentModel>> getCourierAssignedShipments(String courierId) {
    return _db
        .collection('shipments')
        .where('courierId', isEqualTo: courierId)
        .where('status', whereIn: ['assigned', 'in_transit'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShipmentModel.fromFirestore(doc))
            .toList());
  }

  /// Kargo numarasına göre ara
  Future<ShipmentModel?> searchShipmentByNumber(String trackingNumber) async {
    try {
      final querySnapshot = await _db
          .collection('shipments')
          .where('trackingNumber', isEqualTo: trackingNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ShipmentModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Kargo araması başarısız: $e');
    }
  }

  // ==================== STATISTICS ====================

  /// Admin için istatistikleri getir
  Future<Map<String, dynamic>> getAdminStatistics() async {
    try {
      final shipments = await _db.collection('shipments').get();
      final users = await _db.collection('users').get();

      final activeShipments = shipments.docs
          .where((doc) => ['pending', 'assigned', 'in_transit'].contains(doc['status']))
          .length;

      final couriers = users.docs
          .where((doc) => doc['role'] == 'courier')
          .length;

      return {
        'activeShipments': activeShipments,
        'totalShipments': shipments.docs.length,
        'totalUsers': users.docs.length,
        'totalCouriers': couriers,
      };
    } catch (e) {
      throw Exception('İstatistikler alınamadı: $e');
    }
  }

  // ==================== ERROR HANDLING ====================

  /// Firebase Exception'ı türkçeleştir
  static String getFriendlyErrorMessage(Exception e) {
    final errorString = e.toString();

    if (errorString.contains('permission-denied')) {
      return 'Bu işlem için yetkiniz yok.';
    } else if (errorString.contains('not-found')) {
      return 'Belge bulunamadı.';
    } else if (errorString.contains('already-exists')) {
      return 'Bu belge zaten mevcut.';
    } else if (errorString.contains('network')) {
      return 'Ağ bağlantısını kontrol edin.';
    }

    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }
}

