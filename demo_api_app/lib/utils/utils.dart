import 'dart:math';

class Utils {
  static String generateRandomData() {
    final random = Random();
    final items = ['Task', 'Message', 'Data', 'Info', 'Record'];
    return '${items[random.nextInt(items.length)]} ${random.nextInt(1000)}';
  }
}
