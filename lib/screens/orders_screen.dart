import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = "/orders";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    // final orders = Provider.of<Orders>(context, listen: false).orders.length;
    // if (orders == 0) {
    //   _isLoading = true;
    //   Provider.of<Orders>(context, listen: false)
    //       .fetchAndSetOrders()
    //       .then((value) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }).catchError((error) {
    //     setState(() {
    //       _isLoading = false;
    //       _isError = true;
    //     });
    //   });
    // }
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Your orders"),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: _ordersFuture,
            builder: (ctx, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (dataSnapshot.error != null) {
                  return Center(
                    child: Text(
                      "something went wrong",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                } else {
                  return Consumer<Orders>(
                    builder: (ctx, orderData, child) => orderData.orders.length > 0 ? ListView.builder(
                        itemCount: orderData.orders.length,
                        itemBuilder: (ctx, index) =>
                            OrderItem(orderData.orders[index])) :Center(
                      child: Text(
                        "No orders found",
                        style: TextStyle(fontSize: 18),
                      ),
                    ) ,
                  );
                }
              }
            }));
  }
}
