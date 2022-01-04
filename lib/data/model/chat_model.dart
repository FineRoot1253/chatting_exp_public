import 'package:chatting_example/util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ChatLogModel {
  String? chatId, chatContent;
  int? roomId, userId, chatState, memberId;
  DateTime? createAt;
  LayerLink layerLink = LayerLink();
  GlobalKey key = GlobalKey();

  ChatLogModel(
      {this.memberId,
      this.chatId,
      this.userId,
      this.roomId,
      this.chatState,
      this.chatContent,
      this.createAt});

  factory ChatLogModel.fromJson(Map<String, dynamic> json) => ChatLogModel(
      memberId: json['member_id'],
      userId: json['user_id'] == 0 ? json["User"]['user_id'] : json["user_id"],
      chatId: json['chat_id'],
      roomId: json['room_id'] == 0 ? json["Room"]['room_id'] : json['room_id'],
      chatState: json['chat_state'],
      chatContent: json['chat_content'],
      createAt: DateTime.parse(json['createat']));

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'member_id': memberId,
        'user_id': userId,
        'room_id': roomId,
        'chat_state': chatState,
        'chat_content': chatContent,
        'createat':
            "${CommonUtils.getDateForm(createAt!, 'yyyy-MM-ddTHH:mm:ss')}Z"
      };

  @override
  bool operator ==(Object other) => (identical(this, other) ||
      other is ChatLogModel &&
          this.chatId == other.chatId &&
          this.userId == other.userId &&
          this.roomId == other.roomId &&
          this.chatState == other.chatState &&
          this.chatContent == other.chatContent &&
          this.createAt == other.createAt);

  @override
  int get hashCode => super.hashCode;
}
