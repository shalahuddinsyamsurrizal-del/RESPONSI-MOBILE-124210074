class Article {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;
  final List<String> authors;

  Article({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    required this.authors,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      url: json['url'] ?? '',
      imageUrl: json['image_url'] ?? '',
      newsSite: json['news_site'] ?? 'Unknown',
      summary: json['summary'] ?? 'No summary available',
      publishedAt: json['published_at'] ?? '',
      authors: (json['authors'] as List? ?? [])
          .map((author) => author['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'articleId': id,
      'title': title,
      'url': url,
      'imageUrl': imageUrl,
      'newsSite': newsSite,
      'summary': summary,
      'publishedAt': publishedAt,
      'authors': authors,
    };
  }
}
