import 'package:flutter/widgets.dart';

import 'the_game.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TheGame().widget);
}