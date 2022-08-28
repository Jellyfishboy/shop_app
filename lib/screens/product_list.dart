import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import '../screens/cart.dart';
import '../providers/cart.dart';
import '../providers/product.dart';

enum FilterOptions {
  Favourites,
  All,
}

// here a stateful widget is required because we don't want to modify the `items`
// product list in the provider as it will reflect for other screens
// e.g. we search for a product when hitting single product
// and it wont display one if it's not marked as a favourite
// by using a stateful we only modify the list to show favourites for just this screen
class ProductListScreen extends StatefulWidget {
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  var _showOnlyFavourites = false;
  var _initState = true;
  var _isLoading = false;

  @override
  void initState() {
    // you can use Provider.of<ProductProvider>(context).listProducts()
    // if you set listen: false
    super.initState();
  }

  // cannot assign `await` and `async` for `initState()` and `didChangeDependencies()`
  // since they do not return futures
  // therefore you need to use the old approach of `then()`
  @override
  void didChangeDependencies() {
    // forces grabbing data for products to run only once
    // since didChangeDependencies() can run many times on a single screen/page
    if (_initState) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductProvider>(context).listProducts().then((_) {
        // need to update UI with new loading bool with setState()
        setState(() {
          _isLoading = false;
        });
      });
    }
    _initState = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Store'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favourites) {
                  _showOnlyFavourites = true;
                } else {
                  _showOnlyFavourites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favourites'),
                value: FilterOptions.Favourites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<CartProvider>(
            builder: (ctx, cart, child) => Badge(
              child: child,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavourites),
    );
  }
}
