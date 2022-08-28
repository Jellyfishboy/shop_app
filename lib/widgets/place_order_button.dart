import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order.dart';
import '../providers/cart.dart';

class PlaceOrderButton extends StatefulWidget {
  final CartProvider cartData;

  const PlaceOrderButton({
    @required this.cartData,
  });

  @override
  State<PlaceOrderButton> createState() => _PlaceOrderButtonState();
}

class _PlaceOrderButtonState extends State<PlaceOrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('Place Order'),
      onPressed: (widget.cartData.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              // await forces the Provider to be synchronous
              // this means it waits for addOrder() to finish
              // before setting isLoading back to false
              await Provider.of<OrderProvider>(context, listen: false).addOrder(
                  widget.cartData.cartItems.values.toList(),
                  widget.cartData.totalAmount);
              setState(() {
                _isLoading = false;
              });
              widget.cartData.reset();
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
