class ApiCall {
  final String id;
  final String data;
  final DateTime timestamp;

  ApiCall({required this.id, required this.data, required this.timestamp});
}

enum SpeedUnit { kbps, mbps }
