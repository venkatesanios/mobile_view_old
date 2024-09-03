import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:uuid/uuid.dart';
import '../state_management/MqttPayloadProvider.dart';

class MQTTManager {
  static MQTTManager? _instance;
  MqttPayloadProvider? providerState;
  MqttServerClient? _client;

  factory MQTTManager() {
    _instance ??= MQTTManager._internal();
    return _instance!;
  }

  MQTTManager._internal();

  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;
  final Set<String> _subscribedTopics = {};


  void initializeMQTTClient({MqttPayloadProvider? state}) {

    String uniqueId = const Uuid().v4();

    // String baseURL = '192.168.68.141';
    int port = 1883;
    String baseURL = '13.235.254.21';

    if (_client == null) {
      providerState = state;
      _client = MqttServerClient(baseURL, uniqueId);
      _client!.port = port;
      _client!.keepAlivePeriod = 60;
      _client!.onDisconnected = onDisconnected;
      _client!.logging(on: false);
      _client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
      _client!.onConnected = onConnected;
      _client!.onSubscribed = onSubscribed;
      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier(uniqueId)
          .withWillTopic('will-topic')
          .withWillMessage('My Will message')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      print('Mosquitto client connecting....');
      _client!.connectionMessage = connMess;
    }
  }

  void connect() async {
    assert(_client != null);
    if (!isConnected) {
      try {
        print('Mosquitto start client connecting....');
        providerState?.setAppConnectionState(MQTTConnectionState.connecting);
        await _client!.connect();
        _client?.updates!.listen(_onMessageReceived);
        if(providerState!.subscribeTopic.isNotEmpty){
          subscribeToTopic(providerState!.subscribeTopic);
          print('subscribeTopic : ${providerState!.subscribeTopic}');
        }
        if(providerState!.publishTopic.isNotEmpty){
          publish(providerState!.publishMessage, providerState!.publishTopic);
        }
        print('subscribe => ${providerState!.subscribeTopic}');
      } on Exception catch (e, stackTrace) {
        print('Client exception - $e');
        print('StackTrace: $stackTrace');
        disconnect();
      }
    }
  }

  void disconnect() {
    print('Disconnected');
    _client!.disconnect();
  }

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage?>>? c) async {
    final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
    final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print('Received message: $pt');
    providerState?.updateReceivedPayload(pt,false);
  }
  void subscribeToTopic(String topic) async {
    print('Trying to subscribe to ${topic}');
    print('isConnected: ${isConnected}');

    if (_subscribedTopics.contains(topic)) {
      print('Already subscribed to ${topic}');
      return; // Avoid resubscribing
    }

    if (isConnected) {
      print("Connected, subscribing to ${topic}");
      _client?.subscribe(topic, MqttQos.atLeastOnce);
      _subscribedTopics.add(topic); // Track the subscribed topic
    } else {
      Future.delayed(Duration(seconds: 1), () {
        subscribeToTopic(topic);
      });
    }
  }

  // void subscribeToTopic(String topic) async{
  //   print('trying to subscribe ${topic}');
  //   print('isConnected : ${isConnected}');
  //   if(isConnected){
  //     _client!.subscribe(topic, MqttQos.atLeastOnce);
  //     _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async{
  //       final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
  //       final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
  //       providerState?.updateReceivedPayload(pt,false);
  //     });
  //   }else{
  //     Future.delayed(Duration(seconds: 1),(){
  //       subscribeToTopic(topic);
  //     });
  //   }
  // }
  //
  // void unSubscribe({
  //   required String unSubscribeTopic,
  // }){
  //   if(isConnected){
  //     _client!.unsubscribe(unSubscribeTopic);
  //     print('unSubscribeTopic => $unSubscribeTopic');
  //   }else{
  //     Future.delayed(Duration(seconds: 1),(){
  //       unSubscribe(
  //         unSubscribeTopic: unSubscribeTopic,
  //       );
  //     });
  //   }
  // }
  void unSubscribe({
    required String unSubscribeTopic,
    required String subscribeTopic,
    required String publishTopic,
    required String publishMessage
  }){
    if(isConnected){
      providerState!.editSubscribeTopic(subscribeTopic);
      providerState!.editPublishTopic(publishTopic);
      providerState!.editPublishMessage(publishMessage);
      _subscribedTopics.remove(unSubscribeTopic); // Track the subscribed topic
      // _client!.unsubscribe(unSubscribeTopic);
    }else{
      Future.delayed(Duration(seconds: 1),(){
        unSubscribe(
            unSubscribeTopic: unSubscribeTopic,
            subscribeTopic: subscribeTopic,
            publishTopic: publishTopic,
            publishMessage: publishMessage
        );
      });
    }
  }

  Future<void> publish(String message, String topic) async{
    print('publish topic : $topic');
    print('publish message : $message');
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    if(providerState!.publishTopic.isNotEmpty){
      print('publish in subscribe function');
      publish(providerState!.publishMessage, providerState!.publishTopic);
    }
    print('Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() async{
    await Future.delayed(Duration(seconds: 5,));
    try{
      print('OnDisconnected client callback - Client disconnection');
      if (_client!.connectionStatus!.returnCode == MqttConnectReturnCode.noneSpecified) {
        print('OnDisconnected callback is solicited, this is correct');
      }
      providerState?.setAppConnectionState(MQTTConnectionState.disconnected);
      connect();
    }catch(e){
      print('Mqtt connectivity issue => ${e.toString()}');
    }

    // Attempt reconnection after a delay
    /*Future.delayed(const Duration(seconds: 03), () {
      //_client!.disconnect();
      //connect();
    });*/
  }

  void onConnected() {
    assert(isConnected);
    providerState?.setAppConnectionState(MQTTConnectionState.connected);
    print('Mosquitto client connected....');
  }
}
