import 'package:flutter/material.dart';
import 'businessDetailsTab.dart';
import 'businessEmployeesTab.dart';

class BusinessDetailsScreen extends StatefulWidget {
  BusinessDetailsScreen({this.businessId});
  final String businessId;
  @override
  _BusinessDetailsScreenState createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'Details',
            style: TextStyle(color: Colors.black),
          ),
          bottom: TabBar(
            indicatorColor: Colors.black,
            controller: _tabController,
            labelStyle: TextStyle(color: Colors.green),
            tabs: <Widget>[
              Tab(
                  icon: Icon(
                Icons.monetization_on,
                color: _tabController.index == 0 ? Colors.green : Colors.grey,
              )),
              Tab(
                  icon: Icon(
                Icons.people,
                color: _tabController.index == 1 ? Colors.blue : Colors.grey,
              )),
              Tab(
                  icon: Icon(
                Icons.info,
                color: _tabController.index == 2 ? Colors.black : Colors.grey,
              )),
            ],
          ),
        ),
        body: TabBarView(controller: _tabController,
          children: <Widget>[
            // TODO: Add a page for Anaylitics
            Icon(Icons.directions_car),
            // TODO: ADD a page for Employees
            BusinessEmployeesTab(businessId: widget.businessId,),
            BusinessDetailsTab(businessId: widget.businessId,)
          ],
        ),
      ),
    );
    //
  }
}

