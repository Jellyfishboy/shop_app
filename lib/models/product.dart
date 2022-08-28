import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  void _setFavouriteValue(bool newValue) {
    isFavourite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavouriteStatus(String authToken, String userId) async {
    final currentFavouriteStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url =
        'https://shop-app-learning-4f367-default-rtdb.asia-southeast1.firebasedatabase.app/userFavourites/$userId/$id.json?auth=$authToken';
    try {
      final response = await http.put(url,
          body: json.encode(
            isFavourite,
          ));
      if (response.statusCode >= 400) {
        _setFavouriteValue(currentFavouriteStatus);
      }
    } catch (error) {
      _setFavouriteValue(currentFavouriteStatus);
    }
  }
}
