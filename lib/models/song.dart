class Song {
  final String id;
  final String title;
  final String artist;
  final String thumbnail;
  final String category;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnail,
    required this.category,
  });

  Song.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String? ?? '',
        title = json['title'] as String? ?? 'Unknown Title',
        artist = (json['artist'] ?? json['uploader'] ?? 'Unknown Artist') as String,
        thumbnail = (json['thumbnail'] ?? json['poster_image'] ?? '') as String,
        category = json['category'] as String? ?? '';
}