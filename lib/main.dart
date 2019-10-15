import 'package:flutter/material.dart';

import './list.dart';
import './item.dart';
import './model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      routes: <String, WidgetBuilder>{
        //'/splash': (context) => SplashScreen(),
        '/': (context) => PokemonListScreen(),
        //'/pokemon': (context) => PokemonInfoScreen(),
      },
    );
  }
}
