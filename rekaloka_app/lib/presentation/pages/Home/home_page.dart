import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
   static const ROUTE_NAME = '/home';

  const HomePage({ super.key });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: 
      Text('Home Page'),
      
    );
  }
}