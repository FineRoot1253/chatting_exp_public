import 'package:chatting_example/data/model/result_model.dart';
import 'package:chatting_example/util/constant.dart';
import 'package:intl/intl.dart';
import 'dart:convert' show utf8;

class CommonUtils {
  /// api 콜 결과 체크
  static bool checkResult(ResultModel? rm) {
    bool isOk = false;
    if (rm?.code == CD_OK) {
      isOk = true;
    }
    return isOk;
  }

  static String getDateForm(DateTime dateTime, String format) {
    return DateFormat(format).format(dateTime);
  }

  static List<int> encodeStringToUTF8(String text) {
    return utf8.encode(text);
  }

  static String decodeUTF8ToString(List<int> list) {
    return utf8.decode(list);
  }
}
