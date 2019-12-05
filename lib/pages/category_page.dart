import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../service/service_method.dart';
import 'dart:convert';
import '../model/category.dart';
import '../model/categotyGoodsList.dart';
import 'package:provide/provide.dart';
import '../provide/child_category.dart';
import '../provide/category_goods_list.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '商品分类',
        ),
      ),
      body: Container(
        child: Row(
          children: <Widget>[
            LeftCategoryNav(),
            Column(
              children: <Widget>[
                RightCategory(),
                CategoryGoodsList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 左侧导航
class LeftCategoryNav extends StatefulWidget {
  @override
  _LeftCategoryNavState createState() => _LeftCategoryNavState();
}

class _LeftCategoryNavState extends State<LeftCategoryNav> {
  List list = [];
  var listIndex = 0;

  @override
  void initState() {
    _getCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(180),
      decoration: BoxDecoration(
        border: Border(
            right: BorderSide(
          width: 1,
          color: Colors.black12,
        )),
      ),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _leftInkWell(list, index);
        },
      ),
    );
  }

  Widget _leftInkWell(List list, int index) {
    bool isClick = false;
    isClick = index == listIndex ? true : false;
    return InkWell(
      onTap: () {
        setState(() {
          listIndex = index;
        });
        var childCategory = list[index].bxMallSubDto;
        var categoryId = list[index].mallCategoryId;
        Provide.value<ChildCategory>(context)
            .getChildCategory(childCategory, categoryId);

        _getGoodsList(categoryId: categoryId);
      },
      child: Container(
        height: ScreenUtil().setHeight(100),
        padding: EdgeInsets.only(
          left: 10.0,
          top: 15.0,
        ),
        decoration: BoxDecoration(
          color: isClick
              ? Color.fromRGBO(
                  236,
                  236,
                  236,
                  1.0,
                )
              : Colors.white,
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: Colors.black12,
            ),
          ),
        ),
        child: Text(
          list[index].mallCategoryName,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
          ),
        ),
      ),
    );
  }

  void _getCategory() async {
    await request('getCategory').then((val) {
      var data = json.decode(val.toString());

      CategoryModel category = CategoryModel.fromJson(data);
      setState(() {
        list = category.data;
      });
      // 首次右侧子类别为空问题
      Provide.value<ChildCategory>(context)
          .getChildCategory(list[0].bxMallSubDto, list[0].mallCategoryId);

      var categoryId = list[listIndex].mallCategoryId;

      _getGoodsList(categoryId: categoryId);
    });
  }

  void _getGoodsList({String categoryId}) async {
    var data = {
      'categoryId':
          categoryId == null ? list[listIndex].mallCategoryId : categoryId,
      'categorySubId': '',
      'page': 1,
    };

    await request(
      'getMallGoods',
      formData: data,
    ).then((val) {
      var data = json.decode(val.toString());

      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);

      Provide.value<CategoryGoodsListProvide>(context)
          .getGoodsList(goodsList.data);
    });
  }
}

// 右侧子类
class RightCategory extends StatefulWidget {
  @override
  _RightCategoryState createState() => _RightCategoryState();
}

class _RightCategoryState extends State<RightCategory> {
  @override
  Widget build(BuildContext context) {
    return Provide<ChildCategory>(
      builder: (context, child, childCategory) {
        return Container(
          height: ScreenUtil().setHeight(80),
          width: ScreenUtil().setWidth(570),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: Colors.grey,
              ),
            ),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: childCategory.childCategoryList.length,
            itemBuilder: (context, index) {
              return _rightInkWell(
                  childCategory.childCategoryList[index], index);
            },
          ),
        );
      },
    );
  }

  Widget _rightInkWell(BxMallSubDto item, int index) {
    bool isClick = false;
    isClick = index == Provide.value<ChildCategory>(context).childIndex
        ? true
        : false;
    return InkWell(
      onTap: () {
        Provide.value<ChildCategory>(context)
            .changeChildIndex(index, item.mallSubId);
        _getGoodsList(item.mallSubId);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(
          5.0,
          10.0,
          5.0,
          10.0,
        ),
        child: Text(
          item.mallSubName,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
            color: isClick ? Colors.pink : Colors.black,
          ),
        ),
      ),
    );
  }

  void _getGoodsList(String categorySubId) async {
    var data = {
      'categoryId': Provide.value<ChildCategory>(context).categoryId,
      'categorySubId': categorySubId,
      'page': 1,
    };

    await request(
      'getMallGoods',
      formData: data,
    ).then((val) {
      var data = json.decode(val.toString());

      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);

      if (goodsList.data == null) {
        Provide.value<CategoryGoodsListProvide>(context).getGoodsList([]);
      } else {
        Provide.value<CategoryGoodsListProvide>(context)
            .getGoodsList(goodsList.data);
      }
    });
  }
}

