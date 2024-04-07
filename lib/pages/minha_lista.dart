import 'package:flutter/material.dart';
import 'package:livros/models/book.dart';
import 'package:livros/pages/home_page.dart';

class MinhaListaPage extends StatelessWidget {
  const MinhaListaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        title: Text("Minha Lista de Livros"),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context); // Navegue de volta para a página anterior (HomePage)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Livros Adicionados",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(books[index].title),
                trailing: Icon(Icons.delete),
                onTap: () {
                  // Implemente a lógica para excluir o livro da lista
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
