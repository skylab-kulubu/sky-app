class UserService {
  static Future<Map<String, String>> getProfile() async {
    return {
      'name': 'Yakup Emin',
      'email': 'skylab@std.yildiz.edu.tr',
      'teamName': 'MOBILAB',
    };
  }
}
