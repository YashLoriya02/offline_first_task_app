import 'package:shared_preferences/shared_preferences.dart';

class SPService {
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('x-auth-token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('x-auth-token');
    return authToken;
  }
}
