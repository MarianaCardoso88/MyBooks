class Book {
  Book({required this.title, required this.realizado});

  String title;
  bool realizado;

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "realizado": realizado,
    };
  }
}