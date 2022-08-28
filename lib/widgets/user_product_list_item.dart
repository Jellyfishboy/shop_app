import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product.dart';

import '../providers/product.dart';

class UserProductListItem extends StatelessWidget {
  final String id;
  final String name;
  final String imageUrl;

  UserProductListItem({
    @required this.id,
    @required this.name,
    @required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      leading: CircleAvatar(
        // cannot use Image.network with backgroundImage, need to use image provider
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Row(
        // if you set have a Row() inside a trailing property, use the MainAxisSize.min
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(
                EditProductScreen.routeName,
                arguments: id,
              );
            },
            color: Theme.of(context).primaryColor,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              try {
                await Provider.of<ProductProvider>(context, listen: false)
                    .deleteProduct(id);
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Deleting failed',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
            },
            color: Theme.of(context).errorColor,
          ),
        ],
      ),
    );
  }
}
