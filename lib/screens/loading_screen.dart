import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/chargement.png', width: 300, height: 350),
            SizedBox(height: 20),
            Text('Chargements des données en cours...'),
          ],
        ),
      ),
    );
  }
}
