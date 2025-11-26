
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/row_item.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/styles.dart';

import 'model/products_repository.dart';

class ProductCategoryList extends StatefulWidget {
  const ProductCategoryList({super.key});

  @override
  State<ProductCategoryList> createState() => _ProductCategoryListState();
}

class _ProductCategoryListState extends State<ProductCategoryList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Styles.scaffoldBackground,
        body: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: CustomScrollView(
            controller: _scrollController,
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
      ),
    );
  }
}
