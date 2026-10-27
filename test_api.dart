import 'dart:io';
import 'dart:convert';
main() async {
  try {
    var client = HttpClient();
    var request = await client.postUrl(Uri.parse('https://blantonslab.com/m_api/custom-design-submit'));
    request.headers.set('Content-Type', 'application/json');
    var data = {"msg": "test"};
    request.write(jsonEncode(data));
    var response = await request.close();
    print("Response status: ${response.statusCode}");
    print("Response headers: ${response.headers}");
    var respBody = await response.transform(utf8.decoder).join();
    print("Response body: $respBody");
  } catch (e) {
    print("Error: $e");
  }
}
