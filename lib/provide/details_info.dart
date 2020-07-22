import 'package:flutter/material.dart';
import '../model/details.dart';
import '../service/service_method.dart';
import 'dart:convert';

class DetailsInfoProvide with ChangeNotifier {
  DetailsModel goodsInfo = null;

  getGoodsInfo(String id) async {
    var formData = {
      'goodId': id,
    };

    await request('getGoodDetailById', formData: formData).then((val) {
      var responseData = json.decode(val.toString());
      // print(responseData);
      goodsInfo = DetailsModel.fromJson(responseData);
      notifyListeners();
    });
  }

  bool isLeft = true;
  bool isRight = false;

  //改变tabBar的状态
  changeLeftAndRight(String changeState) {
    if (changeState == 'left') {
      isLeft = true;
      isRight = false;
    } else {
      isLeft = false;
      isRight = true;
    }
    notifyListeners();
  }
}
