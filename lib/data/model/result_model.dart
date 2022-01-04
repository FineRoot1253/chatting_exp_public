class ResultModel {
  int? code;
  String? msg;
  String? language;
  dynamic data;

  ResultModel({
    this.code,
    this.msg,
    this.language,
    this.data,
  });

  factory ResultModel.fromJson(Map<String, dynamic> parsedJson) {
    return ResultModel(
      code: parsedJson['code'],
      msg: parsedJson['msg'],
      data: parsedJson['result'],
    );
  }
  Map<String, dynamic> toJson() => {"code": code, "msg": msg, "data": data};

  @override
  String toString() => """ResultModel (code: $code, msg: $msg)""";
}
