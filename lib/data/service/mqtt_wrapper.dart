import 'dart:async';
import 'dart:convert';

import 'package:chatting_example/data/model/chat_model.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClientWrapper {
  static final MQTTClientWrapper _mqttClientWrapper =
      MQTTClientWrapper._instance();

  factory MQTTClientWrapper() => _mqttClientWrapper;

  MQTTClientWrapper._instance();

  late final MqttServerClient client;

  /// 1. mqtt setUp
  void setupMqttClient(MqttServerClient initClient) {
    client = initClient;
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
    client.secure = true;
    client.onBadCertificate = (dynamic cert) => true;
  }

  /// 2. client 연결
  Future<void> connectClient(int userId) async {
    final connMess = MqttConnectMessage()
        .withClientIdentifier('client-$userId')
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce)
        .authenticateAs('g9bon', 'reindeer2017!');

    print('[Mosquitto] client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on Exception catch (e) {
      print('[Mosquitto] exception : client exception - $e');
      client.disconnect();
    }

    print(
        '[Mosquitto] state : ${client.connectionStatus}, ${client.connectionStatus?.state}');

    /// Check we are connected
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('[Mosquitto] client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print(
          '[Mosquitto] Error: client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }
  }

  /// 3. subscribe
  void subscribeToTopic(String topicName) {
    client.subscribe(topicName, MqttQos.atMostOnce);

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
  }

  Stream<List<MqttReceivedMessage<MqttMessage?>>?>? get getStream =>
      client.updates;

  // void getStream() {
  //   client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
  //     final recMess = c![0].payload as MqttPublishMessage;
  //     final pt =
  //         MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
  //
  //     /// The above may seem a little convoluted for users only interested in the
  //     /// payload, some users however may be interested in the received publish message,
  //     /// lets not constrain ourselves yet until the package has been in the wild
  //     /// for a while.
  //     /// The payload is a byte buffer, this will be specific to the topic
  //     print(
  //         '[Mosquitto] Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
  //   });
  // }

  /// 4. publish message
  void publishMessage(String topic, ChatLogModel chatLogModel) {
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(jsonEncode(chatLogModel.toJson()));

    /// Publish it
    print(
        '[Mosquitto] Publishing our topic $topic, message : ${chatLogModel.toJson().toString()}, ${builder.payload}');
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void unSubscribe(String topic) {
    client.unsubscribe(topic);
    print('[Mosquitto] unSubscribe topic : <$topic>');
  }

  void _onConnected() {
    print(
        '[Mosquitto] OnConnected client callback - Client connection was sucessful');
  }

  void _onDisconnected() {
    print('[Mosquitto] OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print(
          '[Mosquitto] OnDisconnected callback is solicited, this is correct');
    }
  }

  void _onSubscribed(String topic) {
    print('[Mosquitto] Subscription confirmed for topic $topic');
  }
}
