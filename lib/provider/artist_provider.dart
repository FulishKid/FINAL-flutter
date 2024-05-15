import 'package:app/api/spofity_acces_token.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/spotify_service.dart';
import '../model/track.dart';

class ArtistProvider extends ChangeNotifier {
  final SpotifyService spotifyService;
  List<Track> topTracks = [];

  ArtistProvider({required this.spotifyService});

  Future<void> fetchArtistTopTracks(
      String artistId, BuildContext context) async {
    var token = await Provider.of<SpotifyAuth>(context).getStoredSpotifyToken();
    final response = await spotifyService.fetchArtistTopTracks(artistId, token);
    topTracks = (response['tracks'] as List)
        .map((trackJson) => Track.fromJson(trackJson))
        .toList();
    notifyListeners();
  }
}
