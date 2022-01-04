import 'package:badges/badges.dart';
import 'package:chatting_example/controller/home_controller.dart';
import 'package:chatting_example/controller/room_controller.dart';
import 'package:chatting_example/controller/user_count_controller.dart';
import 'package:chatting_example/controller/user_list_controller.dart';
import 'package:chatting_example/data/model/room_model.dart';
import 'package:chatting_example/data/service/mqtt_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserListPage extends StatelessWidget {
  UserListPage({Key? key}) : super(key: key);

  final UserListController _listController = UserListController.to;

  @override
  Widget build(BuildContext context) {
    FocusScopeNode scope = FocusScope.of(context);
    String findName = '';
    return GestureDetector(
      onTap: () {
        if (scope.hasFocus) {
          scope.unfocus();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onSubmitted: (_) async {
                      await _searchUser(findName);
                    },
                    onChanged: (value) {
                      findName = value;
                    },
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await _searchUser(findName);
                  },
                  icon: Icon(Icons.search),
                )
              ],
            ),
            Expanded(
              child: GetBuilder<UserListController>(builder: (controller) {
                return ListView.builder(
                    itemCount: controller.searchList.length,
                    itemBuilder: (_, index) {
                      SearchListModel model = controller.searchList[index];
                      return ListTile(
                        title: Text('${model.userModel.nickName}'),
                        trailing: Checkbox(
                          value: model.isSelected,
                          onChanged: (value) {
                            model.isSelected = value ?? false;
                            UserCountController.to.count =
                                controller.selectedUserCount;

                            controller.update();
                          },
                        ),
                        enabled: false,
                      );
                    });
              }),
            )
          ],
        ),
        floatingActionButton:
            GetBuilder<UserCountController>(builder: (controller) {
          return Badge(
            showBadge: controller.count != 0,
            badgeContent: Text(
              '${controller.count}',
              style: const TextStyle(color: Colors.white),
            ),
            child: FloatingActionButton(
              child: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      String roomTitle = '';
                      return AlertDialog(
                        title: Text('방제목을 입력해주세요'),
                        content: TextField(
                          onChanged: (value) {
                            roomTitle = value;
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('취소'),
                          ),
                          TextButton(
                            onPressed: () async {
                              List<int> userIdList = [
                                HomeController.to.currentUser.userId!
                              ];

                              _listController.searchList
                                  .where((element) => element.isSelected)
                                  .forEach((element) {
                                userIdList.add(element.userModel.userId!);
                              });

                              RoomController roomController = RoomController.to;

                              RoomModel model = await roomController.createRoom(RoomModel(
                                  ownerId: HomeController.to.currentUser.userId,
                                  roomName: roomTitle,
                                  roomState: 1,
                                  roomUserIdList: userIdList));
      MQTTClientWrapper().subscribeToTopic(
                                  '${model.roomId}_u');

                              await roomController.getUserRoomList(
                                  HomeController.to.currentUser.userId!);

                              roomController.update();

                              HomeController.to.onTapPage(1);

                              Navigator.pop(context);
                            },
                            child: Text('방 만들기'),
                          )
                        ],
                      );
                    });
              },
            ),
          );
        }),
      ),
    );
  }

  Future<void> _searchUser(String value) async {
    await _listController.setSearchList(
        value, HomeController.to.currentUser.userId!);
  }
}
