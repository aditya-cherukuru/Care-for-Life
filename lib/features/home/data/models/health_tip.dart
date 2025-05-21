class HealthTip {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  
  HealthTip({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
  });
  
  factory HealthTip.fromJson(Map<String, dynamic> json) {
    return HealthTip(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
    };
  }
}