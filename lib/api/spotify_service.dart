import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  Future<List<Artist>> searchArtists(String query, String token) async {
    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/search?q=$query&type=artist&limit=10'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print(json.decode(response.body));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final artistsJson = data['artists']['items'] as List;
      print(artistsJson);
      return artistsJson.map((json) => Artist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load artists');
    }
  }

  Future<Map<String, dynamic>> fetchArtistTopTracks(
      String artistId, String token) async {
    const String baseUrl = 'https://api.spotify.com/v1';
    final response = await http.get(
      Uri.parse('$baseUrl/artists/$artistId/top-tracks?market=US'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load top tracks');
    }
  }
}

class Artist {
  final String id;
  final String name;
  final String imageUrl;

  Artist({required this.id, required this.name, required this.imageUrl});

  factory Artist.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List;
    final imageUrl = images.isNotEmpty ? images[0]['url'] : '';
    return Artist(
      id: json['id'], // Додавання id
      name: json['name'],
      imageUrl: imageUrl,
    );
  }
}
