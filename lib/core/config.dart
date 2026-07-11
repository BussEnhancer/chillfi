// Pass --dart-define=API_URL=https://your-railway-url.up.railway.app/api at build time
// flutter build apk --dart-define=API_URL=https://chillfi-api.up.railway.app/api
const String _kApiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:5000/api', // Android emulator → localhost
);

class AppConfig {
  static const String baseUrl = _kApiUrl;
  static const String appName = 'ChillFi';
  static const String appVersion = '1.0.0';
}
