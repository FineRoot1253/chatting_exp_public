import 'package:chatting_example/controller/chat_controller.dart';
import 'package:chatting_example/data/model/chat_model.dart';
import 'package:chatting_example/data/service/mqtt_wrapper.dart';
import 'package:chatting_example/screen/chat/chat_bubble.dart';
import 'package:flutter/material.dart';


class SendWidget extends StatefulWidget {
  final FocusScopeNode scope;

  SendWidget(this.scope);

  @override
  _SendWidgetState createState() => _SendWidgetState();
}

class _SendWidgetState extends State<SendWidget> {
  TextEditingController _tController = TextEditingController();
  final ChatController _chatController = ChatController.to;

  @override
  void dispose() {
    _tController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 12),
        title: TextField(
            controller: _tController,
            style: const TextStyle(color: Colors.black),
            minLines: 1,
            maxLines: 4,
            maxLength: 200,
            buildCounter: (BuildContext context,
                    {int? currentLength, int? maxLength, bool? isFocused}) =>
                null,
            decoration:
                InputDecoration(hintText: 'Reply...', border: InputBorder.none),
            onSubmitted: (value) => _sendMessage()),
        trailing: Container(
          height: double.maxFinite,
          color: Colors.grey,
          child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage),
        ),
      ),
    );
  }

  void _sendMessage() {
    if (widget.scope.hasFocus) {
      widget.scope.unfocus();
    }

    if (_tController.text.isEmpty) {
      return;
    }

    MQTTClientWrapper().publishMessage(
        '${_chatController.roomId}',
        ChatLogModel(
            chatContent: _tController.text,
            roomId: _chatController.roomId,
            userId: _chatController.userId,
            memberId: _chatController.memberId,
            chatState: ChatState.Normal.index,
            chatId:
                '${_chatController.roomId}_${_chatController.memberId}_${DateTime.now()}',
            createAt: DateTime.now()));

    _tController.clear();
  }
}
