import 'dart:convert';

import 'package:chatting_example/controller/auth_controller.dart';
import 'package:chatting_example/data/model/result_model.dart';
import 'package:chatting_example/data/model/user_model.dart';
import 'package:chatting_example/data/service/mqtt_wrapper.dart';
import 'package:chatting_example/route/route_const.dart';
import 'package:chatting_example/util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatting_example/util/common_extension.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({Key? key}) : super(key: key);

  final AuthController _controller = AuthController.to;
  String _email = "b@b.com";
  String _pwd = "123321";

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Get.focusScope?.hasFocus ?? false) {
          Get.focusScope!.unfocus();
        }
      },
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
            body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sign In',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  TextField(
                    onChanged: (value) {
                      this._email = value;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: 'Email address'),
                  ),
                  TextField(
                    onChanged: (value) {
                      this._pwd = value;
                    },
                    decoration: InputDecoration(hintText: 'Password'),
                    obscureText: true,
                  ),
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      height: 50,
                      width: double.maxFinite,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24))),
                        child: Text('Sign in',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                        onPressed: () async {
                          ResultModel result =
                              await _controller.signIn(this._email, this._pwd);

                          if (CommonUtils.checkResult(result)) {
                            await MQTTClientWrapper()
                                .connectClient(result.data['user_id']);

                            Get.offAllNamed(RouteName.Home,
                                arguments: UserModel.fromJson(result.data));
                          } else {
                            _scaffoldMessengerKey.show(result.msg!);
                          }
                        },
                      )),
                  SizedBox(
                      height: 50,
                      width: double.maxFinite,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24))),
                        child: Text('Sign up',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                        onPressed: () => Get.toNamed(RouteName.SignUp),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: const Padding(
                              padding: EdgeInsets.only(right: 30),
                              child: Divider(color: Colors.grey),
                            ),
                          ),
                          Text('OR', style: TextStyle(color: Colors.grey)),
                          Expanded(
                            child: const Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Divider(color: Colors.grey),
                            ),
                          ),
                        ]),
                  ),
                ]),
          ),
        )),
      ),
    );
  }
}
