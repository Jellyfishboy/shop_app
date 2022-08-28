import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './helpers/custom_route.dart';

import './screens/single_product.dart';
import './screens/order_list.dart';
import './screens/cart.dart';
import './screens/user/product_list.dart';
import './screens/edit_product.dart';
import './screens/auth.dart';
import './screens/splash.dart';
import './screens/product_list.dart';

import './providers/product.dart';
import './providers/cart.dart';
import './providers/order.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // associate a provider class with a widget using ChangeNotifierProvider()
    // make sure you set it at the top most widget which requires data
    // associated with that provider class
    // can use ChangeNotifierProvider().create or ChangeNotifierProvider.value().value
    // the former allows you to utilise the build context (context) =>
    // ChangeNotifierProvider.value() use on existing objects (like in products_grid with products[index])
    // such as lists or grids
    // ChangeNotifierProvider().create use when instantiating a new class object like below with ProductProvider()
    // can still ChangeNotifierProvider.value() when instantiating a new class object
    // BUT it's not as efficient

    // MultiProvider() allows you to pass multiple providers at once
    return MultiProvider(
        providers: [
          // make sure auth provider is the first in the list if
          // other providers depend upon it
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          // ChangeNotifierProxyProvider requires `update` rather than `create`
          // ChangeNotifierProxyProvider enables you to chain 2 providers into
          // a single provider
          // you can have multiple dependencies on a single provider up to 6
          // e.g. ChangeNotifierProxyProvider2<OtherProvider, ProductProvider>
          ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
            create: (_) => ProductProvider('', '', []),
            update: (_, authProvider, oldProductProvider) => oldProductProvider
              ..updateUser(authProvider.token, authProvider.userId),
            // make sure to pass in previous instantiated items for the provider
            //   ProductProvider(
            // authProvider.token,
            // authProvider.userId,
            // (oldProductProvider == null ? [] : oldProductProvider.items),
          ),
          // ),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
            update: (_, authProvider, oldOrderProvider) =>
                // make sure to pass in previous instantiated items for the provider
                OrderProvider(
              authProvider.token,
              authProvider.userId,
              (oldOrderProvider == null ? [] : oldOrderProvider.orders),
            ),
          ),
        ],
        // value: ProductProvider(),
        // setting a consumer on the main.dart MaterialApp ensures
        // it will be rebuilt if the authentication status changes
        child: Consumer<AuthProvider>(
            builder: (ctx, authData, child) => MaterialApp(
                  title: 'MyShop',
                  theme: ThemeData(
                    primarySwatch: Colors.purple,
                    accentColor: Colors.deepOrange,
                    fontFamily: 'Lato',
                    // sets transition animation for all routes
                    pageTransitionsTheme: PageTransitionsTheme(
                      builders: {
                        // can specify different transitions by platform
                        TargetPlatform.android: CustomPageTransitionBuilder(),
                        TargetPlatform.iOS: CustomPageTransitionBuilder()
                      },
                    ),
                  ),
                  home: authData.isAuthenticated
                      ? ProductListScreen()
                      : FutureBuilder(
                          future: authData.tryAutoLogin(),
                          builder: (ctx, authAutoResult) =>
                              authAutoResult.connectionState ==
                                      ConnectionState.waiting
                                  ? SplashScreen()
                                  : AuthScreen(),
                        ),
                  // initialRoute: '/home',
                  routes: {
                    // '/home': (_) => AuthScreen(),
                    SingleProductScreen.routeName: (_) => SingleProductScreen(),
                    CartScreen.routeName: (_) => CartScreen(),
                    OrderListScreen.routeName: (_) => OrderListScreen(),
                    UserProductListScreen.routeName: (_) =>
                        UserProductListScreen(),
                    EditProductScreen.routeName: (_) => EditProductScreen(),
                  },
                )));
  }
}
