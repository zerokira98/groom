import 'package:http/http.dart' as http;

class MidApi {
  String baseUrl;
  String apiKey;
  Map<String, String> baseHeader;
  MidApi({required this.baseUrl, required this.apiKey})
      : baseHeader = {'x-api-key': apiKey, "Content-Type": "application/json"};

  Future<http.Response> getFlutterTest([String body = '{}']) async {
    // print("base :" + baseUrl);
    // print("basehead :" + baseHeader.toString());
    // print("apikey :" + apiKey);
    var get = await http.post(
      Uri.parse('$baseUrl/fluttertest'),
      headers: baseHeader,
      body: body,
    );
    return get;
  }
}
