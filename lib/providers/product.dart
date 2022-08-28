import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// prevent name clashes by assigning a prefix
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/http_exception.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];

  // _items is not accessible outside this class
  // since this class can be globally shared with other widgets
  // you do not want these widgets modifying the original List of Products
  // therefore you need to set a getter
  // and use [..._var] to make a copy of the original _items List
  // changes to the data can ONLY happen inside the class
  // otherwise notifyListeners() could not be called
  // and all widgets listening to this provider would not get updated data

  // var _showFavouritesOnly = false;

  String authToken;
  String userId;

  ProductProvider(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavouritesOnly) {
    //   return _items.where((product) => product.isFavourite).toList();
    // } else {
    return [..._items];
    // }
  }

  List<Product> get favouriteItems {
    return _items.where((product) => product.isFavourite).toList();
  }

  Product findById(String productId) {
    return items.firstWhere((product) => product.id == productId);
  }

  void updateUser(String authToken, String userId) {
    this.authToken = authToken;
    this.userId = userId;
    notifyListeners();
  }

  // void showFavouritesOnly() {
  //   _showFavouritesOnly = true;
  //   notifyListeners();
  // }
  //
  // void showAll() {
  //   _showFavouritesOnly = false;
  //   notifyListeners();
  // }

  // [] around an argument make it optional, can set a default
  Future<void> listProducts([bool filterByUser = false]) async {
    final filterUrl = filterByUser ? 'orderBy="userId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://shop-app-learning-4f367-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken&$filterUrl');
    try {
      // headers are set on the http method e.g. http.get(url, headers: { headers } )
      final response = await http.get(url);
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (jsonResponse == null) {
        return;
      }
      final favouriteUrl = Uri.parse(
          'https://shop-app-learning-4f367-default-rtdb.asia-southeast1.firebasedatabase.app/userFavourites/$userId.json?auth=$authToken');
      final favouriteResponse = await http.get(favouriteUrl);
      final favouriteBody = json.decode(favouriteResponse.body);
      jsonResponse.forEach((productId, productData) {
        loadedProducts.add(
          Product(
              id: productId,
              name: productData['name'],
              description: productData['description'],
              price: productData['price'],
              imageUrl: productData['imageUrl'],
              // ?? checks if value is null, if it is can return another value
              isFavourite: favouriteBody == null
                  ? false
                  : (favouriteBody[productId] ?? false)),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // need to return a future, we don't care what data type we return to the widget
  // so we set has void
  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-app-learning-4f367-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');
    // if you set async for a function if will automatically return a FUTURE
    // so in this instance you don't need to `return` for `http.post`
    // adding `await` to `http.post` means we no longer need `then()` and `catchError()`
    // since it tells the code to wait for the http.post to finish BEFORE executing code after it
    // see commented code below for the previous implementation
    // await requires `async` set on the function to work
    // convert catchError() to a try > catch
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'userId': userId,
        }),
      );
      final newProduct = Product(
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)["name"],
      );
      _items.add(newProduct);
      notifyListeners();
      // catch must always pass an error parameter
    } catch (error) {
      throw error;
    }
    // throw enables passing the error to the widget that called this function
    // i.e. the user interface
    // throw error;
    // http.post(
    //   url,
    //   body: json.encode({
    //     'name': product.name,
    //     'description': product.description,
    //     'price': product.price,
    //     'imageUrl': product.imageUrl,
    //     'isFavourite': product.isFavourite,
    //   }),
    // ).then((response) {
    //   final newProduct = Product(
    //     name: product.name,
    //     description: product.description,
    //     price: product.price,
    //     imageUrl: product.imageUrl,
    //     id: json.decode(response.body)["name"],
    //   );
    //   _items.add(newProduct);
    //   notifyListeners();
    // }).catchError((error) {
    //   // throw enables passing the error to the widget that called this function
    //   // i.e. the user interface
    //   throw error;
    // });
  }

  Future<void> updateProduct(String productId, Product product) async {
    final productIndex =
        _items.indexWhere((product) => product.id == productId);
    if (productIndex >= 0) {
      final url = Uri.parse(
          'https://shop-app-learning-4f367-default-rtdb.asia-southeast1.firebasedatabase.app/products/$productId.json?auth=$authToken');
      try {
        await http.patch(
          url,
          body: json.encode({
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          }),
        );
        _items[productIndex] = product;
        notifyListeners();
      } catch (error) {
        throw error;
      } finally {
        _items[productIndex] = product;
        notifyListeners();
      }
    } else {
      print('No update product found!');
    }
  }

  Future<void> deleteProduct(String productId) async {
    // optimistic updating
    // change it initially locally
    // but roll back if the server request fails
    final url = Uri.parse(
        'https://shop-app-learning-4f367-default-rtdb.asia-southeast1.firebasedatabase.app/products/$productId.json?auth=$authToken');
    final currentProductIndex =
        _items.indexWhere((product) => product.id == productId);
    var currentProduct = _items[currentProductIndex];
    final response = await http.delete(url);
    _items.removeAt(currentProductIndex);
    notifyListeners();
    if (response.statusCode >= 400) {
      _items.insert(currentProductIndex, currentProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    currentProduct = null;
  }
}
