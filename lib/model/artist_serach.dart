import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/spotify_service.dart';
import '../api/spofity_acces_token.dart';

class SearchModel with ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  List<Artist> artists = [];
  bool isLoading = false;

  Future<void> searchArtists(String query, BuildContext context) async {
    isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    SpotifyAuth spotifyAuth = Provider.of<SpotifyAuth>(context, listen: false);
    final token = await spotifyAuth.getStoredSpotifyToken();
    final spotifyService = SpotifyService();

    try {
      final artistsResult = await spotifyService.searchArtists(query, token);
      artists = artistsResult;
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      print(e);
    }
  }
}
