import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livros/models/book.dart';
import 'package:livros/repositories/repositorio.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controllerBook = TextEditingController();
  Repositorio _repositorio = Repositorio();
  List<Book> books = [];

  List<Book> searchedBooks = [];

  void _pesquisarLivro() async {
    String query = controllerBook.text.trim();
    if (query.isNotEmpty) {
      String apiKey = 'AIzaSyCLCJ2Yv_4lFRI4Z-MQbrkHxmdSNfqDvmM';
      String apiUrl = 'https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=10&key=$apiKey';

      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<Book> searchResults = [];

        for (var item in data['items']) {
          searchResults.add(Book(title: item['volumeInfo']['title'] ?? '', realizado: false));
        }

        setState(() {
          searchedBooks = searchResults;
        });
      } else {
        print('Erro ao buscar livros: ${response.statusCode}');
      }
    }
  }

  void _adicionarLivro(Book book) {
    setState(() {
      books.add(book);
      _repositorio.salvarLivro(books);
    });
  }

  void _removerLivro(int index) {
    setState(() {
      Book livroRemovido = books[index];
      books.removeAt(index);
      _repositorio.salvarLivro(books);

      final snack = SnackBar(
        content: Text("Livro ${livroRemovido.title} removido"),
        action: SnackBarAction(
          label: "Desfazer",
          onPressed: () {
            setState(() {
              books.insert(index, livroRemovido);
              _repositorio.salvarLivro(books);
            });
          },
        ),
        duration: Duration(seconds: 3),
      );

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snack);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        title: Text("Lista de livros"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: "Novo Livro"),
                    controller: controllerBook,
                  ),
                ),
                ElevatedButton(
                  onPressed: _pesquisarLivro,
                  child: Text("PESQUISAR"),
                )
              ],
            ),
          ),
          searchedBooks.isNotEmpty
              ? Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Resultados da Pesquisa",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: searchedBooks.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(searchedBooks[index].title),
                      trailing: ElevatedButton(
                        onPressed: () => _adicionarLivro(searchedBooks[index]),
                        child: Text("Adicionar"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
              : SizedBox(),
          books.isNotEmpty
              ? Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Minha Lista de Livros",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) => Dismissible(
                      key: Key(books[index].title),
                      background: Container(
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20.0),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _removerLivro(index);
                      },
                      child: ListTile(
                        title: Text(books[index].title),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
              : SizedBox(),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Lista de Livros',
    theme: ThemeData(
      primarySwatch: Colors.blueGrey,
    ),
    home: HomePage(),
  ));
}