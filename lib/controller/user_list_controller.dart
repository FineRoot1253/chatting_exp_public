import 'package:chatting_example/data/model/result_model.dart';
import 'package:chatting_example/data/model/user_model.dart';
import 'package:chatting_example/data/repository.dart';
import 'package:chatting_example/util/common_util.dart';
import 'package:get/get.dart';

class UserListController extends GetxController {
  static UserListController get to => Get.find<UserListController>();

  final AccountRepository repository;

  UserListController({required this.repository});

  List<SearchListModel> searchList = [];

  Future<void> setSearchList(String userName, int myId) async {
    List<UserModel> list = await searchUserName(userName);

    searchList.clear();

    list.forEach((element) {
      if (element.userId != myId) {
        searchList.add(SearchListModel(userModel: element));
      }
    });
    update();
  }

  Future<List<UserModel>> searchUserName(String userName) async {
    ResultModel result = await repository.getUserList(userName);

    List<UserModel> list = [];
    if (CommonUtils.checkResult(result)) {
      list = UserModel().listFromJson(result.data);
    }
    return list;
  }

  int get selectedUserCount =>
      searchList.where((element) => element.isSelected).length;
}

class SearchListModel {
  UserModel userModel;
  bool isSelected;

  SearchListModel({required this.userModel, this.isSelected = false});
}
