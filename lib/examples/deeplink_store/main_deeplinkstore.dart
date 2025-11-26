import 'package:flutter/material.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/ProductList.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/product_category_list.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/product_details.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(DeeplinkStoreApp());

class DeeplinkStoreApp extends StatefulWidget {
  const DeeplinkStoreApp({super.key});

  @override
  State<DeeplinkStoreApp> createState() => _DeeplinkStoreAppState();
}

class _DeeplinkStoreAppState extends State<DeeplinkStoreApp> {
  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const ProductList(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, __) => const ProductDetails(),
          ),
        ],
      ),
      GoRoute(
        path: '/category/:category',
        builder: (_, __) => const ProductCategoryList(),
      ),
    ],
  );

  Future<bool> _handlePop() async {
    if (_router.canPop()) {
      _router.pop();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handlePop,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        routerConfig: _router,
      ),
    );
  }
}
