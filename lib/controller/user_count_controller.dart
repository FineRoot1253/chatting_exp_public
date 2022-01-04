import 'package:get/get.dart';

class UserCountController extends GetxController {
  static UserCountController get to => Get.find<UserCountController>();

  int _count = 0;

  int get count => _count;

  set count(int value) {
    _count = value;
    update();
  }
}
