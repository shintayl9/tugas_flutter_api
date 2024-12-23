import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiOpenweatherService {
  final String baseUrl =
      'https://api.openweathermap.org/data/2.5/group?id=1650213,1642588,1635111,1621177,1642911&units=metric&appid=1b9faf33eafc021f6977341a94f0b8ff&lang=id';

  Future<List<dynamic>> fetchWeather() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['list'];
      } else {
        throw Exception('Gagal memuat data cuaca');
      }
    } catch (e) {
      throw Exception('Terdapat kesalahan saat pengambilan data cuaca');
    }
  }
}