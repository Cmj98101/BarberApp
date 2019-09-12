import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/globalVariables.dart';

class BusinessDetailsTab extends StatefulWidget {
  BusinessDetailsTab({this.businessId});
  final String businessId;

  @override
  _BusinessDetailsTabState createState() => _BusinessDetailsTabState();
}

class _BusinessDetailsTabState extends State<BusinessDetailsTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('/Owner/$ownerId/Businesses/')
            .where('id', isEqualTo: '${widget.businessId}')
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              return ListView(
                children: snapshot.data.documents.map((document) {
                  var date = (document['dateCreated'] as Timestamp).toDate();
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Card(
                          elevation: 3,
                          margin: EdgeInsets.only(
                              left: 10, right: 10, top: 8, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  'Business Name',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14.0),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  '${document['businessName']}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          elevation: 6,
                          margin: EdgeInsets.only(
                              left: 10, right: 10, top: 8, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  'First Name',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14.0),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  '${document['firstName']}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Last Name',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14.0),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  '${document['lastName']}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Email',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14.0),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  '${document['email']}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              
                              Divider(
                                color: Colors.black,
                                height: 20,
                              ),
                              ListTile(
                                title: Text(
                                  'Joined',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19.0),
                                ),
                                subtitle: Text(
                                  '$date',
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.black,
                                      height: 1.3),
                                ),
                                onTap: () {
                                  // Clipboard.setData(new ClipboardData(
                                  //     text: document['dateCreated']
                                  //         .toString()));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
          }
        },
      ),
    );
  }
}
