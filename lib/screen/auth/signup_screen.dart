import 'package:chatting_example/controller/auth_controller.dart';
import 'package:chatting_example/data/model/result_model.dart';
import 'package:chatting_example/data/model/user_model.dart';
import 'package:chatting_example/route/route_const.dart';
import 'package:chatting_example/util/common_extension.dart';
import 'package:chatting_example/util/common_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key}) : super(key: key);

  final AuthController _controller = AuthController.to;
  String _nickName = "", _pwd = "", _confirmPwd = "";
  bool isDupCheckOK = false;

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
                  Text('Sign Up',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: TextField(
                          decoration:
                              InputDecoration(hintText: 'Email address'),
                          onChanged: (value) {
                            this._controller.emailTextController.text = value;
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: EmailDupCheckWidget(
                          scaffoldMessengerKey: this._scaffoldMessengerKey,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: 'Nickname'),
                    onChanged: (value) {
                      this._nickName = value;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: 'Password'),
                    obscureText: true,
                    onChanged: (value) {
                      this._pwd = value;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: 'Confirm password'),
                    obscureText: true,
                    onChanged: (value) {
                      this._confirmPwd = value;
                    },
                  ),
                  ListTile(
                      leading: GetBuilder<AuthController>(
                          builder: (_) => Checkbox(
                              value: _controller.agreedService,
                              onChanged: (value) =>
                                  _controller.toggleAgreedService(value!))),
                      title: Text('이용약관 동의')),
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
                        onPressed: () async {
                          String? fcmToken =
                              await FirebaseMessaging.instance.getToken();
                          UserModel user = UserModel(
                              nickName: _nickName,
                              emailAddr:
                                  this._controller.emailTextController.text,
                              passWord: _pwd,
                              confirmPassWord: _confirmPwd,
                              userFcmToken: fcmToken);
                          ResultModel result = await _controller.signUp(user);

                          _scaffoldMessengerKey.show(result.msg!);
                          debugPrint("${result.code}");
                          if (CommonUtils.checkResult(result)) {
                            Get.offAllNamed(RouteName.Home,
                                arguments: UserModel.fromJson(result.data));
                          }
                        },
                      ))
                ]),
          ),
        )),
      ),
    );
  }
}

class EmailDupCheckWidget extends StatefulWidget {
  const EmailDupCheckWidget({Key? key, required this.scaffoldMessengerKey})
      : super(key: key);
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  @override
  _EmailDupCheckWidgetState createState() => _EmailDupCheckWidgetState();
}

class _EmailDupCheckWidgetState extends State<EmailDupCheckWidget> {
  final AuthController authController = AuthController.to;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.authController.emailTextController.addListener(() {
      if (this.authController.emailDupChecked) {
        debugPrint("콜콜");
        this.authController.emailDupChecked = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return (authController.emailDupChecked)
        ? Text("검사완료")
        : SizedBox(
            height: 35,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24))),
              child: Text('중복검사',
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              onPressed: () async {
                if (await this.authController.checkEmailDup()) {
                  this.widget.scaffoldMessengerKey.show("이용 가능한 이메일입니다.");
                  authController.emailDupChecked = true;
                  setState(() {});
                } else {
                  this.widget.scaffoldMessengerKey.show("사용 불가능한 이메일입니다!");
                }
              },
            ));
  }
}
