import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';
import 'package:habitur/providers/network_state_provider.dart';
import 'package:provider/provider.dart';

class NetworkIndicator extends StatelessWidget {
  const NetworkIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: Provider.of<NetworkStateProvider>(context).isConnected ? 0 : 30,
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOutSine,
      child: AnimatedOpacity(
        child: Icon(Icons.wifi_off, color: kRed, size: 30),
        opacity: Provider.of<NetworkStateProvider>(context).isConnected ? 0 : 1,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOutSine,
      ),
    );
  }
}
