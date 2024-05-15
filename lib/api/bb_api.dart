import 'dart:convert';
import 'package:app/model/thread.dart';
import 'package:app/provider/profile_provider.dart';
import 'package:app/storage/local_storage.dart';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MyAPIService extends ChangeNotifier {
  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<List<dynamic>> fetchThreadsBySpotifyArtistId(
      String token, String spotifyArtistId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/threads/artist/$spotifyArtistId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);
    print(json.decode(response.body));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load threads');
    }
  }

  // register
  Future<String> registerUser(String username, String email, String password,
      {String? bio, List? genres}) async {
    try {
      final response =
          await http.post(Uri.parse("$baseUrl/register"), headers: {
        'Accept': 'application/json',
      }, body: {
        'username': username,
        'email': email,
        'password': password,
        'bio': bio,
        'genres': genres!.join(','),
      });

      var responseData = json.decode(response.body);
      print(responseData);

      if (responseData['statusCode'] == 201) {
        return "Email verification have been sent to your email addres";
      } else {
        if (responseData.containsKey('errors')) {
          return _buildErrorMessage(responseData);
        } else {
          throw Exception('Failed to register user');
        }
      }
    } catch (e) {
      print(e);
      return 'Error occurred: $e';
    }
  }

  // login User
  Future<String> loginUser(String email, String password, context) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {'Accept': 'application/json'},
      body: {
        'email': email,
        'password': password,
      },
    );
    var data = json.decode(response.body);
    print(data);
    if (data['statusCode'] == 200) {
      String token = "${data['token']}";

      LocalStorage localStorage =
          Provider.of<LocalStorage>(context, listen: false);

      await localStorage.saveToken(token);
      ProfileProvider(apiService: MyAPIService(), localStorage: LocalStorage());

      return data['message'];
    } else if (data['statusCode'] == 404) {
      return 'Invalid email or password. Please try again.';
    } else {
      if (data.containsKey('errors')) {
        return _buildErrorMessage(data);
      }
      return 'Invalid email or password. Please try again.';
    }
  }

  Future<String> logoutUser(context) async {
    LocalStorage localStorage =
        Provider.of<LocalStorage>(context, listen: false);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/logout"),
        headers: {
          'Authorization': 'Bearer ${await localStorage.getToken()}',
          'Accept': 'application/json',
        },
      );

      var data = json.decode(response.body);
      print(data);
      if (data['statusCode'] == 200) {
        await localStorage.clearToken();
        await localStorage.clearUserData();
        return data['message'];
      } else {
        return data['message'];
      }
    } catch (e) {
      return 'Error occurred: $e';
    }
  }

  Future<String> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'email': email,
        },
      );

      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data['message'];
      } else {
        return data['message'];
      }
    } catch (e) {
      return 'Error occurred: $e';
    }
  }
  // User Data

  Future<Map<String, dynamic>> fetchUserData(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // Profile

  Future<Map<String, dynamic>> fetchUserProfile(context) async {
    LocalStorage localStorage = Provider.of<LocalStorage>(context);

    try {
      final token = await localStorage.getToken();
      final response = await http.get(
        Uri.parse("$baseUrl/profile"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == true) {
          return {"message": data['message'], "data": data['data']};
        } else {
          return {"message": "Failed to fetch profile data", "data": {}};
        }
      } else {
        return {"message": "Error: ${response.statusCode}", "data": {}};
      }
    } catch (e) {
      return {"message": 'Error occurred: $e', "data": {}};
    }
  }

  // Threads API

  Future<int> fetchThreadRating(String token, int threadId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/threads/$threadId/rating'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);
    print(json.decode(response.body));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['rating'];
    } else {
      throw Exception('Failed to load thread rating');
    }
  }

  Future<List<dynamic>> fetchThreads(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/threads'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load threads');
    }
  }

  Future<Map<String, dynamic>> createThread(String token, String title,
      String content, String artistId, String artistName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/threads'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': title,
        'content_': content,
        'spotify_artist_id': artistId,
        'artist_name': artistName,
      }),
    );
    print(response.statusCode);

    print(json.decode(response.body));

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create thread');
    }
  }

  Future<Map<String, dynamic>> fetchThread(String token, int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/threads/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load thread');
    }
  }

  Future<Map<String, dynamic>> updateThread(
      String token, int id, String title, String content) async {
    final response = await http.put(
      Uri.parse('$baseUrl/threads/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': title,
        'content_': content,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update thread');
    }
  }

  Future<void> deleteThread(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/threads/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);
    print(json.decode(response.body));
  }

