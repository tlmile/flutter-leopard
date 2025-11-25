import 'package:flutter/material.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/model/products_repository.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/row_item.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/styles.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key});
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = ProductsRepository.loadProducts()
        .map<Widget>((Product product) => RowItem(product: product))
        .toList();
    return Scaffold(// scaffold 是Material 设计里 一个完整页面的基础结构
      backgroundColor: Styles.scaffoldBackground,
      body: CustomScrollView(//可以放多个 Sliver 组件的可滚动区域容器
        slivers: <Widget>[
          const SliverAppBar(
            title: Text('Material Store',style: Styles.productListTitle,),
            backgroundColor: Styles.scaffoldAppBarBackground,
            pinned: true,//表示sliverappbar在向上滚动时，不会完全溢出 屏幕，而是会吸在顶端
          ),
          SliverList(
            delegate: SliverChildListDelegate(children),
          ),
        ],
      ),
    );
  }
}