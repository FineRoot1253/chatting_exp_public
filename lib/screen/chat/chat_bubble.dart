import 'package:chatting_example/controller/chat_controller.dart';
import 'package:flutter/material.dart';

enum ChatState {
  /// 일반 메시지
  Normal,

  /// 나에게서만 안보이게 하기 [미구현]
  Remove_Only_Me_Msg,

  /// 남들한테 않보이게 하기
  Remove_To_All_Msg,

  /// 방 나가기
  User_Room_Exit_Msg,

  /// 새 유저 추가됨
  User_Room_Add_Msg,

  /// 이미지 [미구현] (누가 S3 사줘잉)
  Image_Msg,

  /// 이모티콘 [미구현]
  Imoticon_Msg
}

class ChatBubble extends StatefulWidget {
  ChatBubble(
      {Key? key,
      required this.user,
      required this.message,
      required this.index,
      required this.isOwner})
      : super(key: key);

  final String user, message;
  final int index;
  final bool isOwner;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ChatController.to.chatList[widget.index].key,
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
      child: widget.isOwner
          ? GestureDetector(
              onLongPress: () {
                _showMenu();
              },
              child: CompositedTransformTarget(
                link: ChatController.to.chatList[widget.index].layerLink,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [_textWidget()],
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(child: Text(widget.user[0])),
                const SizedBox(width: 10),
                _textWidget()
              ],
            ),
    );
  }

  Widget _textWidget() {
    return Flexible(
      child: Card(
          color: widget.isOwner ? Colors.blue.shade100 : Colors.grey.shade100,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChatController.to.chatList[widget.index].chatState !=
                    ChatState.Remove_To_All_Msg.index
                ? Text(widget.message, maxLines: 3)
                : Text(
                    '삭제된 메시지입니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
          )),
    );
  }

  void _showMenu() {
    if (ChatController.to.overlayEntry != null &&
        ChatController.to.overlayEntry!.mounted) {
      ChatController.to.overlayEntry?.remove();
      return;
    }
    RenderBox? renderBox = ChatController
        .to.chatList[widget.index].key.currentContext
        ?.findRenderObject() as RenderBox?;
    var size = renderBox?.size;

    debugPrint("오버레이 열림, : ${size?.width}");

    ChatController.to.overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        width: (size?.width ?? 0) * 0.3,
        // height: (size?.width ?? 0) * 3,
        child: CompositedTransformFollower(
          link: ChatController.to.chatList[widget.index].layerLink,
          showWhenUnlinked: false,
          offset: Offset((size?.width ?? 0) * 0.65, (size?.height ?? 0) + 5.0),
          child: Material(
            elevation: 4.0,
            child: TextButton(
              child: Text("삭제하기"),
              onPressed: () {
                ChatController.to.sendRemoveThisMsg(widget.index);
                if (ChatController.to.overlayEntry != null &&
                    ChatController.to.overlayEntry!.mounted) {
                  ChatController.to.overlayEntry?.remove();
                  return;
                }
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context)?.insert(ChatController.to.overlayEntry!);
  }
}
