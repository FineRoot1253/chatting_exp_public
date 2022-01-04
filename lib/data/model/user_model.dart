class UserModel {
  final int? userId;
  final int? memberId;
  final String? nickName;
  final String? userUuid;
  final String? passWord;
  final String? confirmPassWord;
  final String? emailAddr;
  final String? phoneNumber;
  final int? userState;
  final String? userFcmToken;
  final DateTime? birthDate;
  final DateTime? createDate;

  const UserModel(
      {this.userId,
      this.memberId,
      this.nickName,
      this.userUuid,
      this.confirmPassWord,
      this.passWord,
      this.emailAddr,
      this.phoneNumber,
      this.userState,
      this.userFcmToken,
      this.birthDate,
      this.createDate});

  factory UserModel.fromJson(Map<String, dynamic> parsed) {
    return UserModel(
        userId: parsed['user_id'],
        memberId: parsed['member_id'],
        nickName: parsed["nickname"],
        userUuid: parsed["user_uuid"],
        emailAddr: parsed["email_addr"],
        passWord: parsed["pwd"],
        phoneNumber: parsed["phone_number"],
        userState: parsed["user_state"],
        userFcmToken: parsed["user_fcm_token"],
        birthDate: DateTime.now(),
        createDate: DateTime.parse(parsed["createat"].toString()));
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'member_id': memberId,
        "user_uuid": userUuid,
        "email_addr": emailAddr,
        "pwd": passWord,
        "nickname": nickName,
        "phone_number": phoneNumber,
        "birth_date": birthDate,
        "createat": createDate,
      };

  List<UserModel> listFromJson(List<dynamic> list) {
    List<UserModel> userList = [];

    list.forEach((element) {
      userList.add(UserModel.fromJson(element));
    });

    return userList;
  }

  @override
  String toString() => """
  User(userId $userId, memberId $memberId, nickName: $nickName, userUuid: $userUuid, emailAddr: $emailAddr, passWord: $passWord, phoneNumber: $phoneNumber, birthDate: $birthDate, createDate: $createDate)
  """;
}
