import 'dart:convert';
import 'package:http/http.dart' as http;


Future<dynamic> GetListOfAccounts() async {
  // add validation here
  try {
    final response = await http.post(
        Uri.parse(
            'http://192.168.1.13:9095/api/customerAccount/list/' )
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      return data;
    } else {
      return null;
    }
  } on Exception catch (e) {
    throw Exception(e);
//print('Error: $e');
  } catch (e) {
    throw Exception(e);
//print('unknown Error : $e');
  }
}