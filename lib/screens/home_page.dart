import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'book_details.dart'; // File containing the details page

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
        _searchResults = data['items'] ?? []; // Updating search results with book items
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
        title: Text('Home Page'), // App bar title
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Kitap Adı'), // Textfield for entering book name
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _searchBooks(_searchController.text); // Trigger book search on button press
            },
            child: Text('Kitapları Ara'), // Button text
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final book = _searchResults[index]['volumeInfo'];
                final imageLinks = book['imageLinks'] ?? {};

                return ListTile(
                  title: Text(book['title'] ?? 'Unknown Title'), // Book title
                  subtitle: Text(book['authors']?.join(', ') ?? 'Unknown Author'), // Book author(s)
                  leading: imageLinks.isNotEmpty
                      ? Image.network(
                          imageLinks['thumbnail'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : SizedBox.shrink(),
                  onTap: () {
                    // Navigate to the details page of the selected book
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
