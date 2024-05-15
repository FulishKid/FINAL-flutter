import 'package:app/model/artist.dart';
import 'package:app/provider/artist_provider.dart';
import 'package:app/storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String artistId;
  final String artistImgUrl;
  final String name;

  const ArtistDetailScreen({
    Key? key,
    required this.artistId,
    required this.artistImgUrl,
    required this.name,
  }) : super(key: key);

  @override
  _ArtistDetailScreenState createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  late AudioPlayer _audioPlayer;
  late ArtistProvider _artistProvider;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _artistProvider = Provider.of<ArtistProvider>(context, listen: false);
    _artistProvider.fetchArtistTopTracks(widget.artistId, context);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPreview(String url) async {
    if (url == null || url == '') {
      return;
    }
    await _audioPlayer.play(UrlSource(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var token = await Provider.of<LocalStorage>(context, listen: false)
              .getToken();
          context.go('/home/search/artist/threads', extra: {
            'artistId': widget.artistId,
            'token': token,
            'artistName': widget.name,
          });
        },
        child: const Icon(Icons.add, size: 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: const Color.fromARGB(255, 235, 213, 149),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Consumer<ArtistProvider>(
        builder: (context, artistProvider, child) {
          if (artistProvider.topTracks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return SingleChildScrollView(
              child: Consumer<ArtistState>(
                builder: (context, artistStateValue, child) => Column(
                  children: [
                    artistStateValue.artistImgUrl != ''
                        ? Image.network(artistStateValue.artistImgUrl,
                            width: 300, height: 300, fit: BoxFit.cover)
                        : Container(
                            width: double.infinity,
                            height: 300,
                            child: const Center(child: Icon(Icons.music_note)),
                          ),
                    const SizedBox(
                      height: 50,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('Top Tracks'),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: artistProvider.topTracks.length,
                      itemBuilder: (context, index) {
                        final track = artistProvider.topTracks[index];
                        return ListTile(
                          leading: track.albumImageUrl != ''
                              ? Image.network(track.albumImageUrl,
                                  width: 50, height: 50, fit: BoxFit.cover)
                              : Container(
                                  width: 50,
                                  height: 50,
                                  child: const Center(
                                      child: Icon(Icons.music_note)),
                                ),
                          title: Text(track.name),
                          subtitle: Text('Track #${index + 1}'),
                          onTap: () => _playPreview(track.previewUrl),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
