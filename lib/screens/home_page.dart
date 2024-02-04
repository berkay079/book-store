import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'book_details.dart'; // Detay sayfasını içeren dosya

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];

  Future<void> _searchBooks(String query) async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _searchResults = data['items'] ?? [];
      });
    } else {
      // Handle error
      print('Error: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Kitap Adı'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _searchBooks(_searchController.text);
            },
            child: Text('Kitapları Ara'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final book = _searchResults[index]['volumeInfo'];
                final imageLinks = book['imageLinks'] ?? {};

                return ListTile(
                  title: Text(book['title'] ?? 'Unknown Title'),
                  subtitle: Text(book['authors']?.join(', ') ?? 'Unknown Author'),
                  leading: imageLinks.isNotEmpty
                      ? Image.network(
                          imageLinks['thumbnail'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : SizedBox.shrink(),
                  onTap: () {
                    // Seçilen kitabın detay sayfasına git
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetails(
                          volumeId: _searchResults[index]['id'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
