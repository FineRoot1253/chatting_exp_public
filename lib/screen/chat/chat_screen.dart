import 'dart:async';
import 'dart:convert';

import 'package:chatting_example/controller/chat_controller.dart';
import 'package:chatting_example/controller/home_controller.dart';
import 'package:chatting_example/controller/room_controller.dart';
import 'package:chatting_example/data/model/chat_model.dart';
import 'package:chatting_example/data/model/user_model.dart';
import 'package:chatting_example/data/service/mqtt_wrapper.dart';
import 'package:chatting_example/route/route_const.dart';
import 'package:chatting_example/screen/chat/chat_bubble.dart';
import 'package:chatting_example/screen/chat/chat_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';

class ChattingScreen extends StatefulWidget {
  ChattingScreen({Key? key}) : super(key: key);

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  final ChatController _controller = ChatController.to;
  late final Future<void> _future;
  StreamSubscription? _stream;

  @override
  void initState() {
    super.initState();
    _controller.roomId = Get.arguments;
    _controller.userId = HomeController.to.currentUser.userId!;

    _future = _controller.initChattingRoom();

    _stream = MQTTClientWrapper().getStream?.listen((event) {
      final recMess = event![0].payload as MqttPublishMessage;

      final pt = utf8.decode(recMess.payload.message.toList());
      debugPrint(
          '[Mosquitto] Change notification:: topic is <${event[0].topic}>, payload is <-- $pt -->');

      ChatLogModel recvChat = ChatLogModel.fromJson(jsonDecode(pt));

      switch (ChatState.values[recvChat.chatState!]) {
        case ChatState.Remove_To_All_Msg:
          _controller.removeChatInList(recvChat.chatId!, pt);
          break;
        case ChatState.User_Room_Add_Msg:
          _controller.getMemberList();
          break;
        case ChatState.User_Room_Exit_Msg:
          if (recvChat.memberId == _controller.memberId) {
            RoomController.to
                .getUserRoomList(HomeController.to.currentUser.userId!)
                .whenComplete(() {
              RoomController.to.update();
              Get.close(2);
            });
          } else {
            _controller.getMemberList();
          }
          break;
        default:
          _controller.chatList.add(recvChat);
          _controller.mmm.addEntries({
            recvChat.chatId.toString(): jsonEncode(recvChat.toJson())
          }.entries);
          debugPrint("현재 MMM :: ${_controller.mmm}");
          break;
      }
      _controller.update();
    });
  }

  @override
  void dispose() {
    _stream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[log] room id : ${_controller.roomId}');
    final FocusScopeNode scope = FocusScope.of(context);
    return WillPopScope(
      onWillPop: () async {
        if (ChatController.to.overlayEntry != null &&
            ChatController.to.overlayEntry!.mounted) {
          ChatController.to.overlayEntry?.remove();
        }
        _controller.userExit().whenComplete(() {
          return true;
        });

        return true;
      },
      child: SafeArea(
        child: FutureBuilder<void>(
            future: _future,
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text('User name'),
                  ),
                  endDrawer: Drawer(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.person_add_alt),
                          title: Text('유저 초대'),
                          onTap: () {
                            _controller.getAddableUserList().then((value) {
                              Get.toNamed(RouteName.UserSearching,
                                  arguments: value);
                            });
                          },
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: _controller.userList.length,
                              itemBuilder: (_, index) {
                                UserModel model = _controller.userList[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text('${model.nickName}'),
                                );
                              }),
                        ),
                        ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('나가기'),
                          onTap: _exitRoom,
                        )
                      ],
                    ),
                  ),
                  body: GestureDetector(
                    onTap: () {
                      debugPrint("탭!");
                      if (ChatController.to.overlayEntry != null &&
                          ChatController.to.overlayEntry!.mounted) {
                        ChatController.to.overlayEntry?.remove();
                        return;
                      }
                    },
                    child: SafeArea(
                      child: Container(
                        color: Colors.grey[200],
                        child: Column(children: [
                          Expanded(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                if (scope.hasFocus) {
                                  scope.unfocus();
                                }
                                if (ChatController.to.overlayEntry != null &&
                                    ChatController.to.overlayEntry!.mounted) {
                                  ChatController.to.overlayEntry?.remove();
                                }
                              },
                              child: GetBuilder<ChatController>(builder: (_) {
                                return ListView.builder(
                                    itemCount: _controller.chatList.length,
                                    itemBuilder: (_, index) {
                                      ChatLogModel model =
                                          _controller.chatList[index];
                                      return ChatBubble(
                                          user:
                                              '${_controller.userList.singleWhere((element) => element.userId == model.userId).nickName}',
                                          message: '${model.chatContent}',
                                          index: index,
                                          isOwner: model.userId ==
                                              _controller.userId);
                                    });
                              }),
                            ),
                          ),
                          SendWidget(scope)
                        ]),
                      ),
                    ),
                  ),
                );
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }

  void _exitRoom() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text('방에서 나가시겠습니까?'),
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
                  _controller.sendDisconnectRoomMsg();
                  Get.back();
                },
              ),
            ],
          );
        });
  }

  // void _publish() {
  //   /// 1) 모든 사람에게 내 msg 삭제하게 해달라는 요청
  //   MQTTClientWrapper().publishMessage(
  //       '${_controller.roomId}',
  //       ChatLogModel(
  //           chatContent: '',
  //           roomId: _controller.roomId,
  //           userId: _controller.userId,
  //           memberId: _controller.memberId,
  //           chatState: ChatState.Remove_To_All_Msg.index,
  //           chatId:
  //               '${_controller.roomId}_${_controller.memberId}_${DateTime.now()}',
  //           createAt: DateTime.now()));

  //   /// 2) 유저 방 탈퇴 요청
  //   MQTTClientWrapper().publishMessage(
  //       '${_controller.roomId}',
  //       ChatLogModel(
  //           chatContent: '',
  //           roomId: _controller.roomId,
  //           userId: _controller.userId,
  //           memberId: _controller.memberId,
  //           chatState: ChatState.User_Room_Exit_Msg.index,
  //           chatId:
  //               '${_controller.roomId}_${_controller.memberId}_${DateTime.now()}',
  //           createAt: DateTime.now()));

  //   /// 3) 유저 새로 추가 요청
  //   // MQTTClientWrapper().publishMessage(
  //   //     '${_controller.roomId}',
  //   //     ChatLogModel(
  //   //         chatContent: jsonEncode({"users": userList}),
  //   //         roomId: _controller.roomId,
  //   //         userId: _controller.userId,
  //   //         memberId: _controller.memberId,
  //   //         chatState: ChatState.User_Room_Add_Msg.index,
  //   //         chatId:
  //   //             '${_controller.roomId}_${_controller.memberId}_${DateTime.now()}',
  //   //         createAt: DateTime.now()));

  //   _controller.update();
  // }
}
