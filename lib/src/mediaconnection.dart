import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:peerdart/peerdart.dart';
import 'package:peerdart/src/baseconnection.dart';
import 'package:peerdart/src/logger.dart';
import 'package:peerdart/src/negotiator.dart';
import 'package:peerdart/src/servermessage.dart';
import 'package:peerdart/src/util.dart';

class MediaConnection extends BaseConnection {
  MediaStream? localStream;
  MediaStream? remoteStream;

  MediaConnection(String peer, Peer provider, PeerConnectOption? options)
      : super(peer, provider, options) {
    localStream = options?.stream;
    connectionId = options?.connectionId ?? util.randomToken();
    type = ConnectionType.Media;
    label = 'media';

    _negotiator = Negotiator(this);

    if (localStream != null && options?.payload != null) {
      _negotiator?.startConnection(PeerConnectOption(
        stream: localStream,
        connectionId: connectionId,
      ));
    }
  }
  final _idPrefix = 'mc_';
  late Negotiator? _negotiator;

  void addStream(MediaStream remoteStream) {
    logger.log('Receiving stream $remoteStream');

    this.remoteStream = remoteStream;
    // provider?.emit('stream', null, remoteStream); // Should we call this `open`?
    // emit('stream', null, remoteStream); // Should we call this `open`?
    super.emit<MediaStream>(
        'stream', remoteStream); // Should we call this `open`?
  }

  @override
  void dispose() {
    _negotiator?.cleanup();
    _negotiator = null;

    _stopMediaDevice();

    localStream = null;
    remoteStream = null;

    // TODO: set stream to null when done.
    // if (this.options && this.options._stream) {
    // 	this.options._stream = null;
    // }

    if (!open) {
      return;
    }

    open = false;
  }

  void _stopMediaDevice() {
    final tracks = localStream?.getTracks();

    tracks?.forEach((track) async => await track.stop());
  }

  @override
  ConnectionType get type => ConnectionType.Media;

  @override
  void handleMessage(ServerMessage message) {
    final payload = message.payload;

    switch (message.type) {
      case ServerMessageType.Answer:
        // Forward to negotiator
        _negotiator?.handleSDP(payload["sdp"]["type"], payload["sdp"]);
        open = true;
        break;
      case ServerMessageType.Candidate:
        _negotiator?.handleCandidate(RTCIceCandidate(
            payload["candidate"]["candidate"],
            payload["candidate"]["sdpMid"],
            payload["candidate"]["sdpMLineIndex"]));
        break;

      default:
        logger.warn(
          "Unrecognized message type:${message.type.type} from peer: $peerId",
        );
        break;
    }
  }

  void answer(MediaStream stream, {AnswerOption? callOptions}) {
    if (localStream != null) {
      logger.warn(
        "Local stream already exists on this MediaConnection. Are you answering a call twice?",
      );
      return;
    }

    localStream = stream;

    if (callOptions?.sdpTransform != null) {
      callOptions?.sdpTransform = callOptions.sdpTransform;
    }
    final op = PeerConnectOption(
        payload: PeerConnectOption(
            stream: localStream,
            sdp: options!.payload!.sdp,
            connectionId: options!.payload!.connectionId,
            metadata: options!.payload!.metadata));
    _negotiator?.startConnection(op.payload!);

    // Retrieve lost messages stored because PeerConnection not set up.
    if (connectionId != null) {
      final messages = provider.getMessages(connectionId ?? '');

      for (var message in messages) {
        handleMessage(message);
      }
    }

    open = true;
  }
}
