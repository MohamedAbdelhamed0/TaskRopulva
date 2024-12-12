import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Good Morning',
        style: Theme.of(context).textTheme.headlineLarge);
  }
}
