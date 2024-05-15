import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpotifyAuth extends ChangeNotifier {
  final clientId = 'b03bbc9378da4c09bd9f4d2008daff08';
  final clientSecret = '019c20b134c4492fa47ab43c36ccf686';

  Future<String> getSpotifyToken() async {
    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic $credentials',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final accessToken = responseData['access_token'];
      final expiresIn = responseData['expires_in']; // expires_in в секундах

      // Зберігаємо токен і час закінчення
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('spotify_access_token', accessToken);
      await prefs.setInt('spotify_token_expiry',
          DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000) as int);

      return accessToken;
    } else {
      throw Exception('Failed to get token');
    }
  }

  Future<String> getStoredSpotifyToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('spotify_access_token');
    final tokenExpiry = prefs.getInt('spotify_token_expiry');

    if (accessToken != null && tokenExpiry != null) {
      if (DateTime.now().millisecondsSinceEpoch < tokenExpiry) {
        // Токен ще дійсний
        return accessToken;
      }
    }

    // Якщо токен відсутній або закінчився, отримуємо новий
    return await getSpotifyToken();
  }
}
