import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Check if storage permission is granted
  Future<bool> isStoragePermissionGranted() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      
      if (androidInfo >= 33) {
        // Android 13 and above
        return await Permission.audio.isGranted;
      } else if (androidInfo >= 30) {
        // Android 11 and 12
        return await Permission.storage.isGranted || 
               await Permission.manageExternalStorage.isGranted;
      } else {
        // Android 10 and below
        return await Permission.storage.isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.mediaLibrary.isGranted;
    }
    
    return false;
  }

  // Request storage permission
  Future<PermissionStatus> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      
      if (androidInfo >= 33) {
        // Android 13 and above - request READ_MEDIA_AUDIO
        return await Permission.audio.request();
      } else if (androidInfo >= 30) {
        // Android 11 and 12
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          return await Permission.manageExternalStorage.request();
        }
        return storageStatus;
      } else {
        // Android 10 and below
        return await Permission.storage.request();
      }
    } else if (Platform.isIOS) {
      return await Permission.mediaLibrary.request();
    }
    
    return PermissionStatus.denied;
  }

  // Check if permission is permanently denied
  Future<bool> isStoragePermissionPermanentlyDenied() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      
      if (androidInfo >= 33) {
        return await Permission.audio.isPermanentlyDenied;
      } else {
        return await Permission.storage.isPermanentlyDenied;
      }
    } else if (Platform.isIOS) {
      return await Permission.mediaLibrary.isPermanentlyDenied;
    }
    
    return false;
  }

  // Request all necessary permissions
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = {};

    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      
      if (androidInfo >= 33) {
        // Android 13+
        statuses = await [
          Permission.audio,
          Permission.notification,
        ].request();
      } else if (androidInfo >= 30) {
        // Android 11-12
        statuses = await [
          Permission.storage,
          Permission.manageExternalStorage,
        ].request();
      } else {
        // Android 10 and below
        statuses = await [
          Permission.storage,
        ].request();
      }
    } else if (Platform.isIOS) {
      statuses = await [
        Permission.mediaLibrary,
      ].request();
    }

    return statuses;
  }

  // Check notification permission
  Future<bool> isNotificationPermissionGranted() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    }
    return true; // iOS handles notifications differently
  }

  // Request notification permission
  Future<PermissionStatus> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      return await Permission.notification.request();
    }
    return PermissionStatus.granted;
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  // Get Android SDK version
  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;
    
    try {
      // This is a simplified version. In production, you'd use device_info_plus
      // For now, we'll assume a recent version
      return 33; // Default to Android 13
    } catch (e) {
      return 30; // Fallback
    }
  }

  // Check all permissions status
  Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'storage': await isStoragePermissionGranted(),
      'notification': await isNotificationPermissionGranted(),
    };
  }

  // Get permission status message
  String getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted';
      case PermissionStatus.denied:
        return 'Permission denied. Please grant permission to continue.';
      case PermissionStatus.permanentlyDenied:
        return 'Permission permanently denied. Please enable it in app settings.';
      case PermissionStatus.restricted:
        return 'Permission restricted. Cannot request permission.';
      case PermissionStatus.limited:
        return 'Limited permission granted.';
      case PermissionStatus.provisional:
        return 'Provisional permission granted.';
    }
  }

  // Handle permission result
  Future<bool> handlePermissionResult(PermissionStatus status) async {
    if (status.isGranted || status.isLimited) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Open app settings
      await openAppSettings();
      return false;
    } else {
      return false;
    }
  }
}