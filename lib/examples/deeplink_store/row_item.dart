
import 'package:flutter/material.dart';
import 'model/products_repository.dart';

import 'package:go_router/go_router.dart';
import 'styles.dart';

class RowItem extends StatelessWidget {
  const RowItem({super.key, required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) {
    return ListTile(//返回列表项 有几个固定位置leading最左边，放头像 缩略图等；title主标题，subtitle副标题； trailing最右边箭头价格按钮等
      shape: const Border.symmetric( //横向分割线 上下分割线 symmetric表示只在上下两条线加边
        horizontal: BorderSide(//指定分割线的颜色
          color: Styles.productRowDivider,
        ),
      ),
      leading: ClipRRect(//leading是最左边；cliprrect表示做圆角裁剪
        borderRadius: BorderRadius.circular(4),//四个角都是像素的圆角
        child: Image.asset(//从本地assets目录加载本地资源
          product.assetName,
          fit: BoxFit.cover,//等比例填充满 width height指定的区域
          width: 68,
          height: 68,
        ),
      ),
      title: Text(product.name,style: Styles.productRowItemName,),
      subtitle: Text('\$${product.price}',style: Styles.productRowItemPrice,),
      onTap: ()=> context.push('/${product.id}'),//点击跳转到详情页面
    );
  }
}