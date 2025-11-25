

import 'package:flutter/material.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/ProductList.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/product_category_list.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/product_details.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(DeeplinkStoreApp());

class DeeplinkStoreApp extends StatelessWidget {
  const DeeplinkStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      routerConfig: GoRouter(
        routes: [
          GoRoute(
              path: '/',
            builder: (_, _)=>const ProductList(),
            routes: [
              GoRoute(path: ':id',builder: (_, _) => const ProductDetails()),
            ],
          ),
          GoRoute(
              path: '/category/:category',
            builder: (_, _) => const ProductCategoryList(),
          ),
        ],
      ),
    );
  }
}