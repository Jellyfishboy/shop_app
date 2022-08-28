import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit_product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();

  // GlobalKey() allows us to interact with the state of the Form()
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    name: '',
    price: 0.0,
    description: '',
    imageUrl: '',
  );

  // need to set an empty map to accept edit form values
  var _initValues = {
    'name': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    // make sure to dispose listener nodes via dispose()
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // arguments for a Navigator not available inside initState()
    // so need to use didChangeDependencies()
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      // check if a productId exists, before continuing since add product uses same screen
      if (productId != null) {
        final productData = Provider.of<ProductProvider>(context, listen: false)
            .findById(productId);
        _editedProduct = productData;
        _initValues = {
          'name': _editedProduct.name,
          'description': _editedProduct.description,
          // need to set numbers as strings since the TextFieldForm() only accepts strings
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        // if a text field has a controller, you cannot set an initialValue
        // must set it via the controller.text
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    // make sure to set a bool to prevent the above ModalRoute code
    // running more than once
    _isInit = false;
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
  }

  // function to update the image preview if image url present
  // and the image url text field loses focus
  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    // this will trigger validators for all form fields
    // will return true if valid, false if not
    var isValid = _form.currentState.validate();
    // this belong logic will save the form
    // it grabs the value from every TextFormField() child
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      try {
       await Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
              title: Text('An error occurred'),
              content: Text(
                'Something went wrong',
              ),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('Okay'),
                ),
              ]),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    } else {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
              title: Text('An error occurred'),
              content: Text(
                'Something went wrong',
              ),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('Okay'),
                ),
              ]),
        );
        // finally block always runs no matter if the try or catch was triggered
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }

      // since our Future is void in the Product Provider, we still need to accept
      // an argument into the then() function
      // Provider.of<ProductProvider>(context, listen: false)
      //     .addProduct(_editedProduct)
      //     .catchError((error) {
      //   // the then() attached below will only trigger after showDialog() FUTURE
      //   // has resolved, in this instance closed
      //   return showDialog<Null>(
      //     context: context,
      //     builder: (ctx) => AlertDialog(
      //         title: Text('An error occurred'),
      //         content: Text(
      //           'Something went wrong',
      //         ),
      //         actions: [
      //           FlatButton(
      //             onPressed: () {
      //               Navigator.of(ctx).pop();
      //             },
      //             child: Text('Okay'),
      //           ),
      //         ]),
      //   );
      //   // then() AKA a FUTURE will trigger for a successful response or an error response
      // }).then((_) {
      //   // moved Navigator pop() within the Future of addProduct() rather than async
      //   // as previously defined below
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // });
    }

    // goes back to previous screen after submitting form
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                // onWillPop stops the user from exiting the screen the form resides upon
                // onWillPop: () {},
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initValues['name'],
                        // can set error styling via InputDecoration
                        decoration: InputDecoration(
                          labelText: 'Name',
                          errorStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).errorColor,
                          ),
                        ),
                        // changes what button is shown on the mobile keyboard, e.g.
                        // go to next input or submit form
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          // return null; will mean validation has passed
                          // return 'text'; will return the relevant error message
                          if (value.isEmpty) {
                            return 'Please set a product name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          // can create a custom EditProduct model class which allows mutable values
                          // cleaner
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            name: value,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: InputDecoration(
                          labelText: 'Price',
                          errorStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).errorColor,
                          ),
                        ),
                        // changes what button is shown on the mobile keyboard, e.g.
                        // go to next input or submit form
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please set a product price';
                          }
                          // tryParse returns null if not a valid price
                          if (double.tryParse(value) == null) {
                            return 'Please set a valid product price';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please set a price greater than 0';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            name: _editedProduct.name,
                            // need to parse string to double
                            price: double.parse(value),
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration: InputDecoration(
                          labelText: 'Description',
                          errorStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).errorColor,
                          ),
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please set a product description';
                          }
                          if (value.length < 10) {
                            return 'Please set a product description with 10 or more characters';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            name: _editedProduct.name,
                            price: _editedProduct.price,
                            description: value,
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter a URL')
                                : FittedBox(
                                    child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover),
                                  ),
                          ),
                          // TextFormField takes as much width as is available in it's parent widget
                          // if inside a Row() widget that would mean infinite width
                          // so wrap it with an Expanded() widget
                          // Expanded() takes all AVAILABLE space, no more
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Image URL',
                                errorStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).errorColor,
                                ),
                              ),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              // if you have a controller, you cannot set an initial value
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please set a product image';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Please set a valid product image URL';
                                }
                                if (!value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg')) {
                                  return 'Please use a valid file type for the product image URL (png, jpg, jpeg)';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _saveForm(),
                              onEditingComplete: () {
                                setState(() {});
                              },
                              onSaved: (value) {
                                _editedProduct = Product(
                                  id: _editedProduct.id,
                                  name: _editedProduct.name,
                                  price: _editedProduct.price,
                                  description: _editedProduct.description,
                                  imageUrl: value,
                                  isFavourite: _editedProduct.isFavourite,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
