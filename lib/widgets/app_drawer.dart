import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_route.dart';

import '../providers/auth.dart';

import '../screens/order_list.dart';
import '../screens/user/product_list.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            // automaticallyImplyLeading will always disable the ability
            // for a back button to show
            title: Text('Menu'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              // Navigator.of(context).pushNamedAndRemoveUntil(OrderListScreen.routeName, (Route<dynamic> route) => false);
              Navigator.of(context).pushReplacement(
                CustomRouteHelper(
                  builder: (ctx) => OrderListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Managed Products'),
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  UserProductListScreen.routeName,
                  (Route<dynamic> route) => false);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              // if your logout button resides on a drawer
              // make sure to pop it off the stack before hitting the logout function
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          )
        ],
      ),
    );
  }
}
