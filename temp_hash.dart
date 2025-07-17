import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashPassword(String password, {String? salt}) {
  final useSalt = salt ?? '1704067200000';
  final saltedPassword = password + useSalt;
  final bytes = utf8.encode(saltedPassword);
  final digest = sha256.convert(bytes);
  return '\$sha256\$' + useSalt + '\$' + digest.toString();
}

void main() {
  final hash = hashPassword('admin123');
  print('Password hash: \$hash');
}