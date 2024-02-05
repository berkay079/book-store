import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:palette_generator/palette_generator.dart';

class BookDetails extends StatefulWidget {
  final String volumeId;

  BookDetails({Key? key, required this.volumeId}) : super(key: key);

  @override
  _BookDetailsState createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  Map<String, dynamic>? _bookDetails;
  PaletteGenerator? _paletteGenerator;

  @override
  void initState() {
    super.initState();
    _fetchBookDetails(); // Initial fetch of book details
  }

  Future<void> _fetchBookDetails() async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/books/v1/volumes/${widget.volumeId}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _bookDetails = data['volumeInfo'];
      });

      _generatePalette(); // Generate color palette for the book cover image
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  }

  Future<void> _generatePalette() async {
    if (_bookDetails!['imageLinks'] != null) {
      final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(_bookDetails!['imageLinks']['thumbnail']),
      );
      setState(() {
        _paletteGenerator = paletteGenerator;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bookDetails == null) {
      // Loading state
      return Scaffold(
        appBar: AppBar(
          title: Text('Kitap Detay'), // App bar title
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // Loaded state
      return Scaffold(
        appBar: AppBar(
          title: Text(_bookDetails!['title'] ?? 'Unknown Title'), // Book title in app bar
        ),
        body: Container(
          color: _paletteGenerator?.dominantColor?.color ?? Colors.white, // Background color
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_bookDetails!['imageLinks'] != null)
                    Image.network(
                      _bookDetails!['imageLinks']['thumbnail'],
                      height: 200,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Yazar: ${_bookDetails!['authors']?.join(', ') ?? 'Unknown Author'}',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kitap Adı: ${_bookDetails!['title'] ?? 'Unknown Title'}',
                    style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Yayınlanma Tarihi: ${_bookDetails!['publishedDate'] ?? 'Unknown Date'}',
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  if (_bookDetails!['description'] != null)
                    Text(
                      'Açıklama: ${_bookDetails!['description']}',
                      style: TextStyle(color: Colors.black),
                    ),
                  // You can add other relevant information here.
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
