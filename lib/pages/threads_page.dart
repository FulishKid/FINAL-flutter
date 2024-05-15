import 'package:app/api/spofity_acces_token.dart';
import 'package:app/storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/threads_provider.dart';

class ThreadsPage extends StatefulWidget {
  final String artistId;
  final String token;
  final String artistName;

  const ThreadsPage(
      {super.key,
      required this.artistId,
      required this.token,
      required this.artistName});

  @override
  _ThreadsPageState createState() => _ThreadsPageState();
}

class _ThreadsPageState extends State<ThreadsPage> {
  late ThreadsProvider _threadsProvider;
  late LocalStorage _localStorage;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool isLoading = true; // Для відстеження стану завантаження

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _threadsProvider = Provider.of<ThreadsProvider>(context, listen: false);
    _localStorage = Provider.of<LocalStorage>(context, listen: false);
    _loadThreads();
  }

  void _loadThreads() async {
    setState(() {
      isLoading = true;
    });

    await _threadsProvider.fetchThreadsBySpotifyArtistId(
        widget.token, widget.artistId);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitThread() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      var token = await _localStorage.getToken();
      await _threadsProvider.addThread(
        rating: 0,
        content: content,
        context: context,
        token: token!,
        spotifyArtistId: widget.artistId,
        artistName: widget.artistName,
        title: title,
      );

      _titleController.clear();
      _contentController.clear();
      _loadThreads(); // Оновити дані після додавання треду
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist Threads'),
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Показуємо індикатор завантаження
          : Column(
              children: [
                Expanded(
                  child: Consumer<ThreadsProvider>(
                    builder: (context, threadsProvider, child) {
                      if (threadsProvider.threads.isEmpty) {
                        return const Center(child: Text('No threads yet.'));
                      } else {
                        return ListView.builder(
                          itemCount: threadsProvider.threads.length,
                          itemBuilder: (context, index) {
                            final thread = threadsProvider.threads[index];
                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(thread.title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(thread.content),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: thread.isLiked
                                              ? Icon(Icons.thumb_up)
                                              : Icon(Icons.thumb_up_outlined),
                                          onPressed: () async {
                                            if (!thread.isLiked) {
                                              thread.rating++;
                                              if (thread.isDisLiked) {
                                                thread.isDisLiked = false;
                                                thread.rating++;
                                              }
                                              thread.isLiked = true;
                                            } else {
                                              thread.rating--;
                                              thread.isLiked = false;
                                            }
                                            await threadsProvider
                                                .changeThreadRating(
                                              isLiked: true,
                                              token: widget.token,
                                              threadId: thread.threadId!,
                                            );
                                            _threadsProvider.notifyListeners();
                                          },
                                        ),
                                        IconButton(
                                          icon: thread.isDisLiked
                                              ? Icon(Icons.thumb_down)
                                              : Icon(Icons.thumb_down_outlined),
                                          onPressed: () async {
                                            if (!thread.isDisLiked) {
                                              thread.rating--;
                                              if (thread.isLiked) {
                                                thread.isLiked = false;
                                                thread.rating--;
                                              }
                                              thread.isDisLiked = true;
                                            } else {
                                              thread.rating++;
                                              thread.isDisLiked = false;
                                            }
                                            await threadsProvider
                                                .changeThreadRating(
                                              isLiked: false,
                                              token: widget.token,
                                              threadId: thread.threadId!,
                                            );
                                            _threadsProvider.notifyListeners();
                                          },
                                        ),
                                        Text('Rating: ${thread.rating}'),
                                      ],
                                    ),
                                    Container(
                                      height: 5,
                                      width: double.infinity,
                                      color: thread.rating >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      margin: const EdgeInsets.only(top: 5),
                                    ),
                                  ],
                                ),
                                trailing: FutureBuilder(
                                  future: Provider.of<LocalStorage>(context)
                                      .getUserId(),
                                  builder: (context, localStorageSnapshot) {
                                    final userId = localStorageSnapshot.data;
                                    if (userId == thread.creatorId) {
                                      return FutureBuilder(
                                        future:
                                            Provider.of<LocalStorage>(context)
                                                .getToken(),
                                        builder: (context, getTokenSnapshot) {
                                          return Consumer<ThreadsProvider>(
                                            builder: (context, threadsProvider,
                                                    child) =>
                                                PopupMenuButton<String>(
                                              onSelected: (value) {
                                                if (value == 'edit') {
                                                  // Handle edit
                                                } else if (value == 'delete') {
                                                  threadsProvider.deleteThread(
                                                      token: getTokenSnapshot
                                                          .data!,
                                                      threadId:
                                                          thread.threadId);
                                                  _loadThreads();
                                                }
                                              },
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text('Edit'),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text('Delete'),
                                                  ),
                                                ];
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Thread Title',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: 'Thread Content',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submitThread,
                              child: const Text('Submit'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
