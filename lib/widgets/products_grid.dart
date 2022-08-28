import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './product_list_item.dart';
import '../providers/product.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavourites;

  ProductsGrid(this.showOnlyFavourites);

  @override
  Widget build(BuildContext context) {
    // listen to a provider class using Provider.of(context)
    // the widget which is listening and all their child widgets
    // will rebuild if the provider class data/state changes
    // for example product_list.dart will not rebuild as it's a parent without a listener
    // use <> after of to set the provider class
    final productsData = Provider.of<ProductProvider>(context);
    final products = productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemBuilder: (context, index) {
        return ChangeNotifierProvider.value(
          value: products[index],
          child: ProductListItem(),
        );
      },
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
