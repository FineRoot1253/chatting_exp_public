import 'dart:convert';

import 'package:chatting_example/data/model/member_model.dart';
import 'package:chatting_example/data/model/result_model.dart';
import 'package:chatting_example/data/model/room_model.dart';
import 'package:chatting_example/data/model/user_model.dart';
import 'package:chatting_example/data/service/api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AccountRepository extends Api {
  AccountRepository(String baseUrl) : super(baseUrl);

  Future<ResultModel> login(String email, String pwd) async {
    String auth = 'Basic ' + base64Encode(utf8.encode('$email:$pwd'));
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    return await super.get("/chat/v1/user/login?user_fcm_token=$fcmToken",
        headerOption: <String, String>{'authorization': auth});
  }

  Future<ResultModel> signUp(UserModel user) async {
    return await super.post("/chat/v1/user/create", data: user);
  }

  Future<ResultModel> checkEmailDuplicate(String emailAddr) async {
    return await super.get("/chat/v1/user/checkEmail?email_addr=$emailAddr");
  }

  Future<ResultModel> getUserList(String userName) async {
    return await super.get("/chat/v1/user/getUserList?nickname=$userName");
  }

  ///미구현 상태, 쓰진 말것
  Future<ResultModel> logout(UserModel user) async {
    return await super.get("/chat/v1/user/logout");
  }
}

class RoomRepository extends Api {
  RoomRepository(String baseUrl) : super(baseUrl);

  ///[방 생성]
  ///users, room_state, room_name, ownerId 필수
  Future<ResultModel> createRoom(RoomModel room) async {
    return await super.post("/chat/v1/room/create", data: room);
  }

  ///[방 내부 인원 리스트 받아오기]
  ///roomId 필수
  Future<ResultModel> getRoomMemberList(int roomId) async {
    return await super.get("/chat/v1/room/findUserListOfRoom?room_id=$roomId");
  }

  ///[방 내부 인원제외 초대가능한 타 인원 리스트 받아오기]
  ///roomId 필수
  Future<ResultModel> getAddableUserList(int roomId) async {
    return await super.get("/chat/v1/room/findAddableUserList?room_id=$roomId");
  }

  ///[방에 유저 초대하기]
  ///users, room_state, room_name 필수
  Future<ResultModel> addMember(RoomModel room) async {
    return await super.post("/chat/v1/room/addMember", data: room);
  }

  ///[유저가 들어가 있는 방 리스트]
  ///userId 필수
  Future<ResultModel> getUserRoomList(int userId) async {
    return await super.get("/chat/v1/room/findRoomListOfUser?user_id=$userId");
  }

  /// [방에서 탈퇴, 완전히 나감]
  /// user_id, room_id, member_id 필수
  /// 안씀
  Future<ResultModel> getUserDisconnectRoom(MemberModel user) async {
    return await super.get("/chat/v1/room/deleteMember");
  }

  /// [유저 재입장, 잠깐 방나갔다가 들어왔을시 채팅 리스트 받아오기]
  /// member_id, room_id 필수
  Future<ResultModel> userEntrance(MemberModel user) async {
    return await super.post("/chat/v1/log/restOfMsg", data: user);
  }

  /// [유저 나가기, 잠깐 방 뒤로 나가기]
  /// member_id, member_state 필수
  Future<ResultModel> userExit(MemberModel user) async {
    return await super.post("/chat/v1/room/updateLastReadMsgIdx", data: user);
  }

  /// [유저 subscribe 완료시 큐 바인딩 요청]
  ///  user_id 필수
  Future<ResultModel> userBind(int userId) async {
    return await super.get("/chat/v1/log/bindUserQueue?user_id=$userId");
  }
}
