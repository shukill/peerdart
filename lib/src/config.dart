// ignore_for_file: constant_identifier_names, non_constant_identifier_names

const _DEFAULT_CONFIG = {
  'iceServers': [
    {
      "urls": [
        "turn:20.244.8.73:3478",
      ],
      "username": "peerjs",
      "credential": "wrietymaestro",
      "credentialType": "password",
    },
  ],
  'iceTransportPolicy': 'relay',
  'sdpSemantics': "unified-plan"
};

class PeerConfig {
  static const CLOUD_HOST = "0.peerjs.com";
  static const CLOUD_PORT = 443;
  static const defaultConfig = _DEFAULT_CONFIG;
  static const DEFAULT_KEY = "peerjs";
  static const VERSION = "1.0";
}
