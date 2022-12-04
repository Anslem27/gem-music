import 'package:flutter/material.dart';
import 'package:gem/Screens/scrobble/scrobble_home.dart';


class MainView extends StatefulWidget {
  final String username;

  const MainView({super.key, required this.username});

  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SearchView());
  }
}
