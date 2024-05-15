import 'package:flutter/material.dart';

class ArtistState extends ChangeNotifier {
  String artistId = '';
  String artistImgUrl = '';
  String artistName = '';

  setArtistId(String currentArtistId) {
    artistId = currentArtistId;
    // notifyListeners();
  }

  setartistImgUrl(String currentartistImgUrl) {
    artistImgUrl = currentartistImgUrl;
  }

  setArtistName(String currentArtistName) {
    artistName = currentArtistName;
  }
}
