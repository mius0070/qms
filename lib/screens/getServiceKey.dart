import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class GetServiceKey {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Future<String> getAccessToken() async {
    final service = {
      "type": "service_account",
      "project_id": "qmsys-8425f",
      "private_key_id": "fef4b3c70fab0389f59819762d13ff3865d61013",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDVwBLp7lEf6XO5\n4wbZWPYCGgkvWAGOzxDYX0B9HYc7TSNVu8H5S6j6ggCqdmVVlpb9+zbVpRwfoxPu\nauj/kOeghCykmIbnYJ/hQRIJ7aSdUI//AKdqnL3PUNA2Iiw6cBnfby2sL2yshIb9\nUkB0Qdgb1/7vhv+mqmOyRG9ea0QqH0lqEIrnFuhW3UJ7SHpCk9OPu8F4xTm/BhlP\nnipQp2A34XxGqmjn/F7GXDSepasSsLstn8x41XiUkpX2d0cxx1bhvk4hUFq1dmm0\nkMISjd5D4AMfrh+4OGMtBBavDpkrtIwHpuGlxogEP1F4fzuIdaCdLpXcQxhfGRka\nZUTLiBLbAgMBAAECggEAAhH1/O8EOR9mFV0wsGb5/9xvBnNNeQEa8mH3j6XCSV2T\n1WuQ01BwxrBUMW7kq8xB2Y36d+wEZKgMEKXlpT1ViPVHpEvJp5RaKA0rHdWcUXny\ni/aJKI3JEX4dCpEtKQm6yt0FLfEfa2CKUe2mSH2Ewz4M58FO5xq2zQbqGBm6oap0\nX67S8B4Eqrv5E5PG6zR1BNx16+O1DEiv5GUugwZ4gBY462qf7AG7AjpWCR7ESOWg\nzYrvTZeWryRiwEU1fhaQoBrPWp64NmeawiPro3WAulGhe1ret+JGwwxh3xyLnXBW\nzN0NVrTeMkjcuUByWH0jGTpWhpp7LtzmWU4gsKligQKBgQDvVGaC1benyKLV3qrI\n/FeEECmTI91ohCe7WRt2kRug0i2wE4SXZ6OQXDTBR4gH2F3Fh2uIGj9L9XTNbZeS\nad98lboNlYjUcEJId4XkVMzIAEqodNV0ZnOKzj/SLyS14rtUl6RBHLQvni3MaN4b\nIahHEbHurNyt7+1K8aShJyz1WwKBgQDko44hgEgxWfam9jak73VhaFfahdAdDw7I\n5pgdrBqJgfUWzc4uuosrx24J0ipEyJORZgvzq8cRJaojmdoiAdly0fglh2zX+7zW\nHv1gcfBswnyKVTMHjmeHSF5kkQsu0096CgGDy4PDjf8ZDuN08mHfey2FcQFEXEVg\nPMV7JdxQgQKBgGpWZuHVEbAEDo3WTK3WqQ/tmntdISAyL/EnK3OoD82J9XDZiz02\neE9JGMuT+9X4hdmhTN8BQoR+gDJScllEn18cq7kjatNxOZI3QQ9tujtXHdTxbHI2\nnznaYDMEbVw/bJqucfXYShsqPhEnux/0+W7yZsu0lKzYAOgeq9ZKsMgnAoGAS/oV\ntwg79Tph/mV/DxwLs4zK9PDWkXF5hkUqc2HHh75JxYQqadjPeoLRDC5soWLNttlk\nS1rf0dDkUuRDWl2m9sLTZRU1lCgxPi4aILx8GogefpGFXZNyz7+6rkyMnMjXdkRw\n8GzmoktDY/5Qk4IgB/WU0O0WcLMA0tQfA6c3KQECgYEAyASgexDjwXtTDrCMZ7rW\ntAxzvjnY271eik/C+Lxm7TFG2rqeemOueQB+t4nr+BLpDtwX+5/Uj1M4c1qnhyvK\nFDWXLCkdmmdIZeayLBYsCYi8kEDzuCAPlgsphjg+gLM7Lrov6lei3JthSGDc2pJt\nYEYEpfZtoMkS1b+vELRnFHA=\n-----END PRIVATE KEY-----\n",
      "client_email": "project-qmsys@qmsys-8425f.iam.gserviceaccount.com",
      "client_id": "101975618806587028186",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/project-qmsys%40qmsys-8425f.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com",
    };
    List<String> scopes = [
      'https://www.googleapis.com/auth/cloud-platform',
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/userinfo.email',
    ];
    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(service),
      scopes,
    );
    auth.AccessCredentials credentials = await auth
        .obtainAccessCredentialsViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(service),
          scopes,
          client,
        );
    client.close();
    return credentials.accessToken.data;
  }

  static Future<void> sendNotificationToToken(
    String token,
    BuildContext context,
  ) async {
    final String serverKey = await getAccessToken();

    final http.Response resp = await http.post(
      Uri.parse(
        'https://fcm.googleapis.com/v1/projects/qmsys-8425f/messages:send',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode({
        "message": {
          "token": token,
          "notification": {"title": "Alert", "body": "Your turn"},
        },
      }),
    );
    if (resp.statusCode == 200) {
      print("Notification sent successfully");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Notification sent successfully")));
    } else {
      print("Failed to send notification");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send notification,connection error")),
      );
      print("Error: ${resp.statusCode} ${resp.body}");
    }
  }

  /// 🔧 Local notification channel setup (Android)
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'patient_channel',
    'High Importance Notifications patient',
    description: 'Used for important notifications.',
    importance: Importance.high,
  );
  static Future<void> initializeLocalNotifications() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('🔔 Notifications authorized');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('❌ Notifications denied');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      print('❓ Permission not determined');
    }
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iOSSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );
    await _localNotificationsPlugin.initialize(initSettings);

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  @pragma('vm:entry-point')
  static void showNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    print("testing notification");
    if (notification != null && android != null) {
      print("testing notification");
      _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}
