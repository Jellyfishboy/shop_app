import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/edit_product.dart';

import '../../widgets/user_product_list_item.dart';
import '../../widgets/app_drawer.dart';

import '../../providers/product.dart';

class UserProductListScreen extends StatelessWidget {
  static const routeName = '/user_products';

  Future<void> _refreshProducts(BuildContext context) async {
    // since the function is async we can set an await
    await Provider.of<ProductProvider>(context, listen: false)
        .listProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: AppDrawer(),
      // RefreshIndicator() allows user to swipe down and refresh data
      // onRefresh has to return a FUTURE
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, productData) =>
            productData.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<ProductProvider>(
                      builder: (ctx, productData, child) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemBuilder: (ctx, index) => Column(
                            children: [
                              UserProductListItem(
                                id: productData.items[index].id,
                                name: productData.items[index].name,
                                imageUrl: productData.items[index].imageUrl,
                              ),
                              Divider()
                            ],
                          ),
                          itemCount: productData.items.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
