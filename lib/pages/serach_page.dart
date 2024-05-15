// ignore_for_file: prefer_const_constructors

import 'package:app/api/spotify_service.dart';
import 'package:app/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../model/artist.dart';
import '../model/artist_serach.dart';

class SearchPage extends StatefulWidget {
  final String initialQuery;

  const SearchPage({super.key, required this.initialQuery});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    if (widget.initialQuery.isNotEmpty) {
      Provider.of<SearchModel>(context, listen: false)
          .searchArtists(widget.initialQuery, context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Search Artists'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Consumer<SearchModel>(
                builder: (context, searchModel, child) => TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search for an artist...',
                  ),
                  onChanged: (query) {
                    if (query.isNotEmpty) {
                      searchModel.searchArtists(query, context);
                    } else {
                      searchModel.artists = [];
                      searchModel.notifyListeners();
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              Consumer<SearchModel>(
                builder: (context, searchModel, child) => searchModel.isLoading
                    ? const CircularProgressIndicator()
                    : Expanded(
                        child: ListView.builder(
                          itemCount: searchModel.artists.length,
                          itemBuilder: (context, index) {
                            final artist = searchModel.artists[index];
                            return Consumer<ArtistState>(
                              builder: (context, artistStateValue, child) =>
                                  GestureDetector(
                                onTap: () {
                                  String artistId = artist.id;
                                  String artistImgUrl = artist.imageUrl;

                                  artistStateValue.setArtistId(artistId);
                                  artistStateValue
                                      .setartistImgUrl(artistImgUrl);
                                  artistStateValue.setArtistName(artist.name);

                                  context.go('/home/search/artist', extra: {
                                    'artistId': artistStateValue.artistId,
                                    'artistImgUrl':
                                        artistStateValue.artistImgUrl,
                                    'name': artistStateValue.artistName
                                  });
                                },
                                child: Card(
                                  shape: BeveledRectangleBorder(),
                                  margin: EdgeInsets.all(1),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(12),
                                    leading: artist.imageUrl != null &&
                                            artist.imageUrl.isNotEmpty
                                        ? Image.network(
                                            artist.imageUrl,
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 50,
                                          )
                                        : SizedBox(
                                            width: 50,
                                            height: 50,
                                          ),
                                    title: Text(artist.name),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar());
  }
}
