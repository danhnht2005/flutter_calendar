import 'dart:math';

String generateToken() {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  const length = 20;
  final random = Random(); // Khởi tạo bộ tạo số ngẫu nhiên

  // Tạo một danh sách các ký tự ngẫu nhiên và nối chúng lại thành chuỗi
  return String.fromCharCodes(
    Iterable.generate(
      length, 
      (_) => characters.codeUnitAt(random.nextInt(characters.length))
    )
  );
}