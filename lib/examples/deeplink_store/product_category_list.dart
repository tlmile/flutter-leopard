
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/row_item.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/styles.dart';

import 'model/products_repository.dart';

class ProductCategoryList extends StatelessWidget {
  const ProductCategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    final Category category = Category.values.firstWhere(
          (Category value) =>
          value.toString().contains(state.pathParameters['category']!),
      orElse: () => Category.all,
    );
    final List<Widget> children = ProductsRepository.loadProducts(
      category: category,
    ).map<Widget>((Product p) => RowItem(product: p)).toList();
    return Scaffold(
      backgroundColor: Styles.scaffoldBackground,
      body: Scrollbar(
        thumbVisibility: true,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: Text(
                getCategoryTitle(category),
                style: Styles.productListTitle,
              ),
              backgroundColor: Styles.scaffoldAppBarBackground,
              pinned: true,
            ),
            SliverList(delegate: SliverChildListDelegate(children)),
          ],
        ),
      ),
    );
  }
}
