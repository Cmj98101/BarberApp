import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
import 'package:intl/intl.dart';

// Helpers
import '../helpers/auth.dart';

class ClientScheduleScreen extends StatefulWidget {
  ClientScheduleScreen({this.businessId, this.employeeId, this.auth});
  final String businessId;
  final String employeeId;
  final BaseAuth auth;
  @override
  _ClientScheduleScreenState createState() => _ClientScheduleScreenState();
}

enum DataState { loading, complete }
enum PaymentPlace { inShopPayment, mobilePayment }

class _ClientScheduleScreenState extends State<ClientScheduleScreen> {
  void _handleNewDate(date) {
    setState(() {
      _selectedDay = date;
      _selectedEvents = _events[_selectedDay] ?? [];
      int loopTotal = _events[_selectedDay][0]['loopTotal'];
      print(loopTotal);
      if (loopTotal != null) {
        for (var i = 0; i < loopTotal; i++) {
          _events[_selectedDay][i]['isSelected'] = false;
        }
      }
    });
    // print(_selectedEvents);
  }

  List _selectedEvents;
  DateTime _selectedDay;
  final Map _events = {
    // DateTime(2019, 9, 30): [
    //   {'name': 'Event A', 'isDone': true},
    // ],
    // DateTime(2019, 9, 29): [
    //   {'name': 'Event A', 'isDone': true},
    //   {'name': 'Event B', 'isDone': true},
    // ],
  };
  final List _services = [
    {'serviceName': 'Gent\'s Cut', 'time': 45, 'isSelected': false},
    {'serviceName': 'Gent\'s Shave', 'time': 30, 'isSelected': false},
    {'serviceName': 'Senior Gent\'s Cut', 'time': 45, 'isSelected': false},
    {'serviceName': 'Gent\'s Cut & Shave', 'time': 1, 'isSelected': false}
  ];
  List daysOfTheWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  void addDataToList(
      List list,
      List list2,
      DateTime startTime,
      String time,
      int dayOfTheWeekindex,
      int index,
      var formattedTime,
      int loopTotalAmmount,
      time24Format) {
    // print('$time24Format');
    list.add({
      'name': '${daysOfTheWeek[dayOfTheWeekindex]}',
      'time': '$time',
      'date': formattedTime,
      'available': true,
      'isDone': true,
      'isSelected': false,
      'format24': time24Format,
      'loopTotal': loopTotalAmmount
    });

    for (var i = 0; i < 60; i++) {
      _events.addAll({
        DateTime(DateTime.now().year, DateTime.now().month,
            startTime.day + (7 * i)): list,
      });
    }
  }

  void subtractDifference(List list, int dayofTheWeek, int dayOfTheWeekindex) {
    var currentWeekDay = DateTime.now().weekday;
    int difference;
    if (currentWeekDay < dayofTheWeek) {
      difference = dayofTheWeek - currentWeekDay;
      print(
          '${daysOfTheWeek[dayOfTheWeekindex]}: $dayofTheWeek - $currentWeekDay(currentWD) = $difference');
      for (var x = 0; x < 75; x++) {
        _events.addAll({
          DateTime(DateTime.now().year, DateTime.now().month,
              (DateTime.now().day + difference) + (7 * x)): list
        });
      }
    } else {
      difference = currentWeekDay - dayofTheWeek;
      print(
          '${daysOfTheWeek[dayOfTheWeekindex]}: $currentWeekDay(currentWD) - $dayofTheWeek = $difference');
      for (var x = 0; x < 75; x++) {
        _events.addAll({
          DateTime(DateTime.now().year, DateTime.now().month,
              (DateTime.now().day - difference) + (7 * x)): list
        });
      }
    }
  }

