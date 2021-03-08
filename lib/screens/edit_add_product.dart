import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/providers/products_provider.dart';

class UserInput extends StatefulWidget {
  static const routeName = '/add-edit-products';
  final String productId;

  UserInput({this.productId});

  @override
  _UserInputState createState() => _UserInputState();
}

class _UserInputState extends State<UserInput> {
  final _imageUrlFocusNode = FocusNode();
  var _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Map<String, Object>();
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    if (widget.productId != null) {
      final product = Provider.of<Products>(context, listen: false)
          .findById(widget.productId);
      _editedProduct['id'] = product.id;
      _editedProduct['title'] = product.title;
      _editedProduct['price'] = product.price.toString();
      _editedProduct['description'] = product.description;
      _imageUrlController.text = product.imageUrl;
    }
    super.initState();
  }

  void _updateImageUrl() {
    if (_imageUrlController.text.isEmpty ||
        (!_imageUrlController.text.startsWith('http') &&
            !_imageUrlController.text.startsWith('https')) ||
        (!_imageUrlController.text.endsWith('.jpg') &&
            !_imageUrlController.text.endsWith('.jpeg') &&
            !_imageUrlController.text.endsWith('.png') &&
            !_imageUrlController.text.endsWith('.gif'))) {
      return;
    }
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() async {
    setState(() {
      _isLoading = true;
    });
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    if (_editedProduct['id'] != null) {
      var product = Product(
          id: _editedProduct['id'],
          title: _editedProduct['title'],
          description: _editedProduct['description'],
          price: double.parse(_editedProduct['price']),
          imageUrl: _editedProduct['imageURL']);

     try{
       await Provider.of<Products>(context, listen: false)
           .updateProduct(product);
     }catch(error){
       await showDialog(
           context: context,
           builder: (ctx) => AlertDialog(
             title: Text('An error occurred!'),
             content: Text('Something went wrong while updating product'),
             actions: [
               TextButton(
                   onPressed: () {
                     Navigator.of(ctx).pop();
                   },
                   child: Text('Okay'))
             ],
           ));
     }
    } else {
      var product = Product(
          id: DateTime.now().toString(),
          title: _editedProduct['title'],
          description: _editedProduct['description'],
          price: double.parse(_editedProduct['price']),
          imageUrl: _editedProduct['imageURL']);

      try {
        await Provider.of<Products>(context, listen: false).addProduct(product);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occurred!'),
                  content: Text('Something went wrong while adding product'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Okay'))
                  ],
                ));
      }
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_editedProduct['id'] == null ? "Add Product" : "Edit Product"),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _editedProduct['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a value';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct['title'] = value;
                        },
                      ),
                      TextFormField(
                        initialValue: _editedProduct['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a number greater than zero';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct['price'] = value;
                        },
                      ),
                      TextFormField(
                        initialValue: _editedProduct['description'],
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a value';
                          }
                          if (value.length < 10) {
                            return 'Should be at least 10 characters long';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct['description'] = value;
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
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? Center(child: Text("Enter a URL"))
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                                //initialValue: _editedProduct['imageURL'],
                                decoration:
                                    InputDecoration(labelText: 'Image URL'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: _imageUrlController,
                                focusNode: _imageUrlFocusNode,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please provide an image URL';
                                  }
                                  if (!value.startsWith('http') &&
                                      !value.startsWith('https')) {
                                    return 'Please provide a valid image URL';
                                  }
                                  if (!value.endsWith('.png') &&
                                      !value.endsWith('.jpg') &&
                                      !value.endsWith('.jpeg') &&
                                      !value.endsWith('.gif')) {
                                    return 'Please provide a valid image URL';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _saveForm(),
                                onSaved: (value) {
                                  _editedProduct['imageURL'] = value;
                                },
                                onEditingComplete: () {
                                  setState(() {});
                                }),
                          ),
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
