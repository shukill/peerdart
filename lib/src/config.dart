import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
// ignore_for_file: constant_identifier_names, non_constant_identifier_names

class PeerConfig {
  static const CLOUD_HOST = "0.peerjs.com";
  static const CLOUD_PORT = 443;
  static final defaultConfig = generateTurnCredentials();
  static const DEFAULT_KEY = "peerjs";
  static const VERSION = "1.0";

  static Map<String, dynamic> generateTurnCredentials() {
    const String secret = "wrietymaestro"; // Same as in turnserver.conf
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000 +
        3600; // Expire in 1 hour
    String username = "$timestamp:peerjs";

    // Generate HMAC-SHA1 hash
    var hmacSha1 = Hmac(sha1, utf8.encode(secret));
    String password =
        base64.encode(hmacSha1.convert(utf8.encode(username)).bytes);

    var myTurnConfig = {
      "urls": ["turn:20.244.8.73:3478"],
      "username": username,
      "credential": password,
    };

    var iceServers = {
      'iceServers': [
        // {'urls': "stun:stun.bethesda.net:3478"},
        // {
        //   'urls': [
        //     'stun:stun.l.google.com:19302',
        //     'stun:stun1.l.google.com:19302',
        //   ]
        // },
        myTurnConfig,
        // {
        //   "urls": [
        //     "turn:eu-0.turn.peerjs.com:3478",
        //     "turn:us-0.turn.peerjs.com:3478",
        //   ],
        //   "username": "peerjs",
        //   "credential": "peerjsp",
        // },
      ],
      'sdpSemantics': "unified-plan"
    };

    return iceServers;
  }
}
