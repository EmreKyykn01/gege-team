/// Hata Yönetim Utility - Uygulamada kullanılan ortak hata yönetimi fonksiyonları

/// 🛠️ Hata yönetimi ve validasyon sınıfı
class ErrorHandler {
  /// Firebase Auth hatasını türkçeleştir
  static String getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Bu e-posta adresi kayıtlı değil.';
      case 'wrong-password':
        return 'Şifre hatalı. Lütfen tekrar deneyin.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmıştır.';
      case 'email-already-in-use':
        return 'Bu e-posta zaten kullanımda. Farklı bir e-posta deneyiniz.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 8 karakter, harf ve rakam içermelidir.';
      case 'too-many-requests':
        return 'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin.';
      case 'invalid-credential':
        return 'Geçersiz kullanıcı kimliği veya şifre.';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda yapılamıyor. Lütfen daha sonra deneyin.';
      case 'account-exists-with-different-credential':
        return 'Bu e-posta başka bir hesapla ilişkili.';
      default:
        return 'Giriş/Kayıt işleminde hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  /// Firestore hatasını türkçeleştir
  static String getFirestoreErrorMessage(String message) {
    if (message.contains('permission-denied')) {
      return 'Bu işlem için yetkiniz yok.';
    } else if (message.contains('not-found')) {
      return 'Belge bulunamadı.';
    } else if (message.contains('already-exists')) {
      return 'Bu belge zaten mevcut.';
    } else if (message.contains('network')) {
      return 'İnternet bağlantısını kontrol edin.';
    } else if (message.contains('failed-precondition')) {
      return 'İstek tamamlanamadı. Lütfen daha sonra deneyin.';
    } else if (message.contains('aborted')) {
      return 'İşlem iptal edildi. Lütfen tekrar deneyin.';
    } else if (message.contains('unauthenticated')) {
      return 'Oturum süresi doldu. Lütfen tekrar giriş yapın.';
    } else if (message.contains('data-loss')) {
      return 'Veri kaybı riski. Lütfen tekrar deneyin.';
    } else if (message.contains('deadline-exceeded')) {
      return 'İstek zaman aşımına uğradı. Lütfen İnternet bağlantınızı kontrol edin.';
    }
    return 'Veritabanı işleminde hata oluştu. Lütfen tekrar deneyin.';
  }

  /// Genel Exception'ı türkçeleştir
  static String getGeneralErrorMessage(String message) {
    if (message.contains('SocketException')) {
      return 'İnternet bağlantı sorunu. Lütfen İnternet bağlantınızı kontrol edin.';
    } else if (message.contains('TimeoutException')) {
      return 'Bağlantı zaman aşımına uğradı. Lütfen daha sonra tekrar deneyin.';
    } else if (message.contains('Invalid')) {
      return 'Geçersiz veri. Lütfen bilgilerinizi kontrol edin.';
    }
    return 'Bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
  }

  /// Form validasyon hataları
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta boş bırakılamaz.';
    }

    // Basit e-posta regex pattern
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta giriniz.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş bırakılamaz.';
    }

    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Şifre en az bir rakam içermelidir.';
    }

    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Şifre en az bir harf içermelidir.';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası boş bırakılamaz.';
    }

    // Türkiye telefon numarası format: 05xx xxx xx xx
    final phoneRegex = RegExp(r'^(\+90|0)?5[0-9]{9}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Geçerli bir telefon numarası giriniz.';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad boş bırakılamaz.';
    }

    if (value.length < 2) {
      return 'Ad en az 2 karakter olmalıdır.';
    }

    if (value.length > 100) {
      return 'Ad 100 karakterden uzun olamaz.';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Adres boş bırakılamaz.';
    }

    if (value.length < 5) {
      return 'Adres çok kısa.';
    }

    return null;
  }
}

