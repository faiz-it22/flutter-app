import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIConstants {
  APIConstants._();

  static const String tBaseUrl = "https://api-dta-pmserp.apps.cl0100.cloud22.io/erp";
  static const String tLoginUrl = "/user/login";

  static final String secretApiKey = dotenv.env['API_SECRET_KEY'] ?? '';
}
