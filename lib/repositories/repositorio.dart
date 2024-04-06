import 'package:livros/repositories/sqflite.dart';
import 'package:livros/models/book.dart';

class Repositorio {
  Repositorio();

  Future<void> salvarLivro(List<Book> books) async {
    var db = await SQLiteDataBase().obterDataBase();
    await db.rawQuery('DELETE from tarefas');
    for (Book book in books){
      await db.rawInsert('INSERT INTO books (title) VALUES (?)',[book.title]);
    }
  }

  Future<List<Book>> recuperarLivro() async {
    List<Book> books = [];
    var db = await SQLiteDataBase().obterDataBase();
    var result = await db.rawQuery('SELECT * FROM books');
    for (var element in result) {
      books.add(Book(title:
      element["title"].toString()));
    }
    return books;
  }
}