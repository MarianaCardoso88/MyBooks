import 'package:flutter/material.dart';
import 'package:livros/models/book.dart';
import 'package:livros/repositories/repositorio.dart';

class MinhaListaPage extends StatefulWidget {
  const MinhaListaPage({Key? key}) : super(key: key);

  @override
  State<MinhaListaPage> createState() => _MinhaListaPageState();
}

class _MinhaListaPageState extends State<MinhaListaPage> {
  Repositorio _repositorio = Repositorio();
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    _recuperarLivro();
  }

  void _recuperarLivro() async {
    List<Book> fetchedBooks = await _repositorio.recuperarLivro();
    setState(() {
      books = fetchedBooks;
      print(books);
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
        title: Text('Minha Lista de Livros'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: books.isNotEmpty ? _buildBookList() : SizedBox(),
    );
  }

  Widget _buildBookList() {
    return Column(
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
    );
  }
}