// 商品列表
class CategoryGoodsList extends StatefulWidget {
  @override
  _CategoryGoodsListState createState() => _CategoryGoodsListState();
}

class _CategoryGoodsListState extends State<CategoryGoodsList> {
  @override
  void initState() {
    super.initState();
  }

  GlobalKey<RefreshFooterState> _footerkey =
      new GlobalKey<RefreshFooterState>();

  var scrollContraler = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Provide<CategoryGoodsListProvide>(
      builder: (context, child, data) {
        try {
          if (Provide.value<ChildCategory>(context).page == 1) {
            // 列表位置最上
            scrollContraler.jumpTo(0.0);
          }
        } catch (e) {
          print('第一次进入页面:$e');
        }
        if (data.goodsList.length > 0) {
          return Expanded(
            child: Container(
              width: ScreenUtil().setWidth(570),
              // height: ScreenUtil().setHeight(980),
              child: EasyRefresh(
                  refreshFooter: ClassicsFooter(
                    key: _footerkey,
                    bgColor: Colors.white,
                    textColor: Colors.pink,
                    moreInfoColor: Colors.pink,
                    showMore: true,
                    noMoreText:
                        Provide.value<ChildCategory>(context).noMoreText,
                    moreInfo: '加载中',
                    loadReadyText: '上拉加载',
                  ),
                  child: ListView.builder(
                    controller: scrollContraler,
                    itemCount: data.goodsList.length,
                    itemBuilder: (context, index) {
                      return _listItem(data.goodsList, index);
                    },
                  ),
                  loadMore: () async {
                    print('上拉加载');
                    _getMoreGoodsList();
                  }),
            ),
          );
        } else {
          return Text('暂无数据');
        }
      },
    );
  }

  void _getMoreGoodsList() async {
    Provide.value<ChildCategory>(context).addPage();
    var data = {
      'categoryId': Provide.value<ChildCategory>(context).categoryId,
      'categorySubId': Provide.value<ChildCategory>(context).subId,
      'page': Provide.value<ChildCategory>(context).page,
    };

    await request(
      'getMallGoods',
      formData: data,
    ).then((val) {
      var data = json.decode(val.toString());

      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);

      if (goodsList.data == null) {
        Provide.value<ChildCategory>(context).changeNoMoreText('没有更多了!');
        Fluttertoast.showToast(
          msg: '已经到底了!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.pink,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Provide.value<CategoryGoodsListProvide>(context)
            .getMoreGoodsList(goodsList.data);
      }
    });
  }

  Widget _goodsImage(List list, int index) {
    return Container(
      width: ScreenUtil().setWidth(200),
      child: Image.network(
        list[index].image,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _goodsName(List list, int index) {
    return Container(
      padding: EdgeInsets.all(5.0),
      width: ScreenUtil().setWidth(360),
      child: Text(
        list[index].goodsName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(28),
        ),
      ),
    );
  }

  Widget _goodsPrice(List list, int index) {
    return Container(
      margin: EdgeInsets.only(
        top: 20.0,
        left: 5.0,
      ),
      width: ScreenUtil().setWidth(350),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '价格:￥${list[index].presentPrice}',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: Colors.pink,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '价格:￥${list[index].oriPrice}',
              style: TextStyle(
                color: Colors.black26,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listItem(List list, int index) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.only(
          top: 5.0,
          bottom: 5.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              width: 1.0,
              color: Colors.black12,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            _goodsImage(list, index),
            Column(
              children: <Widget>[
                _goodsName(list, index),
                _goodsPrice(list, index),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
