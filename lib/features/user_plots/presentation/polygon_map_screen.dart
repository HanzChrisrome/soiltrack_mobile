import 'package:flutter/material.dart';

class PolygonMapScreen extends StatefulWidget {
  const PolygonMapScreen({super.key});

  @override
  _PolygonMapScreenState createState() => _PolygonMapScreenState();
}

class _PolygonMapScreenState extends State<PolygonMapScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lopez Jaena Polygon Map"),
      ),
    );
  }
}
