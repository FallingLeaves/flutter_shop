import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';
import '../config/service_url.dart';

// 获取首页主题内容
Future getHomePageContent() async {
  try {
    print('开始获取首页数据');
    Response response;
    Dio dio = new Dio();
    dio.options.contentType = Headers.formUrlEncodedContentType;

    var formData = {'lon': '115.02932', 'lat': '35.76189'};

    response = await dio.post(servicePath['homePageContent'], data: formData);

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('后端接口异常');
    }
  } catch (e) {
    return print('ERROR:===$e');
  }
}

// 获取首页火爆商品
Future getHomePageBlewContent() async {
  try {
    print('开始获取首页火爆专区数据');
    Response response;
    Dio dio = new Dio();
    dio.options.contentType = Headers.formUrlEncodedContentType;

    int page = 1;

    response = await dio.post(servicePath['homePageBelowContent'], data: page);

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('后端接口异常');
    }
  } catch (e) {
    return print('ERROR:===$e');
  }
}

Future request(url, {formData}) async {
  try {
    // print('开始获取数据');
    // print(url);
    // print(formData.toString());
    Response response;
    Dio dio = new Dio();
    dio.options.contentType = Headers.formUrlEncodedContentType;
    if (formData == null) {
      response = await dio.post(
        servicePath[url],
      );
    } else {
      response = await dio.post(
        servicePath[url],
        data: formData,
      );
    }

    if (response.statusCode == 200) {
      // print(response.data);
      return response.data;
    } else {
      throw Exception('后端接口异常');
    }
  } catch (e) {
    return print('ERROR:===$e');
  }
}
