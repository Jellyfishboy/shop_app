import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/single_product.dart';
import '../models/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

// use only Stateful Widgets when the updated data is reflected within in a single Widget (local state)
// if the updated data needs to be reflected across several widgets and/or screens
// use the Consumer() and Provider() logic
class ProductListItem extends StatelessWidget {
  void selectProduct(BuildContext context, String id) {
    Navigator.of(context).pushNamed(
      SingleProductScreen.routeName,
      arguments: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    // the advantage of Provider vs Consumer is you can wrap a specific widget
    // within the widget tree to listen for updates, e.g. a button
    // therefore you can use Provider.of with listen: false to grab the initial data
    // then use Consumer() wrapped around a specific widget in the tree to listen to changes

    final productData = Provider.of<Product>(context, listen: false);
    final cartData = Provider.of<CartProvider>(context, listen: false);
    final authData = Provider.of<AuthProvider>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () => selectProduct(context, productData.id),
          child: Hero(
            // tag is an identifier so the target screen knows which image
            // to use in the transition
            tag: productData.id,
            // FadeInImage sets a placeholder image while waiting
            // for the target image to load
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(productData.imageUrl),
              fit: BoxFit.cover,
              // Image.network(
              //   productData.imageUrl,
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            // make sure not to name builder context same as the context in the Widget build
            // otherwise items such as Theme.of(context) will get incorrect colors
            // child argument allows you to specify an item in your widget which
            // you don't want to rebuild every time you listen and update
            // e.g. a static Text() widget with static text which will never change
            // then you can reference `child` inside the Consumer widget wrapper to
            // the location where that widget resides
            builder: (ctx, productData, child) => IconButton(
              icon: Icon(productData.isFavourite
                  ? Icons.favorite
                  : Icons.favorite_border),
              // label: child,
              onPressed: () => productData.toggleFavouriteStatus(
                authData.token,
                authData.userId,
              ),
              color: Theme.of(context).accentColor,
            ),
            // child: Text('Never changes!'),
          ),
          title: Text(
            productData.name,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cartData.addItem(
                  productData.id, productData.price, productData.name);
              // Scaffold context refs nearest available ScaffoldMessenger() declaration
              // in this example it is product_list.dart
              // can use Scaffold.of(context).openDrawer(), only works if associated
              // ScaffoldMessenger() has a drawer defined
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added to cart!',
                    // textAlign: TextAlign.center,
                  ),
                  duration: Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cartData.removeSingleItem(productData.id);
                    },
                  ),
                ),
              );
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
