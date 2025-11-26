

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
    final router = GoRouter(
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

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      routerConfig: router,
      builder: (context, child) {
        return WillPopScope(
          onWillPop: () async {
            final NavigatorState rootNavigator =
            Navigator.of(context, rootNavigator: true);

            if (rootNavigator.canPop()) {
              rootNavigator.pop();
              return false;
            }

            return true;
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
