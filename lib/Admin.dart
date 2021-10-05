import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'api/CreateCard.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'main.dart';

class Admin extends StatelessWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACT Soft Point of Sale Card Association',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'ACT Soft POS Card Association'),
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
  List<String> accountNames = [];
  List<String> statusList = ["Active", "InActive", "Expired", "Blocked"];
  String? status, cardNum, accountnum, pin;

  void initState() {
    //await loadPage();
    Timer.run(() => loadPage());
    _tagRead();
  }

  Future<void> loadPage() async {
    try {
      var data = await GetListOfAccounts();
      if (data != null) {
        for (var i = 0; i < data.length; i++) {
          var row = data[i];
          String id2 = row["accountId"].toString();
          accountNames.add(id2);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("There are no registered accounts!")));
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
  }

  void _handlelogout() {
    runApp(const MyApp());
  }

  Future<void> _handleButtonPress() async {
    print("CardNum:" + cardNum.toString());
    if (((accountnum?.isEmpty ?? true) ||
            (status?.isEmpty ?? true) ||
            (pin?.isEmpty ?? true) ||
            (cardNum?.isEmpty ?? true)) ==
        false) {
      //print("$status $cardNum");
      try {
        final data = await getCardByCardCode(cardNum!);
        if (data == null) {
          final data =
              await createCard(int.parse(accountnum!), cardNum!, pin!, status!);
          if (data == true) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Card Association done!")));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Card Association failed try again! CardNum:' +
                    cardNum.toString())));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(' CardNum:' +
                  cardNum.toString() +
                  ' Is already associated previously!')));
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
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                      Text('There is no availble NFC! Enable NFC if availble, then logout and login!'),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        onPressed: _handlelogout,
                        child: const Text('logout'),
                      )
                    ]))
              : Flex(
                  mainAxisAlignment: MainAxisAlignment.start,
                  direction: Axis.vertical,
                  children: <Widget>[
                    const Text(
                      "Account Card Association",
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
                    const SizedBox(
                      height: 10,
                    ),
                    DropDownField(
                        value: accountnum,
                        required: true,
                        labelText: 'Account Number',
                        icon: Icon(Icons.account_balance),
                        items: accountNames,
                        onValueChanged: (dynamic val) {
                          accountnum = val;
                        },
                        setter: (dynamic newValue) {
                          accountnum = newValue;
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    DropDownField(
                        value: status,
                        required: true,
                        labelText: 'Card Status',
                        items: statusList,
                        onValueChanged: (dynamic val) {
                          status = val;
                        },
                        setter: (dynamic newValue) {
                          status = newValue;
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: _handleButtonPress,
                      child: const Text('Associate'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: _handlelogout,
                      child: const Text('logout'),
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
      //NfcManager.instance.stopSession();
    });
  }
}
