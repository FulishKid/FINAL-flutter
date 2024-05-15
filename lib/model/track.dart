class Track {
  final String name;
  final String albumImageUrl;
  final String previewUrl;

  Track({
    required this.name,
    required this.albumImageUrl,
    required this.previewUrl,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      name: json['name'],
      albumImageUrl: json['album']['images'][0]['url'],
      previewUrl: json['preview_url'] ?? '',
    );
  }
}
