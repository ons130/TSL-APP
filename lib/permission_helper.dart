import 'package:permission_handler/permission_handler.dart';

abstract class PermissionHandler {
  Future<PermissionStatus> requestPermission(Permission permission);
}

class DefaultPermissionHandler implements PermissionHandler {
  @override
  Future<PermissionStatus> requestPermission(Permission permission) {
    return permission.request();
  }
}
