import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> getCardByCardCode(String cardCode) async {
  // add validation here
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.9:9095/api/customerCard/getByCard/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{'cardCode': cardCode}),
    );

    if (response.statusCode == 200) {
      if (response.body != null && response.body != "") {
        final data = jsonDecode(response.body);
        print(data);
        return data;
      } else {
        return null;
      }
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

Future<dynamic> makeTransaction(double amount, double balance, int reciever,
    int accountId, int cardId, int userId,
    String goodName, String status) async {
  // add validation here
  try {
    final response = await http.post(
      //Uri.parse('http://192.168.178.28:8080/api/account/create'),
      Uri.parse(
        //'http://10.0.2.2:9095/api/customerCard/create')
        //'http://192.168.1.9:9095/api/customerCard/create')
          'http://192.168.1.9:9095/api/cardTransaction/create'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'transaction_card': {
          'cardId': cardId,
          'customer_account': {"accountId": accountId,
            "balance": balance}
        },
        'transaction_user': {'userId': userId},
        'amount': amount,
        'status': status,
        'goodName': goodName
      }),
    );

    if (response.statusCode == 200) {
      final data2 = json.decode(response.body);
      if (data2 == true) {
        final response2 = await http.post(Uri.parse(
            'http://192.168.1.9:9095/api/customerAccount/updateBalance')
            ,
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, dynamic>{
              "accountId": reciever,
                "balance": (balance + amount)}),
            );

            if (response2.statusCode == 200)
        {
          return data2;
        } else {
        return "";
      }
    }
  } else {
  return "";
  }
  } on Exception
  catch
  (
  e) {
  throw Exception(e);
//print('Error: $e');
  } catch
  (
  e) {
  throw Exception(e);
//print('unknown Error : $e');
  }
}
