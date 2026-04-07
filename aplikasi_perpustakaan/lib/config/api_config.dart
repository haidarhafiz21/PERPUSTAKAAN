class ApiConfig {
  static const String baseUrl = "http://172.20.10.3:3000/api";

  /// ================= AUTH =================
  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";

  /// ================= USERS =================
  static const String users = "$baseUrl/users";
  static const String members = "$baseUrl/users/members";
  static const String verifyFace = "$baseUrl/users/verify-face";
  static const String updateFace = "$baseUrl/users/update-face";
  static const String profile = "$baseUrl/users/profile";
  static const String searchUser = "$baseUrl/users/search";

  /// ================= BOOKS =================
  static const String books = "$baseUrl/books";
  static const String recommendedBooks = "$baseUrl/books/recommended";
  static const String booksByRack = "$baseUrl/books/by-rak";
  static const String digitalBooks = "$baseUrl/books/digital";
  static const String readBook = "$baseUrl/books/read";

  /// ================= BORROW =================
  static const String booking = "$baseUrl/borrows/booking";
  static const String scanBorrow = "$baseUrl/borrows/scan";
  static const String returnBook = "$baseUrl/borrows/return";
  static const String activeBorrows = "$baseUrl/borrows/active";
  static const String userBorrows = "$baseUrl/borrows/user";
  static const String allBorrows = "$baseUrl/borrows/all";
  static const String cekTerlambat = "$baseUrl/borrows/cek-terlambat";
  static const String cancelExpired = "$baseUrl/borrows/cancel-expired";

  /// INI PENTING UNTUK ADMIN
  static const String userBooking = "$baseUrl/borrows/user-booking";
}