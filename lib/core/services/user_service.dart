import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const _keyEmail = 'user_email';

  static Future<Map<String, String>> getProfile() async {
    return {
      'name': 'Yakup Emin',
      'email': 'skylab@std.yildiz.edu.tr',
      'teamName': 'MOBILAB',
    };
  }
}