  void dayNotAvailable(
    List list,
    int dayOfTheWeekindex,
  ) {
    var currentWeekDay = DateTime.now().weekday;
    var monday = DateTime.monday;
    var tuesday = DateTime.tuesday;
    var wednesday = DateTime.wednesday;
    var thursday = DateTime.thursday;
    var friday = DateTime.friday;
    var saturday = DateTime.saturday;
    var sunday = DateTime.sunday;

    list.add({
      'name': '${daysOfTheWeek[dayOfTheWeekindex]}',
      'isDone': true,
      'available': false,
    });
    // print(DateTime.now().weekday == dayOfTheWeekindex + 1);
    if (currentWeekDay == dayOfTheWeekindex + 1) {
      for (var x = 0; x < 75; x++) {
        _events.addAll({
          DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + (7 * x)): list
        });
      }
    } else if (dayOfTheWeekindex + 1 == 1) {
      subtractDifference(list, monday, dayOfTheWeekindex);
    } else if (dayOfTheWeekindex + 1 == 2) {
      subtractDifference(list, tuesday, dayOfTheWeekindex);
    } else if (dayOfTheWeekindex + 1 == 3) {
      subtractDifference(list, wednesday, dayOfTheWeekindex);
    } else if (dayOfTheWeekindex + 1 == 4) {
      subtractDifference(list, thursday, dayOfTheWeekindex);
    } else if (dayOfTheWeekindex + 1 == 5) {
      subtractDifference(list, friday, dayOfTheWeekindex);
    } else if (dayOfTheWeekindex + 1 == 6) {
      subtractDifference(list, saturday, dayOfTheWeekindex);
    } else if (dayOfTheWeekindex + 1 == 7) {
      subtractDifference(list, sunday, dayOfTheWeekindex);
    }
  }

  DataState dataState = DataState.loading;
  void getAvailabilities() async {
    // 1.) Ininitialize required Variables
    List<Map<dynamic, dynamic>> employeeSundayData =
        List<Map<dynamic, dynamic>>();
    List<Map<dynamic, dynamic>> employeeMondayData =
        List<Map<dynamic, dynamic>>();
    List<Map<dynamic, dynamic>> employeeTuesdayData =
        List<Map<dynamic, dynamic>>();
    List<Map<dynamic, dynamic>> employeeWednesDayData =
        List<Map<dynamic, dynamic>>();
    List<Map<dynamic, dynamic>> employeeThursdayData =
        List<Map<dynamic, dynamic>>();
    List<Map<dynamic, dynamic>> employeeFridayData =
        List<Map<dynamic, dynamic>>();
    List<Map<dynamic, dynamic>> employeeSaturdayData =
        List<Map<dynamic, dynamic>>();
    List employeeSundayData2 = List();
    List employeeMondayData2 = List();
    List employeeTuesdayData2 = List();
    List employeeWednesDayData2 = List();
    List employeeThursdayData2 = List();
    List employeeFridayData2 = List();
    List employeeSaturdayData2 = List();

    // 2.) Loop through every day of the week [Monday-Sunday]
    for (var i = 0; i < daysOfTheWeek.length; i++) {
      // 3.) Get available times from Firebase and await for response
      await widget.auth
          .getAvailibilityTimes(
              widget.businessId, widget.employeeId, daysOfTheWeek[i].toString())
          .then((employeeList) {
        // 4.) Check {employeeList} to see if day of the week [availablity] == true
        if (employeeList[2] == true) {
          var startTime = (employeeList[0] as Timestamp).toDate();
          var endTime = (employeeList[1] as Timestamp).toDate();
          // var formatStartTime = DateFormat('h:mm a').format(startTime);
          // var formatEndTime = DateFormat('h:mm a').format(endTime);

          var difference = endTime.difference(startTime).inHours;

          var incrementBy15 = difference * 4 + 1;
          for (var x = 0; x < incrementBy15; x++) {
            var addedTime = startTime.add(Duration(minutes: 15 * x));
            var time = DateFormat('h:mm a').format(addedTime);
            var time24Format = DateFormat('HH:mm:ss').format(addedTime);
            var formattedTime;

            formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(
                '${DateTime.now().year}-${DateTime.now().month}-${startTime.day} $time24Format');

            if (daysOfTheWeek[i] == 'Sunday') {
              addDataToList(employeeSundayData, employeeSundayData2, startTime,
                  time, i, x, formattedTime, incrementBy15, time24Format);
            } else if (daysOfTheWeek[i] == 'Monday') {
              addDataToList(employeeMondayData, employeeMondayData2, startTime,
                  time, i, x, formattedTime, incrementBy15, time24Format);
            } else if (daysOfTheWeek[i] == 'Tuesday') {
              addDataToList(
                  employeeTuesdayData,
                  employeeTuesdayData2,
                  startTime,
                  time,
                  i,
                  x,
                  formattedTime,
                  incrementBy15,
                  time24Format);
            } else if (daysOfTheWeek[i] == 'Wednesday') {
              addDataToList(
                  employeeWednesDayData,
                  employeeWednesDayData2,
                  startTime,
                  time,
                  i,
                  x,
                  formattedTime,
                  incrementBy15,
                  time24Format);
            } else if (daysOfTheWeek[i] == 'Thursday') {
              addDataToList(
                  employeeThursdayData,
                  employeeThursdayData2,
                  startTime,
                  time,
                  i,
                  x,
                  formattedTime,
                  incrementBy15,
                  time24Format);
            } else if (daysOfTheWeek[i] == 'Friday') {
              addDataToList(employeeFridayData, employeeFridayData2, startTime,
                  time, i, x, formattedTime, incrementBy15, time24Format);
            } else if (daysOfTheWeek[i] == 'Saturday') {
              addDataToList(
                  employeeSaturdayData,
                  employeeSaturdayData2,
                  startTime,
                  time,
                  i,
                  x,
                  formattedTime,
                  incrementBy15,
                  time24Format);
            } else {
              print('DAY NOT IN LIST');
            }
          }
        } else {
          // Else [availability] != true
          if (daysOfTheWeek[i] == 'Monday') {
            print('false ${daysOfTheWeek[i]} $i');
            dayNotAvailable(employeeMondayData, i);
            return;
          } else if (daysOfTheWeek[i] == 'Tuesday') {
            print('false ${daysOfTheWeek[i]} $i');
            dayNotAvailable(employeeTuesdayData, i);
            return;
          } else if (daysOfTheWeek[i] == 'Wednesday') {
            print('false ${daysOfTheWeek[i]} $i');
            dayNotAvailable(employeeWednesDayData, i);
            return;
          } else if (daysOfTheWeek[i] == 'Thursday') {
            print('false ${daysOfTheWeek[i]} $i');
            dayNotAvailable(employeeThursdayData, i);
            return;
          } else if (daysOfTheWeek[i] == 'Friday') {
            print('false ${daysOfTheWeek[i]} $i');
            dayNotAvailable(employeeFridayData, i);
            return;
          } else if (daysOfTheWeek[i] == 'Saturday') {
            print('false ${daysOfTheWeek[i]} $i');
            dayNotAvailable(employeeSaturdayData, i);
            return;
          } else if (daysOfTheWeek[i] == 'Sunday') {
            print('false ${daysOfTheWeek[i]} $i');
            dayNotAvailable(employeeSundayData, i);
            return;
          } else {
            print('DAY NOT IN LIST');
            return;
          }
          // print('Not Available ${daysOfTheWeek[i]}');
        }
      });
    }
    print('done');
    setState(() {
      dataState = DataState.complete;
    });
  }

  @override
  void initState() {
    super.initState();
    getAvailabilities();
    _selectedEvents = _events[_selectedDay] ?? [];
  }

  void scheduleAppointment() {}
  PaymentPlace paymentPlace = PaymentPlace.inShopPayment;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduling with'),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(width: .4, color: Colors.black))),
        height: 95,
        // color: Colors.red,
        child: Row(
          children: <Widget>[
            Container(
              child: Text('\$50',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              margin: EdgeInsets.only(left: 30.0),
            ),
            Container(
                margin: EdgeInsets.only(right: 30.0),
                child: RaisedButton(color: Colors.green[900],elevation: 4,
                  onPressed: () {
                    scheduleAppointment();
                  },
                  child: Text('Book', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w800,letterSpacing: 1.5)),
                ))
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
      body: Container(
        // color: Colors.blue,
        padding: EdgeInsets.only(top: 12.0, bottom: 0, left: 20.0, right: 20.0),
        // color: Colors.red,
        child: ListView(
          children: <Widget>[
            Text(
              'Select a Service',
              style: TextStyle(fontSize: 18),
            ),
            Padding(
              padding: EdgeInsets.only(top: 14.0),
            ),
            _buildServiceList(),
            Text('Select a Date & Time', style: TextStyle(fontSize: 18)),
            Padding(
              padding: EdgeInsets.only(top: 14.0),
            ),
            Padding(
              padding: EdgeInsets.only(top: 14.0),
            ),
            Container(
              child: dataState == DataState.loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Calendar(
                      events: _events,
                      onRangeSelected: (range) =>
                          print("Range is ${range.from}, ${range.to}"),
                      onDateSelected: (date) => _handleNewDate(date),
                      isExpandable: false,
                      showTodayIcon: true,
                      eventDoneColor: Colors.transparent,
                      eventColor: Colors.transparent),
            ),
            _buildEventList(),
            Text('Payment', style: TextStyle(fontSize: 18)),
            Padding(
              padding: EdgeInsets.only(top: 14.0),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: InkWell(
                    onTap: () {
                      setState(() {
                        paymentPlace = PaymentPlace.mobilePayment;
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.check_circle,
                          color: paymentPlace == PaymentPlace.mobilePayment
                              ? Colors.green
                              : Colors.black,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                        ),
                        Text('Mobile Payment', style: TextStyle(fontSize: 16))
                      ],
                    ),
                  )),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  ),
                  Container(
                      child: InkWell(
                    onTap: () {
                      setState(() {
                        paymentPlace = PaymentPlace.inShopPayment;
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.check_circle,
                          color: paymentPlace == PaymentPlace.inShopPayment
                              ? Colors.green
                              : Colors.black,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                        ),
                        Text('In Shop', style: TextStyle(fontSize: 16))
                      ],
                    ),
                  ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _serviceSelected(int index) {
    for (var service in _services) {
      service['isSelected'] = false;
    }
    if (_services[index]['isSelected'] == false) {
      setState(() {
        _services[index]['isSelected'] = true;
      });
      print(_services[index]['serviceName']);
    } else {
      setState(() {
        _services[index]['isSelected'] = false;
      });
    }
  }

  void _timeSelected(int index) {
    var formattedTime;
    print(index);
    formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(
        '${_selectedDay.year}-${_selectedDay.month}-${_selectedDay.day} ${_selectedEvents[index]['format24']}');
    int totalLoopAmmount = _selectedEvents[index]['loopTotal'];
    for (var i = 0; i < totalLoopAmmount; i++) {
      _selectedEvents[i]['isSelected'] = false;
    }
    setState(() {
      _selectedEvents[index]['isSelected'] = true;
    });

    print('isSelectedtime: ${_selectedEvents[index]}  $formattedTime');
  }

  Widget _buildServiceList() {
    return Container(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) => Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 70,
                  child: Card(
                    child: ListTile(
                      title: Text('${_services[index]['serviceName']}'),

                      leading: Icon(
                        Icons.check_circle,
                        color: _services[index]['isSelected'] == true
                            ? Colors.green
                            : null,
                      ),
                      trailing: Text(
                        '${_services[index]['time']} min.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        _serviceSelected(index);
                      },
                      // selected: _services[index]['isSelected'],
                    ),
                  ),
                ),
              ],
            ),
          ),
          itemCount: _services.length,
        ));
  }

  Widget _buildEventList() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) => Container(
          // decoration: BoxDecoration(
          //   border: Border(
          //       // bottom: BorderSide(width: 1.5, color: Colors.black12),
          //       ),
          // ),
          // padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),

          child: _selectedEvents[index]['available'] == true
              ? Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                    ),
                    RaisedButton(
                      color: _selectedEvents[index]['isSelected'] == true
                          ? Colors.green
                          : Colors.transparent,
                      elevation: 0,
                      highlightColor: Colors.yellow[800],
                      // splashColor: Colors.yellow[800],
                      animationDuration: Duration(milliseconds: 1),
                      child: Text(_selectedEvents[index]['time'].toString()),
                      onPressed: () {
                        _timeSelected(index);
                      },
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black, width: 2),
                          borderRadius: new BorderRadius.circular(30.0)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 15),
                    )
                  ],
                )
              : Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'NOT AVAILABLE',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
        ),
        itemCount: _selectedEvents.length,
      ),
    );
  }
}
