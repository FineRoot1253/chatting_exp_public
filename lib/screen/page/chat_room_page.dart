import 'package:chatting_example/controller/home_controller.dart';
import 'package:chatting_example/controller/room_controller.dart';
import 'package:chatting_example/data/model/room_model.dart';
import 'package:chatting_example/data/service/mqtt_wrapper.dart';
import 'package:chatting_example/main.dart';
import 'package:chatting_example/route/route_const.dart';
import 'package:chatting_example/util/common_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class ChatRoomListPage extends StatefulWidget {
  @override
  State<ChatRoomListPage> createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<ChatRoomListPage> {
  late final Future<bool> future;

  @override
  void initState() {
    super.initState();

    future = RoomController.to
        .getUserRoomList(HomeController.to.currentUser.userId!)
        .whenComplete(() {
      RoomController.to.roomList.forEach((element) {
        MQTTClientWrapper().subscribeToTopic('${element.roomId}_u');
      });

      // RoomController.to.subscribeBind(HomeController.to.currentUser.userId!);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          "[로그] Foreground :: ${message.data} ::: ${WidgetsBinding.instance?.lifecycleState}");

      if (int.parse(message.data['msgType']) != 0) {
        flutterLocalNotificationsPlugin.show(
            int.parse(message.data["msgID"] ?? "0"),
            '채팅방에 초대되었습니다.',
            message.data["body"],
            NotificationDetails(
              android: AndroidNotificationDetails(
                  channel.id, channel.name, channel.description,
                  icon: 'app_icon'),
            ),
            payload: message.data["path"]);
      }

      MQTTClientWrapper().subscribeToTopic('${message.data['room_id']}_u');
      // RoomController.to.subscribeBind(HomeController.to.currentUser.userId!);

      RoomController.to
          .getUserRoomList(HomeController.to.currentUser.userId!)
          .whenComplete(() {
        RoomController.to.update();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: future,
        initialData: false,
        builder: (_, snapshot) {
          if (snapshot.data ?? false) {
            return GetBuilder<RoomController>(builder: (controller) {
              return controller.roomList.isEmpty
                  ? Center(
                      child: Text('대화 방이 없습니다.'),
                    )
                  : ListView.builder(
                      itemCount: controller.roomList.length,
                      itemBuilder: (_, index) {
                        RoomModel item = controller.roomList[index];
                        return ListTile(
                          title: Text('${item.roomName}'),
                          subtitle: Text(
                              '${CommonUtils.getDateForm(item.createDate!, 'yyyy-MM-dd')}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person),
                              Text('${item.userCount}'),
                            ],
                          ),
                          onTap: () => Get.toNamed(RouteName.Chat,
                              arguments: item.roomId),
                        );
                      });
            });
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
