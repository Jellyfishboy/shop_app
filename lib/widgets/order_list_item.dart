import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './order_list_product_item.dart';
import '../models/order_item.dart';

class OrderListItem extends StatefulWidget {
  final OrderItem orderItem;

  OrderListItem(this.orderItem);

  @override
  State<OrderListItem> createState() => _OrderListItemState();
}

class _OrderListItemState extends State<OrderListItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _expanded ? min(widget.orderItem.products.length* 20.0 + 130, 200) : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              // leading:,
              title: Text('\$${widget.orderItem.amount}'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(
                    widget.orderItem.chargedAt),
              ),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              height: _expanded ? min(widget.orderItem.products.length* 20.0 + 30, 100) : 0,
              child: ListView.builder(
                itemBuilder: (ctx, index) {
                  return OrderListProductItem(
                    name: widget.orderItem.products[index].name,
                    price: widget.orderItem.products[index].price,
                    quantity: widget.orderItem.products[index].quantity,
                  );
                },
                itemCount: widget.orderItem.products.length,
              ),
            )
          ],
        )
        ,
      ),
    );
  }
}
