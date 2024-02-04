import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'book_details.dart'; // Detay sayfasını içeren dosya


class FavoriPage extends StatefulWidget {
  @override
  _FavoriPageState createState() => _FavoriPageState();
}

class _FavoriPageState extends State<FavoriPage> {
  List<dynamic> _newBooks = [];
  List<dynamic> _bestSellerBooks = [];

  @override
  void initState() {
    super.initState();
    _searchNewBooks();
    _searchBestSellerBooks();
  }

  Future<void> _searchNewBooks() async {
    final DateTime currentDate = DateTime.now();
    final formattedDate = "${currentDate.year}-${currentDate.month}-${currentDate.day}";

    final response = await http.get(
      Uri.parse('https://www.googleapis.com/books/v1/volumes?q=new&orderBy=newest&publishedAfter=$formattedDate'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _newBooks = data['items'] ?? [];
      });
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  }

  Future<void> _searchBestSellerBooks() async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/books/v1/volumes?q=bestseller'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _bestSellerBooks = data['items'] ?? [];
      });
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  }

  @override
// ...
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Çıkan ve Best Seller Kitaplar'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _newBooks.length,
              itemBuilder: (context, index) {
                final book = _newBooks[index]['volumeInfo'];
                final title = book['title'] as String? ?? 'Unknown Title';
                final authors = (book['authors'] as List<dynamic>?)?.join(', ') ?? 'Unknown Author';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetails(volumeId: book['id']),
                      ),
                    );
                  },
                  child: Container(
                    width: 150,
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: book['imageLinks'] != null
                                ? Image.network(
                                    book['imageLinks']['thumbnail'] as String,
                                    fit: BoxFit.cover,
                                  )
                                : Placeholder(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              authors,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _bestSellerBooks.length,
              itemBuilder: (context, index) {
                final book = _bestSellerBooks[index]['volumeInfo'];
                final title = book['title'] as String? ?? 'Unknown Title';
                final authors = (book['authors'] as List<dynamic>?)?.join(', ') ?? 'Unknown Author';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetails(volumeId: book['id']),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(8),
                    child: Card(
                      child: ListTile(
                        leading: book['imageLinks'] != null
                            ? Image.network(
                                book['imageLinks']['thumbnail'] as String,
                                fit: BoxFit.cover,
                              )
                            : Placeholder(),
                        title: Text(title),
                        subtitle: Text(authors),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// ...

}
