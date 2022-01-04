import 'package:chatting_example/controller/auth_controller.dart';
import 'package:chatting_example/controller/chat_controller.dart';
import 'package:chatting_example/controller/home_controller.dart';
import 'package:chatting_example/controller/room_controller.dart';
import 'package:chatting_example/controller/user_count_controller.dart';
import 'package:chatting_example/controller/user_list_controller.dart';
import 'package:chatting_example/data/repository.dart';
import 'package:chatting_example/util/constant.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => RoomController(repository: RoomRepository(API_BASE_URL)));
    Get.lazyPut(
        () => UserListController(repository: AccountRepository(API_BASE_URL)));
    Get.lazyPut(() => UserCountController());
  }
}

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController(repository: RoomRepository(API_BASE_URL)));
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
        () => AuthController(repository: AccountRepository(API_BASE_URL)));
  }
}

class UserListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
        () => UserListController(repository: AccountRepository(API_BASE_URL)));
  }
}

class PageListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PageListBinding());
  }
}
