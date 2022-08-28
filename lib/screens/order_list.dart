import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/order_list_item.dart';
import '../widgets/app_drawer.dart';

import '../providers/order.dart';

// class OrderListScreen extends StatefulWidget {
//   static const routeName = '/orders';
//
//   @override
//   State<OrderListScreen> createState() => _OrderListScreenState();
// }
//
// class _OrderListScreenState extends State<OrderListScreen> {
  // var _initState = true;
  // var _isLoading = false;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (_initState) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     final orderData =
  //         Provider.of<OrderProvider>(context, listen: false).listOrders().then((_) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     });
  //   }
  //   _initState = false;
  // }
class OrderListScreen extends StatelessWidget {
  static const routeName = '/orders';

  // Future _ordersFuture;
  //
  // Future _listOrdersFuture() {
  //   return Provider.of<OrderProvider>(context, listen: false)
  //       .listOrders();
  // }
  //
  // @override
  // void initState() {
  //   _ordersFuture = _listOrdersFuture();
  //   super.initState();
  // }
  // then use the _ordersFuture property in the FutureBuilder.future

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<OrderProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      // FutureBuilder associates with a future method
      // orderData parameter is the return value from the OrderProvider future
      // alternative to grabbing Provider data via the initState or
      // didChangeDependencies events
      // furthermore it means we dont need to convert a widget to stateful
      // the FutureBuilder handles the loading animation with connectionState
      // CAREFUL when using FutureBuilder, if you're managing a state outside of this
      // which triggers the parent build() method
      // the http request will be fired every time which is a waste
      // therefore it is advised to wrap the OrderProvider future in a future property
      // then reference the new future property in FutureBuilder.future
      // making sure it is a stateful widget (which it would be anyway if you needed
      // to use this approach)
      // see above as an example
      body: FutureBuilder(
          future: Provider.of<OrderProvider>(context, listen: false)
              .listOrders(),
          builder: (ctx, orderData) {
            // connectionState informs the current status of the OrderProvider future
            // compare to ConnectionState
            if (orderData.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (orderData.error != null) {
                // error handling stuff
                return Center(child: Text('An error occurred!'),);
              } else {
                return Consumer<OrderProvider>(builder: (ctx, orderData, child) => ListView.builder(
                  itemBuilder: (ctx, index) {
                    return OrderListItem(orderData.orders[index]);
                  },
                  itemCount: orderData.orders.length,
                )
                );
              }
            }
          }),
    );
  }
}
