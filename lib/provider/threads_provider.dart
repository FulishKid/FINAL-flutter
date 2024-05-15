import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/bb_api.dart';
import '../model/thread.dart';

class ThreadsProvider extends ChangeNotifier {
  final MyAPIService apiService;
  List<Thread> threads = [];

  ThreadsProvider({required this.apiService});

  Future<void> fetchThreadsBySpotifyArtistId(
      String token, String spotifyArtistId) async {
    final response =
        await apiService.fetchThreadsBySpotifyArtistId(token, spotifyArtistId);
    threads = (response as List).map((threadJson) {
      return Thread.fromJson(
          threadJson); // Переконайтеся, що конструктор `fromJson` налаштовано правильно
    }).toList();

    // Сортування тредів за рейтингом у спадаючому порядку
    threads.sort((a, b) => b.rating.compareTo(a.rating));

    notifyListeners();
  }

  Future<void> changeThreadRating({
    required bool isLiked,
    required String token,
    required int threadId,
  }) async {
    String voteType = isLiked ? 'up' : 'down';

    await apiService.addVote(token, threadId, voteType);
    notifyListeners();
  }

  Future<void> deleteThread({required String token, required threadId}) async {
    await apiService.deleteThread(token, threadId);
    notifyListeners();
  }

  Future<void> addThread(
      {required String content,
      required BuildContext context,
      required String token,
      required String spotifyArtistId,
      required String artistName,
      required int rating,
      required String title}) async {
    var apiService = Provider.of<MyAPIService>(context, listen: false);

    notifyListeners();

    await apiService.createThread(
        token, title, content, spotifyArtistId, artistName);
  }
}
