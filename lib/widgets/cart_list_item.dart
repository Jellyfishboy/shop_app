import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartListItem extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String productId;

  const CartListItem({
    @required this.id,
    @required this.name,
    @required this.price,
    @required this.quantity,
    @required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    // dismissable is a swipe remove animation
    return Dismissible(
      // ValueKey with a parameter creates a unique value
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(Icons.delete, color: Colors.white, size: 40),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
      ),
      direction: DismissDirection.endToStart,
      // direction arguments allows you to define different behaviour for left or right
      // e.g. swipe right updates, swipe left removes
      confirmDismiss: (direction) {
        // showDialog returns a future
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to remove the item from the cart?'),
            actions: [
              FlatButton(
                onPressed: () {
                  // Navigator.of returns a FUTURE
                  Navigator.of(ctx).pop(false);
                },
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
                child: Text('Yes'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        // set listen: false if you just want to trigger a method from the provider once
        Provider.of<CartProvider>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: FittedBox(
                  child: Text('\$$price'),
                ),
              ),
            ),
            title: Text(name),
            subtitle: Text('Total: \$${price * quantity}'),
            trailing: Text('x $quantity'),
          ),
        ),
      ),
    );
  }
}
