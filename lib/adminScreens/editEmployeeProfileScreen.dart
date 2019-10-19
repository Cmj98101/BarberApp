import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Helpers
import '../helpers/auth.dart';
import '../helpers/globalVariables.dart';

class EditEmployeeProfileScreen extends StatefulWidget {
  EditEmployeeProfileScreen(
      {this.auth,
      this.businessId,
      this.employeeId,
      this.firstName,
      this.lastName});
  final BaseAuth auth;
  final String businessId;
  final String employeeId;
  final String firstName;
  final String lastName;
  @override
  _EditEmployeeProfileScreenState createState() =>
      _EditEmployeeProfileScreenState();
}

enum TimeType { open, close }

class _EditEmployeeProfileScreenState extends State<EditEmployeeProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static final formKey = GlobalKey<FormState>();

  String _firstName;
  String _lastName;

  bool mondayActive = false;
  TextEditingController _firstNameTFController = TextEditingController();
  TextEditingController _lastNameTFController = TextEditingController();

  _unsuccessfullSnackBar(String content) {
    final snackBar = SnackBar(
      content: Text(
        '$content',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w600),
      ),
      duration: Duration(seconds: 5),
      backgroundColor: Colors.red,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  _successfullSnackBar(String content) {
    final snackBar = SnackBar(
      content: Text(
        '$content',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w600),
      ),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.green,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        widget.auth.editEmployee(
            widget.businessId, widget.employeeId, _firstName, _lastName);
        _successfullSnackBar('Successfully updated employee');
        Navigator.pop(context);
      } catch (error) {
        print('ERROR could not edit employee: $error');
        _unsuccessfullSnackBar('Failed to update employee');
      }
    }
  }

  // DateTime startTime = DateTime.parse('$start').toLocal();
  // DateTime endTime = DateTime.parse('$end').toLocal();
  // var formattedStartTime = DateFormat('h:mm:ss a').format(startTime);
  // var formattedEndTime = DateFormat('h:mm:ss a').format(endTime);

  // print(formattedStartTime);
  // print(formattedEndTime);

  @override
  void dispose() {
    super.dispose();
    _firstNameTFController.dispose();
    _lastNameTFController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Employee Profile'),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(12),
          child: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: _firstNameTFController,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (value) =>
                          value.isEmpty ? 'First name can\'t be Emtpy' : null,
                      onSaved: (value) => _firstName = value,
                    ),
                    TextFormField(
                      controller: _lastNameTFController,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (value) =>
                          value.isEmpty ? 'Last name can\'t be Emtpy' : null,
                      onSaved: (value) => _lastName = value,
                    ),
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            top: 30.0,
                          ),
                        ),
                        Container(
                          child: Text('Day Availibility'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 30.0,
                          ),
                        ),
                        Container(
                            height: 320,
                            child: StreamBuilder<QuerySnapshot>(
                                stream: Firestore.instance
                                    .collection(
                                        '/Owner/$ownerId/Businesses/${widget.businessId}/Employees/${widget.employeeId}/Availability/')
                                    .orderBy('order', descending: false)
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return new Center(
                                          child:
                                              new CircularProgressIndicator());
                                    default:
                                      return Column(
                                          children: snapshot.data.documents
                                              .map((document) {
                                        var startTime;
                                        var formatStartTime;

                                        var endTime;
                                        var formatEndTime;
                                        try {
                                          startTime =
                                              (document['start'] as Timestamp)
                                                  .toDate();
                                          formatStartTime = DateFormat('h:mm a')
                                              .format(startTime);
                                        } catch (error) {
                                          startTime = null;
                                        }
                                        try {
                                          endTime =
                                              (document['end'] as Timestamp)
                                                  .toDate();
                                          formatEndTime = DateFormat('h:mm a')
                                              .format(endTime);
                                        } catch (error) {
                                          endTime = null;
                                        }

                                        return Column(
                                          children: <Widget>[
                                            Container(
                                              height: 45,
                                              child: Card(
                                                elevation: 6,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                        // color: Colors.green,
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 7,
                                                                top: 7,
                                                                bottom: 7),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Switch(
                                                              onChanged:
                                                                  (value) {
                                                                Map<String,
                                                                        Object>
                                                                    data = {
                                                                  'isAvailable':
                                                                      value,
                                                                };

                                                                try {
                                                                  Firestore
                                                                      .instance
                                                                      .document(
                                                                          '/Owner/$ownerId/Businesses/${widget.businessId}/Employees/${widget.employeeId}/Availability/${document.documentID}')
                                                                      .updateData(
                                                                          data);
                                                                } catch (error) {
                                                                  print(
                                                                      'ERROR updating ISAVAILABLE: $error');
                                                                }
                                                              },
                                                              value: document[
                                                                  'isAvailable'],
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 15),
                                                            ),
                                                            Text(document[
                                                                'dayOfWeek']),
                                                          ],
                                                        )),
                                                    Container(
                                                      child: Visibility(
                                                        visible: document[
                                                                    'isAvailable'] ==
                                                                false
                                                            ? false
                                                            : true,
                                                        child: Row(
                                                          children: <Widget>[
                                                            FlatButton(
                                                              child: Text(
                                                                  startTime ==
                                                                          null
                                                                      ? 'Open'
                                                                      : '$formatStartTime'),
                                                              onPressed: () {
                                                                bottom(
                                                                    document
                                                                        .documentID,
                                                                    TimeType
                                                                        .open,
                                                                    document[
                                                                        'dayOfWeek'],
                                                                    startTime);
                                                              },
                                                            ),
                                                            Text('-'),
                                                            FlatButton(
                                                              child: Text(endTime ==
                                                                      null
                                                                  ? 'Close'
                                                                  : '$formatEndTime'),
                                                              onPressed: () {
                                                                bottom(
                                                                    document
                                                                        .documentID,
                                                                    TimeType
                                                                        .close,
                                                                    document[
                                                                        'dayOfWeek'],
                                                                    endTime);
                                                                // TODO: add a way to not accept times that extend past the day
                                                              },
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      }).toList());
                                  }
                                })),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 40.0),
                        ),
                        Container(
                          child: Text('Break Hours'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 40.0),
                        ),
                        Container(
                            // height: 220,
                            child: StreamBuilder<QuerySnapshot>(
                                stream: Firestore.instance
                                    .collection(
                                        '/Owner/$ownerId/Businesses/${widget.businessId}/Employees/${widget.employeeId}/Availability/')
                                    // .where('isAvailable', isEqualTo: true)
                                    .orderBy('order', descending: false)
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return new Center(
                                          child:
                                              new CircularProgressIndicator());
                                    default:
                                      return Column(
                                          children: snapshot.data.documents.map(
                                        (document) {
                                          return Column(
                                            children: <Widget>[
                                              Visibility(
                                                visible:
                                                    document['isAvailable'] ==
                                                            false
                                                        ? false
                                                        : true,
                                                child: Container(
                                                  height: 45,
                                                  child: Card(
                                                    elevation: 6,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 25,
                                                                    top: 7,
                                                                    bottom: 7),
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                Text(document[
                                                                    'dayOfWeek']),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              20),
                                                                ),
                                                              ],
                                                            )),
                                                        Container(
                                                          child: Row(
                                                            children: <Widget>[
                                                              FlatButton(
                                                                child: Text(
                                                                    'open'),
                                                                onPressed:
                                                                    () {},
                                                              ),
                                                              Text('-'),
                                                              FlatButton(
                                                                child: Text(
                                                                    'close'),
                                                                onPressed:
                                                                    () {},
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      ).toList());
                                  }
                                })),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                    ),
                    // RaisedButton(
                    //   child: Text(
                    //     'Time Available',
                    //     style: TextStyle(fontSize: 20.0),
                    //   ),
                    //   onPressed: () {
                    //     // showTimePicker(context);
                    //   },
                    // ),
                    RaisedButton(
                        child: Text(
                          'Save Employee',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        onPressed: validateAndSubmit),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  int getWeekDay(String weekDay) {
    for (var i = 0; i < weekDays.length; i++) {
      if (weekDay == weekDays[i]) {
        print('WeekDay : ${i + 1}');
        return i + 1;
      }
    }
    return null;
  }

  DateTime setTime(int currentWeekDay, int selectedWeekDay, String time) {
    int difference;
//TODO: BUG when user changes day on Sunday ex: currentdayofweek is sunday changed day of the  week is monday but it will subtract to the past monday!
    var format;
    if (currentWeekDay == selectedWeekDay) {
      difference = 0;
      format = DateFormat('yyyy-MM-dd HH:mm:ss').parse(
          '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + difference} $time');
    } else if (currentWeekDay < selectedWeekDay) {
      print('current weekday is less');
      difference = selectedWeekDay - currentWeekDay;
      format = DateFormat('yyyy-MM-dd HH:mm:ss').parse(
          '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day + difference} $time');
    } else {
      print('current weekday is greater');
      difference = currentWeekDay - selectedWeekDay;
      format = DateFormat('yyyy-MM-dd HH:mm:ss').parse(
          '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day - difference} $time');
    }
    print('$format');

    return format;
  }

  TimeType timeType;
  void bottom(
      String documentId, TimeType type, String weekDay, DateTime startTime) {
    Picker ps = new Picker(
        hideHeader: true,
        adapter: new DateTimePickerAdapter(
            type: PickerDateTimeType.kHM_AP, value: startTime),
        onConfirm: (Picker picker, List value) {
          // print((picker.adapter as DateTimePickerAdapter).value);
          DateTime now = DateTime.parse(
                  "${(picker.adapter as DateTimePickerAdapter).value}")
              .toLocal();
          print('$now');
          // var addedTime = now.add(Duration(minutes: 15 * i));
          String formatedTime = DateFormat('HH:mm:ss').format(now);
          timeType = type;
          int currentWeekDay = DateTime.now().weekday;
          int selectedWeekDay = getWeekDay(weekDay);

          Map<String, Object> data;
          var dayOfTheWeek = Firestore.instance.document(
              '/Owner/$ownerId/Businesses/${widget.businessId}/Employees/${widget.employeeId}/Availability/$documentId');
          switch (timeType) {
            case TimeType.open:
              var time = setTime(currentWeekDay, selectedWeekDay, formatedTime);
              data = {'start': time};
              dayOfTheWeek.updateData(data);

              break;
            case TimeType.close:
              var time = setTime(currentWeekDay, selectedWeekDay, formatedTime);

              data = {'end': time};
              dayOfTheWeek.updateData(data);

              break;
          }

          // timeAvailable.add('$time');
          // print(time);
        });

    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            color: Colors.white,
            height: 250,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: new Text(
                            PickerLocalizations.of(context).cancelText)),
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ps.onConfirm(ps, ps.selecteds);
                        },
                        child: new Text(
                            PickerLocalizations.of(context).confirmText))
                  ],
                ),
                ps.makePicker(),
              ],
            ),
          );
        });
  }
}
