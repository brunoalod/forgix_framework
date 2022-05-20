import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

abstract class DeviceIdentifier {
  static Future<DeviceData> getDeviceData() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    String uuid = await _getUuid();
    String platform;
    Map<String, dynamic>? raw;

    if (Platform.isWindows) {
      platform = 'Windows';
      raw = (await deviceInfoPlugin.windowsInfo).toMap();
    } else if (Platform.isAndroid) {
      platform = 'Android';
      raw = (await deviceInfoPlugin.androidInfo).toMap();
    } else {
      platform = 'Unknown';
    }

    final DeviceData deviceData = DeviceData(
      uuid: uuid,
      platform: platform,
      raw: raw ?? {},
    );

    return deviceData;
  }

  static Future<String> _getUuid() async {
    await _ensureUuidPresent();

    final File file = await getUuidFile();

    return file.readAsStringSync();
  }

  static Future<File> getUuidFile() async {
    final Directory directory = await getApplicationSupportDirectory();

    final String path = p.join(directory.path, 'uuid.lyra');

    return File(path);
  }

  static Future<void> _ensureUuidPresent() async {
    final File file = await getUuidFile();

    if (file.existsSync() == false) {
      file.createSync();
    }

    file.writeAsStringSync(const Uuid().v4(), mode: FileMode.append);
  }
}

class DeviceData {
  final String uuid;
  final String platform;
  final Map<String, dynamic> raw;

  DeviceData({
    required this.uuid,
    required this.platform,
    required this.raw,
  });
}
