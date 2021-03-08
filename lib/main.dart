import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_add_product.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/splashScreen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';
import 'package:shop_app/screens/auth_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products('', '', []),
            update: (ctx, auth, previousProducts) => Products(
                auth.token,
                auth.userId,
                previousProducts.items == null ? [] : previousProducts.items)),
        ChangeNotifierProvider(create: (ctx) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders([], '', ''),
            update: (ctx, auth, previousOrders) => Orders(
                previousOrders.orders == null ? [] : previousOrders.orders,
                auth.token,
                auth.userId))
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shop App',
          theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato'),
          home: authData.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (ctx, authResult) =>
                      authResult.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          onGenerateRoute: (RouteSettings settings) {
            var routeName = settings.name;
            var routeParams = settings.arguments;
            switch (routeName) {
              case ProductsOverviewScreen.routeName:
                return MaterialPageRoute(
                    builder: (ctx) => ProductsOverviewScreen());
              case ProductDetailScreen.routeName:
                return MaterialPageRoute(
                    builder: (ctx) => ProductDetailScreen(
                          id: routeParams,
                        ));
              case CartScreen.routeName:
                return MaterialPageRoute(builder: (ctx) => CartScreen());
              case OrdersScreen.routeName:
                return MaterialPageRoute(builder: (ctx) => OrdersScreen());
              case UserProductsScreen.routeName:
                return MaterialPageRoute(
                    builder: (ctx) => UserProductsScreen());
              case UserInput.routeName:
                return MaterialPageRoute(
                    builder: (ctx) => UserInput(
                          productId: routeParams,
                        ));
              case AuthScreen.routeName:
                return MaterialPageRoute(builder: (ctx) => AuthScreen());
              default:
                return MaterialPageRoute(
                    builder: (ctx) => Scaffold(
                          body: Center(
                            child: Text("error"),
                          ),
                        ));
            }
          },
        ),
      ),
    );
  }
}
