import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';

class SingleProductScreen extends StatelessWidget {
  static const routeName = '/single_product';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    // if listen argument is true (default), it will rebuild the current widget
    // and it's child widgets every time the data in product provider changes
    // if listen argument is false, it will grab the data once and not listen
    // for updated changes
    final productData = Provider.of<ProductProvider>(context, listen: false)
        .findById(productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(productData.name),
      // ),
      // same as SingleChildScrollView() but with more options
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // expandedHeight is the desired height if it's not the app bar but the image
            expandedHeight: 300,
            // pinned true means app bar will always be visible
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(productData.name),
              // background is the content if it's expanded
              // so in this case the image
              background: Hero(
                // same tag as in product_list_item
                tag: productData.id,
                child: Image.network(
                  productData.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 10),
                Text(
                  '\$${productData.price}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    productData.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                SizedBox(height: 800),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
