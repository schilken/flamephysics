import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'the_game.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: Scaffold(body: TheGame().widget)));
}
