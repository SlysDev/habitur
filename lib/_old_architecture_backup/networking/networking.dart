import 'package:http/http.dart' as http;

class Networking {
  late String data;
  getData() async {
    http.Response response = await http.get(
      Uri.parse('https://www.boredapi.com/api/activity?type=busywork'),
    );
    String data = response.body;
  }
}
