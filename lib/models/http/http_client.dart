import 'package:dudu/models/logined_user.dart';
import 'package:http/http.dart' as http;

class HttpClient extends http.BaseClient {
  final String token;
  final http.Client _inner = http.Client();

  HttpClient(this.token);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = LoginedUser().getToken();

    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }

}