import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class StatusAppBar extends StatefulWidget implements PreferredSizeWidget {
  const StatusAppBar({super.key, required this.title});

  final String title;

  @override
  State<StatusAppBar> createState() => _StatusAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _StatusAppBarState extends State<StatusAppBar> {
  var isConnected = false;

  @override
  initState() {
    super.initState();

    InternetConnection().hasInternetAccess.then((result) {
      setState(() {
        isConnected = result;
      });
    });

    InternetConnection().onStatusChange.listen((InternetStatus status) {
      setState(() {
        isConnected = status == InternetStatus.connected;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const connectedIcon = IconButton(
      icon: Icon(
        Icons.wifi,
        weight: 700,
        color: Colors.green,
      ),
      tooltip: 'Connected',
      onPressed: null,
    );
    const disconnectedIcon = IconButton(
      icon: Icon(
        Icons.wifi_off,
        color: Colors.red,
      ),
      tooltip: 'Not connected',
      onPressed: null,
    );

    return AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(color: Colors.white),
      ),
      actions: <Widget>[isConnected ? connectedIcon : disconnectedIcon],
      backgroundColor: Colors.black12,
    );
  }
}
