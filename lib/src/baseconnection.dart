import 'package:events_emitter/emitters/stream_event_emitter.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peerdart/src/enums.dart';
import 'package:peerdart/src/option_interfaces.dart';
import 'package:peerdart/src/peer.dart';
import 'package:peerdart/src/servermessage.dart';

abstract class BaseConnection extends StreamEventEmitter {
  BaseConnection(this.peerId, this.provider, this.options) {
    metadata = options?.metadata;
  }

  String peerId;
  Peer provider;
  PeerConnectOption? options;
  String? connectionId;
  ConnectionType type = ConnectionType.Data;
  String label = '';
  Map<String, dynamic>? metadata;
  bool open = false;
  RTCPeerConnection? peerConnection;

  void dispose();
  void handleMessage(ServerMessage message);

  void closeRequest() {
    emit("close", {
      'peer': peerId,
      'provider': provider,
    });
  }
}
