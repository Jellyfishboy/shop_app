import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/cart_list_item.dart';
import '../widgets/place_order_button.dart';

import '../providers/cart.dart';
import '../providers/order.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  // spacer() takes up all available space
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cartData.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme
                        .of(context)
                        .primaryColor,
                  ),
                  PlaceOrderButton(cartData: cartData),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // ListView widget will not work inside a column
          // Column has infinite height and ListView will take up all the space
          // that is available in height
          // which results in an infinite height ListView
          // wrap in an Expanded() widget to prevent this
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, index) {
                return CartListItem(
                  // cartItems is a map inside the Cart model (Map<String, CartItem>)
                  // you can access just the value data by doing .values.toList()
                  // can also access keys, which in this case is the productId
                  id: cartData.cartItems.values.toList()[index].id,
                  name: cartData.cartItems.values.toList()[index].name,
                  price: cartData.cartItems.values.toList()[index].price,
                  quantity: cartData.cartItems.values.toList()[index].quantity,
                  productId: cartData.cartItems.keys.toList()[index],
                );
              },
              itemCount: cartData.itemCount,
            ),
          ),
        ],
      ),
    );
  }
}
