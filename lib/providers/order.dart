import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/order_item.dart';
import '../models/cart_item.dart';

class OrderProvider with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  OrderProvider(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> listOrders() async {
    final url =
        Uri.parse('https://shop-app-learning-4f367-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken');

    try {
      final response = await http.get(url);
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      if (jsonResponse == null) {
        return;
      }
      jsonResponse.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
            id: orderId,
            amount: orderData["amount"],
            // use DateTime.parse from iso to DateTime object
            chargedAt: DateTime.parse(orderData["chargedAt"]),
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (cartItem) => CartItem(
                    id: cartItem['id'],
                    price: cartItem['price'],
                    quantity: cartItem['quantity'],
                    name: cartItem['name'],

                  ),
                )
                .toList()));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        Uri.parse('https://shop-app-learning-4f367-default-rtdb.asia-southeast1.firebasedatabase.app/orders/$userId.json?auth=$authToken');
    final chargedAt = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'chargedAt': chargedAt.toIso8601String(),
          'products': cartProducts
              .map((cartProduct) => {
                    'id': cartProduct.id,
                    'name': cartProduct.name,
                    'quantity': cartProduct.quantity,
                    'price': cartProduct.price,
                  })
              .toList()
        }),
      );
      final newOrderItem = OrderItem(
        id: json.decode(response.body)["name"],
        amount: total,
        chargedAt: chargedAt,
        products: cartProducts,
      );
      // add() will always add the item to the end of the list
      // insert can define with a parameter where in the list to insert
      // e.g. 0 will insert it at the beginning of the list
      _orders.insert(0, newOrderItem);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
