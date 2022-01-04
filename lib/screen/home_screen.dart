import 'package:chatting_example/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<HomeController>(initState: (state) {
        HomeController.to.currentUser = Get.arguments;
      }, builder: (controller) {
        return Scaffold(
          body: IndexedStack(
            index: controller.pageIndex,
            children: controller.pageList,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.pageIndex,
            onTap: (index) => controller.onTapPage(index),
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.people), label: 'Users'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble), label: 'Chat'),
            ],
          ),
          //     Center(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       TextButton(
          //           child: Text('Chat screen'),
          //           onPressed: () => Get.toNamed(RouteName.Chat)),
          //       TextButton(
          //           onPressed: () {
          //             LocalNotification noti = LocalNotification();
          //             noti.showNotification(NotificationModel(
          //                 id: 0, title: 'Test', body: 'It must be working!'));
          //           },
          //           child: Text('Show noti')),
          //       TextButton(
          //           onPressed: () => Get.toNamed(RouteName.SignIn),
          //           child: Text('SignIn screen'))
          //     ],
          //   ),
          // )
        );
      }),
    );
  }
}
