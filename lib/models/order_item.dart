import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';

class OrderItem {
  final String id;
  final double amount;
  final DateTime chargedAt;
  final List<CartItem> products;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.chargedAt,
  });
}
