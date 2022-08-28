import 'package:flutter/material.dart';

class OrderListProductItem extends StatelessWidget {
  final String name;
  final double price;
  final int quantity;

  OrderListProductItem({
    @required this.name,
    @required this.price,
    @required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '$quantity x \$$price',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
