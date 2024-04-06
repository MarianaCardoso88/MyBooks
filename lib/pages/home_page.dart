import 'package:flutter/material.dart';
import 'package:livros/models/book.dart';
import 'package:livros/repositories/repositorio.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controlerBook = TextEditingController();

  Repositorio _repositorio = Repositorio();
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    _repositorio.recuperarLivro().then((dados) {
      setState(() {
        books = dados;
      });
    });
  }

  void _adicionarLivro() {
    setState(() {
      Book book = Book(title: controlerBook.text, realizado: false);
      books.add(book);
      controlerBook.text = '';
      _repositorio.salvarLivro(books);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        title: Text(
            "Lista de livros"),
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
                      controller: controlerBook,
                    )),
                ElevatedButton(onPressed: _adicionarLivro, child: Text("ADD"))
              ],
            ),
          ),
          Expanded(child: ListView.builder(
              itemCount: books.length,
              itemBuilder: contruirListView))
        ],
      ),
    );
  }

  Widget contruirListView(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime
          .now()
          .microsecondsSinceEpoch
          .toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(books[index].title),
        value: books[index].realizado,
        secondary: CircleAvatar(
          child: Icon(books[index].realizado ? Icons.check : Icons.error),
        ),
        onChanged: (checked) {
          setState(() {
            books[index].realizado = checked!;
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          Book livroRemovido = books[index];
          books.removeAt(index);
          _repositorio.salvarLivro(books);
          int indiceLivroRemovido = index;

          final snack = SnackBar(
            content: Text("Livro ${livroRemovido.title} removido"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    books.insert(indiceLivroRemovido, livroRemovido);
                    _repositorio.salvarLivro(books);
                  });
                }),
            duration: Duration(seconds: 3),
          );

          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }
}