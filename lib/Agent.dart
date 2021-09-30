import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'api/MakeTransaction.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'main.dart';

class Agent extends StatelessWidget {
  const Agent({Key? key, required String this.userId}) : super(key: key);
  final String userId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACT Soft Point of Sale Transaction',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(userId: userId, title: 'ACT Soft POS Transaction'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required String this.userId, required this.title})
      : super(key: key);

  final String userId;

  // STATE - variable
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  String? accountId,
      cardId,
      uId,
      status,
      cardNum,
      reason,
      pin,
      actualPin,
      amount,
      balance,reciever;

  void initState() {
    _tagRead();
  }

  Future<void> _handleButtonPress() async {
    //print("CardNum:"+cardNum.toString());

    if (pin != actualPin) {
      if (((reason?.isEmpty ?? true) ||
              (status?.isEmpty ?? true) ||
              (amount?.isEmpty ?? true) ||
          (reciever?.isEmpty ?? true) ||
              (balance?.isEmpty ?? true) ||
              (pin?.isEmpty ?? true)) ==
          false) {
        if (reciever == accountId) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Debit and Credit account can't be the same." + status!)));
          return;
        }
        if (status != "Active") {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Card status is :" + status!)));
          return;
        }
        if (double.parse(balance!) < double.parse(amount!)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Payment Amount : " +
                  amount! +
                  " is greater than balance : " +
                  balance!)));
          return;
        }
        //print("$status $cardNum");
        try {
          final data = await makeTransaction(
              double.parse(amount!),
              double.parse(balance!),
              int.parse(reciever!),
              int.parse(accountId!),
              int.parse(cardId!),
              int.parse(uId!),
              reason!,
              "Complete");
          if (data == true) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Transaction done!")));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Transaction failed try again!')));
          }
        } on Exception catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
          //print('Error: $e');
        } catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('unknown Error : $e')));
          //print('unknown Error : $e');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('All fields should not be empty!' + status!)));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid PIN')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      restorationId: uId = widget.userId,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: NfcManager.instance.isAvailable(),
          builder: (context, ss) => ss.data != true
              ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'))
              : Flex(
                  mainAxisAlignment: MainAxisAlignment.start,
                  direction: Axis.vertical,
                  children: <Widget>[
                    const Text(
                      "Account Transaction",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    ElevatedButton(
                        child: Text('Tag Read'), onPressed: _tagRead),
                    const Text("Card Code"),
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(2),
                        constraints: BoxConstraints.tightForFinite(),
                        decoration: BoxDecoration(border: Border.all()),
                        child: SingleChildScrollView(
                          child: ValueListenableBuilder<dynamic>(
                            valueListenable: result,
                            builder: (context, value, _) =>
                                // Text('${value ?? ''}'),
                                Text('${value ?? ''}'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text("pin"),
                    TextField(
                      autofocus: true,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (String value) {
                        pin = value;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text("Amount"),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (String value) {
                        amount = value;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text("Reciever Account"),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (String value) {
                        reciever = value;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text("Reason"),
                    TextField(
                      keyboardType: TextInputType.text,
                      onChanged: (String value) {
                        reason = value;
                      },
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: _handleButtonPress,
                      child: const Text('Transact'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: _handlelogout,
                      child: const Text('logout'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _handlelogout(){
    runApp(const MyApp());
  }
  void _tagRead() {
    try {
      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        result.value = await tag.data;
        String num = result.value.toString();
        String filter =
            num.substring((num.indexOf("[")), (num.indexOf("]") + 1));
        result.value = filter;
        cardNum = filter;
        final data = await getCardByCardCode(cardNum!);
        if (data != null) {
          final row = data["customer_account"]; // as double;
          row.forEach((key, value) {
            if (key == "balance") balance = value.toString();
            if (key == "accountId") accountId = value.toString();
          });
          status = data["status"];
          actualPin = data["pin"];
          String card = '';
          data.forEach((key, value) {
            if (key == "cardId") card = value.toString();
          });
          cardId = card;
          reason='';
        } else {
          balance = '';
          status = '';
          actualPin = '';
          cardId = '';
          reason='';
        }

        //NfcManager.instance.stopSession();
      });
    } on Exception catch (e) {
      throw Exception(e);
//print('Error: $e');
    } catch (e) {
      throw Exception(e);
//print('unknown Error : $e');
    }
  }
}
