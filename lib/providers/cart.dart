import 'package:flutter/material.dart';

import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _cartItems = {};

  // FUCK HEAD, CHECK THIS MAPPING IS CORRECT WHEN YOU WAKE UP
  Map<String, CartItem> get cartItems {
    return {..._cartItems};
  }

  int get itemCount {
    return _cartItems.length;
  }

  double get totalAmount {
    var total = 0.0;
    _cartItems.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, double price, String name) {
    if (_cartItems.containsKey(productId)) {
      _cartItems.update(
          productId,
          (currentCartItem) => CartItem(
                id: currentCartItem.id,
                name: currentCartItem.name,
                price: currentCartItem.price,
                quantity: currentCartItem.quantity + 1,
              ));
    } else {
      _cartItems.putIfAbsent(
          productId,
          () => CartItem(
                id: DateTime.now().toString(),
                name: name,
                price: price,
                quantity: 1,
              ));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_cartItems.containsKey(productId)) {
      return;
    }
    if (_cartItems[productId].quantity > 1) {
      _cartItems.update(
        productId,
        (currentCartItem) => CartItem(
            id: currentCartItem.id,
            name: currentCartItem.name,
            price: currentCartItem.price,
            quantity: currentCartItem.quantity - 1),
      );
    } else {
      _cartItems.remove(productId);
    }
    notifyListeners();
  }

  void reset() {
    _cartItems = {};
    notifyListeners();
  }
}
