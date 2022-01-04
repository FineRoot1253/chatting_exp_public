import 'package:badges/badges.dart';
import 'package:chatting_example/controller/chat_controller.dart';
import 'package:chatting_example/controller/user_list_controller.dart';
import 'package:chatting_example/data/model/room_model.dart';
import 'package:chatting_example/data/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserSearchingPage extends StatefulWidget {
  @override
  State<UserSearchingPage> createState() => _UserSearchingPageState();
}

class _UserSearchingPageState extends State<UserSearchingPage> {
  List<SearchListModel> _list = [];
  int selectedCount = 0;

  @override
  void initState() {
    super.initState();
    List<UserModel> userList = Get.arguments;
    userList.forEach((element) {
      if (element.nickName?.isNotEmpty ?? false) {
        _list.add(SearchListModel(userModel: element));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _list.isEmpty
          ? Center(child: Text('유저 초대 불가능'))
          : Scrollbar(
              child: ListView.builder(
                  itemCount: _list.length,
                  itemBuilder: (_, index) {
                    SearchListModel model = _list[index];
                    return ListTile(
                      leading: CircleAvatar(
                          child: Text(model.userModel.nickName?[0] ?? '')),
                      title: Text(model.userModel.nickName ?? ''),
                      trailing: Checkbox(
                        value: model.isSelected,
                        onChanged: (value) {
                          model.isSelected = value ?? false;

                          selectedCount = _list
                              .where((element) => element.isSelected)
                              .length;
                          setState(() {});
                        },
                      ),
                      enabled: false,
                    );
                  }),
            ),
      floatingActionButton: Badge(
        showBadge: selectedCount != 0,
        badgeContent: Text(
          '$selectedCount',
          style: const TextStyle(color: Colors.white),
        ),
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: _addUser,
        ),
      ),
    );
  }

  void _addUser() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text('선택된 유저를 초대하겠습니까?'),
            actions: [
              TextButton(
                child: Text('취소'),
                onPressed: () {
                  Get.back();
                },
              ),
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  List<int> userIdList = [];

                  _list
                      .where((element) => element.isSelected)
                      .forEach((element) {
                    userIdList.add(element.userModel.userId!);
                  });

                  //users, room_state, room_name //todo: room model 추가
                  ChatController.to
                      .sendAddTheseUserMsg(
                          RoomModel(roomUserIdList: userIdList))
                      .whenComplete(() async {
                    await ChatController.to.getMemberList();
                    Get.back();
                    Get.back();
                  });
                },
              ),
            ],
          );
        });
  }
}
