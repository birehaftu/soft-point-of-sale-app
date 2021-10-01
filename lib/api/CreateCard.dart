import 'dart:convert';
import 'package:http/http.dart' as http;


Future<dynamic> GetListOfAccounts() async {
  // add validation here
  try {
    final response = await http.get(
        Uri.parse(
            'https://soft-point-of-sale-act.herokuapp.com/api/customerAccount/list' )
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print(data);
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
Future<dynamic> createCard(int accountId,String cardCode,String pin,String status) async {
  // add validation here
  try {
    if((await getCardByCardCode(cardCode))==null) {
      final response = await http.post(
        //Uri.parse('http://192.168.178.28:8080/api/account/create'),
        Uri.parse(
          //'http://10.0.2.2:9095/api/customerCard/create')
          //'https://soft-point-of-sale-act.herokuapp.com/api/customerCard/create')
            'https://soft-point-of-sale-act.herokuapp.com/api/customerCard/create')
        , headers: <String, String>{
        'Content-Type': 'application/json',
      },
        body: jsonEncode(<String, dynamic>{
          'customer_account': {'accountId': accountId},
          'cardCode': cardCode,
          'pin': pin,
          'status': status
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
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
    }else{
      return "";
    }
  } on Exception catch (e) {
    throw Exception(e);
//print('Error: $e');
  } catch (e) {
    throw Exception(e);
//print('unknown Error : $e');
  }
}

Future<dynamic> getCardByCardCode(String cardCode) async {
  // add validation here
  try {
    final response = await http.get(
        Uri.parse(
            'https://soft-point-of-sale-act.herokuapp.com/api/customerCard/getByCard/'+cardCode )
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print(data);
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