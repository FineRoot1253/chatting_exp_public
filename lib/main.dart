import 'dart:io';
import 'package:chatting_example/data/service/mqtt_wrapper.dart';
import 'package:chatting_example/route/get_routes.dart';
import 'package:chatting_example/route/route_const.dart';
import 'package:chatting_example/util/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:path_provider/path_provider.dart';

final client = MqttServerClient.withPort('go-talk.kr', '', 8883);
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
late AndroidNotificationChannel channel;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final documentsDirectory = await getApplicationDocumentsDirectory();
  Hive.init(documentsDirectory.path);
await Hive.openBox(HIVE_CHAT_LOG_BOX);
  FirebaseMessaging _fcm = FirebaseMessaging.instance;

  MQTTClientWrapper clientWrapper = MQTTClientWrapper();

  final List<int> certificateChainBytes =
      (await rootBundle.load('assets/ssl/ca_certificate.pem'))
          .buffer
          .asInt8List();
  final List<int> clientCertificateBytes =
      (await rootBundle.load('assets/ssl/client_certificate.pem'))
          .buffer
          .asInt8List();
  final List<int> privateKeyBytes =
      (await rootBundle.load('assets/ssl/client_key_unencrypted.pem'))
          .buffer
          .asInt8List();
  SecurityContext context = SecurityContext(withTrustedRoots: true);
  context
    ..setTrustedCertificatesBytes(certificateChainBytes)
    ..useCertificateChainBytes(clientCertificateBytes)
    ..usePrivateKeyBytes(privateKeyBytes);
  // SecurityContext context = new SecurityContext()
  //   ..useCertificateChainBytes(certificateChainBytes)
  //   ..usePrivateKeyBytes(privateKeyBytes)
  //       ..setClientAuthoritiesBytes(clientCertificateBytes)
  //   ;
  // context.setClientAuthoritiesBytes(clientCertificateBytes);
  client.securityContext = context;
  clientWrapper.setupMqttClient(client);

  /// 토큰 체크로 처음 실행이후 IOS기준 퍼미션검사를 받을지 안받을지를 판단
  /// TODO : 배포 직전 주석 ALL로 변경 해줄 것 !!! 매우 중요 !!!
  // String? _fcmToken = appConfig.get("FCM_TOKEN");
  // _fcm.subscribeToTopic("ALL_DEV");
  // _fcm.subscribeToTopic("ALL");

  // if (_fcmToken == null) {

  if (Platform.isIOS) {
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
  }
  await _fcm.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  // }

  /// 안드로이드 체널 세팅
  /// TODO: 알림 타입이 증가하면 이 세팅의 가짓수도 증가해야 함
  channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    Platform.localeName == 'US'
        ? "G9bon Notification Setting"
        : "지구본 알림 세팅", // title
    Platform.localeName == 'US' ? "Default Notification Setting" : "기본 알림 세팅",
    importance: Importance.high,
  );

  /// 안드로이드 체널 생성
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// IOS 헤드업 알림을 위해 필요함
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  /// 로컬 노티 플러그인 초기화
  await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
          android: AndroidInitializationSettings("app_icon"),
          iOS: initializationSettingsIOS), onSelectNotification: (val) async {
    debugPrint("[로그] 포어그라운드 알람 콜백");
    // DeepLinkController.to.catchDeepLink(val);
  });

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   debugPrint(
  //       "[로그] Foreground :: ${message.data} ::: ${WidgetsBinding.instance?.lifecycleState}");

  //   if (message.data['msgType'] != 0) {
  //     flutterLocalNotificationsPlugin.show(
  //         int.parse(message.data["msgID"] ?? "0"),
  //         message.data["title"],
  //         message.data["body"],
  //         NotificationDetails(
  //           android: AndroidNotificationDetails(
  //               channel.id, channel.name, channel.description,
  //               icon: 'app_icon'),
  //         ),
  //         payload: message.data["path"]);
  //   }

  //   clientWrapper.subscribeToTopic(message.data['room_id']);
  // });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String? token = await _fcm.getToken();
  debugPrint(
    "FCM_TOKEN :: $token",
  );

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    getPages: GetRoutes.pages,
    initialRoute: RouteName.Initial,
  ));
}

///FCM 백그라운드 설정
///다른 Isolate에서 동작
///메모리가 다른점을 유의 할 것
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 안드로이드 알림 채널 세팅
  channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    Platform.localeName == 'US'
        ? "G9bon Notification Setting"
        : "지구본 알림 세팅", // title
    Platform.localeName == 'US' ? "Default Notification Setting" : "기본 알림 세팅",
    importance: Importance.high,
  );

  /// 안드로이드 알림 채널 생성
  /// 앱 설치후, 단 한번도 알람이 오지 않은 상황을 대비해 세팅
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// IOS 헤드업 알림을 위해 필요함
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  /// 로컬 노티 플러그인 초기화
  await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
          android: AndroidInitializationSettings("notification_icon"),
          iOS: initializationSettingsIOS),
      onSelectNotification: (String? payload) async {
    debugPrint("[로그] Background CB : $payload");
    // if (Platform.isIOS) DeepLinkController.to.catchDeepLink(payload);
  });

  debugPrint("[로그] Background : ${message.data["path"]}");

  /// 알림!
  flutterLocalNotificationsPlugin.show(
      int.parse(message.data["msgID"]),
      message.data["title"],
      message.data["body"],
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channel.description,
          icon: 'app_icon', // color: Constants.g9bonColor,
        ),
      ),
      payload: message.data["path"]);
}
