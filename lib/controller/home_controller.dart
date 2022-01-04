import 'package:chatting_example/data/model/user_model.dart';
import 'package:chatting_example/screen/page/chat_room_page.dart';
import 'package:chatting_example/screen/page/user_list_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find<HomeController>();

  final List<Widget> pageList = [UserListPage(), ChatRoomListPage()];

  late UserModel currentUser;

  int pageIndex = 0;

  void onTapPage(int index) {
    pageIndex = index;
    update();
  }
}
