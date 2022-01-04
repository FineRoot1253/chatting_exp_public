class MemberModel {
  final int? memberId;
  final int? userId;
  final int? roomId;
  final int? memberState;
  final String? lastReadMsgIndex;
  final DateTime? createDate;

  const MemberModel(
      {this.memberId,
      this.userId,
      this.roomId,
      this.memberState,
      this.lastReadMsgIndex,
      this.createDate});

  factory MemberModel.fromJson(Map<String, dynamic> parsed) {
    return MemberModel(
        memberId: parsed["member_id"],
        userId: parsed["user_id"],
        roomId: parsed["room_id"],
        memberState: parsed["member_state"],
        lastReadMsgIndex: parsed["member_last_read_msg_index"],
        createDate: DateTime.parse(parsed["createat"]));
  }
  //
  // List<MemberModel> listFromJson(List<dynamic> list) {
  //   List<MemberModel> memberList = [];
  //
  //   list.forEach((element) {
  //     memberList.add(MemberModel.fromJson(element));
  //   });
  //
  //   return memberList;
  // }

  Map<String, dynamic> toJson() => {
        "member_id": memberId,
        "user_id": userId,
        "room_id": roomId,
        "member_state": memberState,
        "member_last_read_msg_index": lastReadMsgIndex,
        "createat": createDate,
      };

  @override
  String toString() => """
  Member(memberId: $memberId, userId: $userId, roomId: $roomId, memberState: $memberState, lastReadMsgIndex: $lastReadMsgIndex, createDate: $createDate)
  """;
}
