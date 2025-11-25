import 'package:flutter/material.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/model/products_repository.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/row_item.dart';
import 'package:flutter_leopard_demo/examples/deeplink_store/styles.dart';
import 'package:go_router/go_router.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = ProductsRepository.loadProducts()
        .map<Widget>((Product product) => RowItem(product: product))
        .toList();
    return Scaffold(// scaffold 是Material 设计里 一个完整页面的基础结构
      backgroundColor: Styles.scaffoldBackground,
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: CustomScrollView(//可以放多个 Sliver 组件的可滚动区域容器
          controller: _scrollController,
          slivers: <Widget>[
            const SliverAppBar(
              title: Text(
                'Material Store',
                style: Styles.productListTitle,
              ),
              backgroundColor: Styles.scaffoldAppBarBackground,
              pinned: true,//表示sliverappbar在向上滚动时，不会完全溢出 屏幕，而是会吸在顶端
            ),
            const SliverPersistentHeader(
              pinned: true,
              delegate: _CategorySelectorHeader(),
            ),
            SliverList(
              delegate: SliverChildListDelegate(children),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector();

  @override
  Widget build(BuildContext context) {
    final List<(String label, VoidCallback onTap)> categories = [
      ('全部', () => context.go('/')),
      ('Accessories', () => context.go('/category/accessories')),
      ('Clothing', () => context.go('/category/clothing')),
      ('Home', () => context.go('/category/home')),
    ];

    return Container(
      color: Styles.scaffoldBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: categories
            .map(
              (category) => ActionChip(
                label: Text(category.$1),
                onPressed: category.$2,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CategorySelectorHeader extends SliverPersistentHeaderDelegate {
  const _CategorySelectorHeader();

  static const double _height = 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return const _CategorySelector();
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
