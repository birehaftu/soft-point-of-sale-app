import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'api/MakeTransaction.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:nfc_manager/nfc_manager.dart';

class Agent extends StatelessWidget {
  const Agent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACT Soft Point of Sale Transaction',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'ACT Soft POS Transaction'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // STATE - variable
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  String? status, cardNum, reason, pin,  actualPin, amount, balance;

  void initState() {
    _tagRead();
  }

  Future<void> _handleButtonPress() async {
    //print("CardNum:"+cardNum.toString());

    if (balance?.isEmpty ?? false) {
      if (((reason?.isEmpty ?? true) ||
              (status?.isEmpty ?? true) ||
              (amount?.isEmpty ?? true) ||
              (balance?.isEmpty ?? true) ||
              (pin?.isEmpty ?? true) ||
              (cardNum?.isEmpty ?? true)) ==
          false) {
        if (status != "Active") {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Card status is :" + status!)));
          return;
        }
        if (double.parse(balance!) < double.parse(amount!)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Payment Amount :" +
                  amount! +
                  " is greater than balance " +
                  balance!)));
          return;
        }
        if (pin!=actualPin) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Invalid PIN!")));
          return;
        }
        //print("$status $cardNum");
        try {
          final data = await makeTransaction(
              double.parse(amount!), cardNum!, pin!, status!);
          if (data == true) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Transaction done!")));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Transaction failed try again! CardNum:' +
                    cardNum.toString())));
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
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All fields should not be empty!')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid Card Number')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  direction: Axis.vertical,
                  children: <Widget>[
                    const Text(
                      "Account Transaction",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      height: 10,
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
                    const Text("pin"),
                    TextField(
                      autofocus: true,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (String value) {
                        pin = value;
                      },
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
                    const Text("Reason"),
                    TextField(
                      keyboardType: TextInputType.text,
                      onChanged: (String value) {
                        reason = value;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: _handleButtonPress,
                      child: const Text('Transact'),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = await tag.data;
      String num = result.value.toString();
      String filter = num.substring((num.indexOf("[")), (num.indexOf("]") + 1));
      result.value = filter;
      cardNum = filter;
      final data = await getCardByCardCode(cardNum!);
      if (data != null) {
        var row = data["balance"];
        balance = row;
        status = data["status"];
        actualPin== data["pin"];
      } else {
        balance = '';
        status = '';
        actualPin='';
      }

      //NfcManager.instance.stopSession();
    });
  }
}
