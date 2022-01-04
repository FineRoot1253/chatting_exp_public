import 'dart:convert';

class RoomModel {
  final int? ownerId;
  final int? roomId;
  final String? roomName;
  final int? roomState;
  final int? userCount;
  final List<int>? roomUserIdList;
  final DateTime? createDate;

  const RoomModel(
      {
        this.ownerId,
        this.roomId,
      this.roomName,
      this.roomState,
      this.userCount,
      this.roomUserIdList,
      this.createDate});

  factory RoomModel.fromJson(Map<String, dynamic> parsed) {
    return RoomModel(
        ownerId: parsed['owner'],
        roomId: parsed["room_id"],
        roomName: parsed["room_name"],
        roomState: parsed["room_state"],
        userCount: parsed["room_count"],
        roomUserIdList: parsed["users"] ?? [],
        createDate: DateTime.parse(parsed["createat"]));
  }

  List<RoomModel> listFromJson(List<dynamic> list) {
    List<RoomModel> roomList = [];

    list.forEach((element) {
      roomList.add(RoomModel.fromJson(element));
    });

    return roomList;
  }

  Map<String, dynamic> toJson() => {
        "owner" : ownerId,
        "room_id": roomId,
        "room_name": roomName,
        "room_state": roomState,
        "room_count": userCount,
        "users": roomUserIdList,
        "createat": createDate,
      };

  @override
  String toString() => """
  Room(roomId: $roomId, roomName: $roomName, userCount: $userCount ,roomState: $roomState, createDate: $createDate)
  """;
}
