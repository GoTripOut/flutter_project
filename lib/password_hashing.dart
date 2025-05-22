import 'package:crypto/crypto.dart';
import 'dart:convert';

String hashPassword(String pw){
  var bytes = utf8.encode(pw);
  var digest = sha256.convert(bytes);
  return digest.toString();
}