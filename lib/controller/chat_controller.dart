import 'dart:convert';

import 'package:chatting_example/controller/home_controller.dart';
import 'package:chatting_example/controller/room_controller.dart';
import 'package:chatting_example/data/model/chat_model.dart';
import 'package:chatting_example/data/model/member_model.dart';
import 'package:chatting_example/data/model/result_model.dart';
import 'package:chatting_example/data/model/room_model.dart';
import 'package:chatting_example/data/model/user_model.dart';
import 'package:chatting_example/data/repository.dart';
import 'package:chatting_example/data/service/mqtt_wrapper.dart';
import 'package:chatting_example/screen/chat/chat_bubble.dart';
import 'package:chatting_example/util/common_util.dart';
import 'package:chatting_example/util/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find<ChatController>();

  RoomRepository repository;

  ChatController({required this.repository});
  OverlayEntry? overlayEntry;
  List<ChatLogModel> chatList = [];

  List<UserModel> userList = [];
  Map<String, dynamic> mmm = {};
  late int roomId;
  late int userId;
  late int memberId;

  /// 초기화 동작
  /// member list, chat list가져옴
  Future<void> initChattingRoom() async {
    await getMemberList();

    await userEntrance(MemberModel(roomId: roomId, memberId: memberId));
    return;
  }

  /// 방 입장
  Future<void> userEntrance(MemberModel model) async {
    ResultModel result = await repository.userEntrance(model);
    print('entrance : ${result.data}');
    if (CommonUtils.checkResult(result)) {
      List<dynamic> list = result.data;
      Box box = Hive.box(HIVE_CHAT_LOG_BOX);
      List jsonList;

      /// sum용 맵 변수
      /// 1) hive에 저장되어있는 map이 있는지 검사한다.
      /// 2.1) 저장된 데이터가 있으면 지금 받아온 채팅로그 리스트의 엔트리를 저장되있던 map데이터에 더해서 저장해준다. (addEntries)
      /// 2.2) 저장된 데이터가 없으면 그냥 지금 받아온 채팅로그 리스트를 map으로 만든다.
      /// 3) this.chatList에 넣는다.
      /// 4) 2) 항목에서 저장한 map을 hive에 저장한다.
      Map<String, dynamic> mapTemp = Map.fromIterable(list,
          key: (element) => element["chat_id"],
          value: (element) => jsonEncode(element));

      /// 1)
      String? storedJsonListString = box.get("${model.roomId}");

      /// 2.1)
      if (storedJsonListString != null) {
        mmm = jsonDecode(storedJsonListString);
        mmm.addEntries(mapTemp.entries);
      } else {
        /// 2.2)
        mmm = mapTemp;
      }

      /// 3)
      this.chatList = mmm.entries
          .map((element) => ChatLogModel.fromJson(jsonDecode(element.value)))
          .toList();

      /// 4)
      await Hive.box(HIVE_CHAT_LOG_BOX).put("${model.roomId}", jsonEncode(mmm));
    }
  }

  /// 방 내부인원 리스트
  Future<void> getMemberList() async {
    ResultModel result = await repository.getRoomMemberList(roomId);
    if (CommonUtils.checkResult(result)) {
      userList = UserModel().listFromJson(result.data ?? []);
      memberId =
          userList.singleWhere((element) => element.userId == userId).memberId!;
    }
  }

  /// 방 내부인원 제외 초대 가능 유저
  Future<List<UserModel>> getAddableUserList() async {
    ResultModel result = await repository.getAddableUserList(roomId);

    List<UserModel> list = [];
    if (CommonUtils.checkResult(result)) {
      list = UserModel().listFromJson(result.data);
    }

    return list;
  }

  /// 유저 초대
  /// 사용 안함
  Future<void> addMember(RoomModel model) async {
    // ResultModel result = await repository.addMember(model);
    // if (CommonUtils.checkResult(result)) {}
  }

  /// 방 탈퇴 및 나감
  /// 안됨!
  Future<void> getUserDisconnectRoom() async {
    ResultModel result = await repository.getUserDisconnectRoom(
        MemberModel(userId: userId, memberId: memberId, roomId: roomId));
    if (CommonUtils.checkResult(result)) {}
  }

  /// 뒤로가기
  Future<void> userExit() async {
    await Hive.box(HIVE_CHAT_LOG_BOX).put("$roomId", jsonEncode(mmm));

    ResultModel result = await repository
        .userExit(MemberModel(memberId: memberId, memberState: 1));
    if (CommonUtils.checkResult(result)) {
      RoomController.to
          .getUserRoomList(HomeController.to.currentUser.userId!)
          .whenComplete(() {
        RoomController.to.update();
      });
    }
  }

  Future<void> sendRemoveThisMsg(int index) async {
    /// 1) 모든 사람에게 내 msg 삭제하게 해달라는 요청
    MQTTClientWrapper().publishMessage(
        '$roomId',
        ChatLogModel(
            chatContent: '',
            roomId: roomId,
            userId: userId,
            memberId: memberId,
            chatState: ChatState.Remove_To_All_Msg.index,
            chatId: this.chatList[index].chatId,
            createAt: DateTime.now()));
  }

  Future<void> sendDisconnectRoomMsg() async {
    /// 2) 유저 방 탈퇴 요청
    MQTTClientWrapper().publishMessage(
        '$roomId',
        ChatLogModel(
            chatContent: '',
            roomId: roomId,
            userId: userId,
            memberId: memberId,
            chatState: ChatState.User_Room_Exit_Msg.index,
            chatId: '${roomId}_${memberId}_${DateTime.now()}',
            createAt: DateTime.now()));
  }

  Future<void> sendAddTheseUserMsg(RoomModel model) async {
    /// 3) 유저 새로 추가 요청
    MQTTClientWrapper().publishMessage(
        '$roomId',
        ChatLogModel(
            chatContent: jsonEncode(model.toJson()),
            roomId: roomId,
            userId: userId,
            memberId: memberId,
            chatState: ChatState.User_Room_Add_Msg.index,
            chatId: '${roomId}_${memberId}_${DateTime.now()}',
            createAt: DateTime.now()));
  }

  void removeChatInList(String chatId, String jsonStringData) async {
    mmm[chatId] = jsonStringData;
    this.chatList = mmm.entries
        .map((element) => ChatLogModel.fromJson(jsonDecode(element.value)))
        .toList();
    debugPrint(mmm.toString());
    Hive.box(HIVE_CHAT_LOG_BOX).put("$roomId", jsonEncode(mmm));
  }

  Future<void> refreshUserList(String chatId, String jsonStringData) async {
    await getMemberList();
  }
}
