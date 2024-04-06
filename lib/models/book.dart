class Book {
  String title;

  Book({required this.title});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['volumeInfo']['title'],
    );
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      title: map['title'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
    };
  }
}