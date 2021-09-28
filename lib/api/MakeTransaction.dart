import 'dart:convert';
import 'package:http/http.dart' as http;


Future<dynamic> GetListOfCards() async {
  // add validation here
  try {
    final response = await http.post(
      //Uri.parse('http://192.168.178.28:8080/api/account/create'),
        Uri.parse(
            'http://192.168.55.125:9095/api/accountCard/list/' )
      /*, headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'userName': userName,
      'password': password
    }),*/
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 login response,
      // then parse the JSON.
      final data = json.decode(response.body);
      print(data);
      //print(data["role"]);
      return data;
      /*if(data!=null) {
        return true;
      }
      else{
        return false;
      }*/
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      return "";
      //throw Exception('LogIn failed.' + response.statusCode.toString() + " : " +
      //    response.body);
    }
  } on Exception catch (e) {
    throw Exception(e);
//print('Error: $e');
  } catch (e) {
    throw Exception(e);
//print('unknown Error : $e');
  }
}