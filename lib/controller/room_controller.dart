import 'package:chatting_example/data/model/result_model.dart';
import 'package:chatting_example/data/model/room_model.dart';
import 'package:chatting_example/data/repository.dart';
import 'package:chatting_example/util/common_util.dart';
import 'package:get/get.dart';

class RoomController extends GetxController {
  static RoomController get to => Get.find<RoomController>();

  RoomController({required this.repository});

  final RoomRepository repository;

  List<RoomModel> roomList = [];

  /// 방생성
  Future<RoomModel> createRoom(RoomModel model) async {
    ResultModel result = await repository.createRoom(model);

    print(result.toString());

    if (CommonUtils.checkResult(result)) {
      return RoomModel.fromJson(result.data["room"]);
    }
    return RoomModel();
  }

  /// 대화방 리스트
  Future<bool> getUserRoomList(int userId) async {
    ResultModel result = await repository.getUserRoomList(userId);
    if (CommonUtils.checkResult(result)) {
      roomList = RoomModel().listFromJson(result.data ?? []);
      return true;
    }

    return false;
  }

  Future<void> subscribeBind(int userId) async {
    ResultModel result = await repository.userBind(userId);
    print('bind : ${result.toString()}');
    if (CommonUtils.checkResult(result)) {
      print('bind');
    }
  }
}