// ProfileController

  Future<Map<String, dynamic>> fetchProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print(json.decode(response.body));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<Map<String, dynamic>> updateProfile(
      String token, String bio, String favoriteGenres,
      {String? favoriteArtists}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'bio': bio,
        'favorite_genres': favoriteGenres,
        'favorite_artists': favoriteArtists,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<Map<String, dynamic>> fetchRating(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/rating'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load rating');
    }
  }

  // Comments

  Future<List<dynamic>> fetchComments(String token, int threadId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/threads/$threadId/comments'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<Map<String, dynamic>> createComment(
      String token, int threadId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/threads/$threadId/comments'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'content_': content,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create comment');
    }
  }

  Future<Map<String, dynamic>> fetchComment(String token, int commentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/comments/$commentId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load comment');
    }
  }

  Future<Map<String, dynamic>> updateComment(
      String token, int commentId, String content) async {
    final response = await http.put(
      Uri.parse('$baseUrl/comments/$commentId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'content_': content,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update comment');
    }
  }

  Future<void> deleteComment(String token, int commentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$commentId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete comment');
    }
  }

// Artist

  Future<List<dynamic>> fetchArtists(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/artists'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load artists');
    }
  }

  Future<Map<String, dynamic>> fetchArtist(String token, int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/artists/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load artist');
    }
  }

  Future<Map<String, dynamic>> createArtist(
      String token, String spotifyArtistId, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/artists'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'spotify_artist_id': spotifyArtistId,
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create artist');
    }
  }

  Future<Map<String, dynamic>> updateArtist(
      String token, int id, String name) async {
    final response = await http.put(
      Uri.parse('$baseUrl/artists/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update artist');
    }
  }

  Future<void> deleteArtist(String token, int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/artists/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete artist');
    }
  }

  //Favorite Artist

  Future<List<dynamic>> fetchFavoriteArtists(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/favorites/artists'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load favorite artists');
    }
  }

  Future<Map<String, dynamic>> addFavoriteArtist(
      String token, int artistId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites/artists'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'artist_id': artistId,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add favorite artist');
    }
  }

  Future<void> deleteFavoriteArtist(String token, int artistId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites/artists/$artistId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete favorite artist');
    }
  }

  // votes

  Future<Map<String, dynamic>> addVote(
      String token, int threadId, String voteType) async {
    final response = await http.post(
      Uri.parse('$baseUrl/threads/$threadId/votes'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'vote_type': voteType,
      }),
    );
    print(response.statusCode);
    print(json.decode(response.body));

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      return {'msg': 'somthing went wrong'};
    }
  }

  Future<void> deleteVote(String token, int voteId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/votes/$voteId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete vote');
    }
  }

  // Error Message Builder
  String _buildErrorMessage(Map<String, dynamic> responseData) {
    List<String> errorMessages = [];
    responseData['errors'].forEach((key, value) {
      errorMessages.add('${value.join(", ")}');
    });
    return errorMessages.join("\n");
  }

  String getBaseUrl() {
    if (Platform.isAndroid) {
      // Для Android емулятора
      return "http://10.0.2.2:8000/api";
    } else if (Platform.isIOS) {
      // Для iOS симулятора
      return "http://localhost:8000/api";
    } else {
      // Стандартна URL, якщо не виконується на емуляторах
      return "http://127.0.0.1:8000/api";
    }
  }
}
