class Thread {
  final String artistId;
  final String title;
  final String content;
  final String artistName;
  final int? threadId;
  final int? creatorId;
  final String? createdAt;
  int rating;
  bool isLiked = false;
  bool isDisLiked = false;

  Thread(
      {required this.artistId,
      this.threadId,
      this.creatorId,
      this.createdAt,
      required this.title,
      required this.content,
      required this.artistName,
      required this.rating});

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      threadId: json['thread_id'],
      createdAt: json['created_at'] ?? '',
      creatorId: json['creator_id'] ?? 0,
      artistId: json['artist_id'].toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      artistName: json['artistName'] ?? '',
      rating: json['rating'] != null ? json['rating'] as int : 0,
    );
  }
}
