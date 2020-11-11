import 'dart:async';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      textStyle: TextStyle(fontSize: 19.0, color: Colors.white),
      backgroundColor: Colors.grey,
      radius: 10.0,
      animationCurve: Curves.easeIn,
      animationBuilder: Miui10AnimBuilder(),
      animationDuration: Duration(milliseconds: 200),
      duration: Duration(seconds: 3),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: 'Flutter Read Contacts'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Iterable<Contact> contacts = [];

  final _streamController = StreamController<Iterable<Contact>>();

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  void _getContacts() async {
    //Grand the permission
    if (await Permission.contacts.request().isGranted) {
      //Read the list contact
      // Get all contacts on device
      contacts = await ContactsService.getContacts();
      if (contacts.length != 0) {
        _streamController.sink.add(contacts);
      }
      contacts.forEach((element) {
        print(element.displayName.toString());
      });
    } else {
      showToast('Quyền truy cập danh bạ bị từ chối');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue,
              width: 1,
            )),
        child: StreamBuilder<Iterable<Contact>>(
            stream: _streamController.stream,
            initialData: [],
            builder: (context, snapshot) {
              return snapshot.data.length == 0
                  ? _noItemFound()
                  : SingleChildScrollView(
                      child: Column(
                        children: List.generate(contacts.length, (index) {
                          final item = contacts.elementAt(index);
                          return ListTile(
                            leading: Icon(
                              Icons.contact_page_rounded,
                              color: Colors.blue,
                            ),
                            title: Text(item.displayName),
                            subtitle: Column(
                              children: List.generate(item.phones.length,
                                  (phoneIndex) {
                                final phone = item.phones.elementAt(phoneIndex);
                                return SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    '${phone.value} ${(phone?.label ?? '') != '' ? '(${phone.label})' : ''}',
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                    );
            }),
      ),
    );
  }

  _noItemFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.do_not_disturb_off,
                color: Colors.blueGrey,
              ),
              SizedBox(width: 10),
              Text(
                'No contact found!',
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onPressed: () {
              _getContacts();
            },
            child: Text(
              'Truy cập danh bạ',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            color: Colors.blue,
          )
        ],
      ),
    );
  }
}
