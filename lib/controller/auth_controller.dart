import 'package:chatting_example/data/model/result_model.dart';
import 'package:chatting_example/data/model/user_model.dart';
import 'package:chatting_example/data/repository.dart';
import 'package:chatting_example/util/common_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();
  final AccountRepository repository;

  AuthController({required this.repository});

  bool agreedService = false;
  bool emailDupChecked = false;
  TextEditingController emailTextController = TextEditingController();

  void toggleAgreedService(bool value) {
    agreedService = value;
    update();
  }

  Future<ResultModel> signIn(String email, String pwd) async {
    return await this.repository.login(email, pwd);

    // if (model.id == null || model.pw == null) {
    //   resultModel.code = -5;
    //   resultModel.msg = '정보를 입력해주세요';
    // } else if ((model.pw?.length ?? 10) < 6) {
    //   resultModel.code = -4;
    //   resultModel.msg = '비밀번호를 확인해주세요.';
    // } else {
    //   try {
    //     resultModel.msg = '~에 오신걸 환영합니다!';
    //   } catch (e) {
    //     resultModel.code = -1;
    //     resultModel.msg = '로그인 실패 : ${e.toString()}';
    //   }
    // }
  }

  Future<ResultModel> signUp(UserModel user) async {
    ResultModel resultModel = ResultModel();

    /// TODO : 이메일 중복 검사 필요
    if (checkNull(user)) {
      resultModel.code = -5;
      resultModel.msg = '정보를 입력해주세요';
    } else if (user.passWord != user.confirmPassWord) {
      resultModel.code = -4;
      resultModel.msg = '비밀번호를 확인해주세요';
    } else if ((user.passWord?.length ?? 10) < 6) {
      resultModel.code = -4;
      resultModel.msg = '비밀번호는 최소 6자리 이상으로 설정해주세요';
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(user.emailAddr ?? '')) {
      resultModel.code = -3;
      resultModel.msg = '이메일 주소를 다시 확인해주세요.';
    } else if (!agreedService) {
      resultModel.code = -2;
      resultModel.msg = '이용 약관에 동의해주세요.';
    } else if (!emailDupChecked) {
      resultModel.code = -3;
      resultModel.msg = '이메일 중복검사를 먼저 해주세요';
    } else {
      try {
        resultModel = await repository.signUp(user);
        resultModel.msg = "회원가입을 축하드립니다.";
      } catch (e) {
        resultModel.code = -1;
        resultModel.msg = '회원가입 실패 : ${e.toString()}';
      }
    }

    return resultModel;
  }

  Future<bool> checkEmailDup() async {
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(this.emailTextController.text)) {
      return false;
    }
    ResultModel result =
        await repository.checkEmailDuplicate(this.emailTextController.text);
    if (CommonUtils.checkResult(result)) {
      return true;
    }
    return false;
  }

  Future<List<UserModel>> searchNickname(String userName) async {
    ResultModel result = await repository.getUserList(userName);

    List<UserModel> list = [];
    if (CommonUtils.checkResult(result)) {
      list = UserModel().listFromJson(result.data);
    }

    return list;
  }

  bool checkNull(UserModel model) => (model.emailAddr == null ||
      model.passWord == null ||
      model.confirmPassWord == null ||
      model.nickName == null);
}
