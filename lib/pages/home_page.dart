import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:livros/models/book.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Books API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BookSearchPage(),
    );
  }
}

class BookSearchPage extends StatefulWidget {
  @override
  _BookSearchPageState createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  TextEditingController _controller = TextEditingController();
  List<Book> _books = [];
  List<Book> _readingList = [];

  Future<void> _searchBooks(String query) async {
    final String apiKey = 'API KEY'; // Troque para sua chave de API do Google Books
    final String apiUrl =
        'https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=10&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _books.clear();
        _books.addAll((data['items'] as List).map((item) => Book.fromJson(item)).toList());
      });
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<void> _addBookToReadingList(Book book) async {
    final database = await _openDatabase();
    await database.insert('reading_list', book.toMap());
    await _fetchReadingList();
  }

  Future<Database> _openDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'reading_list.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE reading_list(id INTEGER PRIMARY KEY, title TEXT)',
        );
      },
    );
  }

  Future<void> _fetchReadingList() async {
    final database = await _openDatabase();
    final List<Map<String, dynamic>> books = await database.query('reading_list');

    setState(() {
      _readingList.clear();
      _readingList.addAll(books.map((book) => Book.fromMap(book)).toList());
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchReadingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Books API Demo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Digite o nome do livro',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _searchBooks(_controller.text);
              },
              child: Text('Enviar'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return ListTile(
                    title: Text(book.title),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        await _addBookToReadingList(book);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Lista de Leitura',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: _readingList.length,
                itemBuilder: (context, index) {
                  final book = _readingList[index];
                  return ListTile(
                    title: Text(book.title),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}