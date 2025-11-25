import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/styles.dart';
import 'package:go_router/go_router.dart';

import 'model/products_repository.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentId = GoRouterState.of(context).pathParameters['id']!;
    final Product product = ProductsRepository.loadProduct(
      id: int.parse(currentId),
    );
    return Scaffold(
      body: ListView(
        children: <Widget>[
          ProductPicture(product: product),
          Styles.spacer,
          Text(product.name, style: Styles.productPageItemName),
          Styles.spacer,
          Text('\$${product.price}', style: Styles.productPageItemPrice),
          Styles.largeSpacer,
        ],
      ),
    );
  }
}

class ProductPicture extends StatelessWidget {
  const ProductPicture({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Image.asset(
              product.assetName2X,
              package: product.assetPackage,
              fit: BoxFit.cover,
              width: constraints.maxWidth,
            );
          },
        ),
      ],
    );
  }
}
