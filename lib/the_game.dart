import 'dart:ui';

import 'package:flame/gestures.dart';
import 'package:flame/game.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'the_world.dart';

class TheGame extends BaseGame with TapDetector {
  TheWorld theWorld;
  bool debounceActive = false;

  @override
  void render(Canvas canvas) {
    theWorld?.render(canvas);
  }

  @override
  void update(double t) {
    theWorld?.update(t);
  }

  @override
  void resize(Size size) async {
    print("resize $size");
    if (debounceActive) return;
    debounceActive = true;
    await Future.delayed(Duration(seconds: 1));
    debounceActive = false;
    print("really resize");
    super.resize(size);
    print("window.physicalSize ${window.physicalSize}"); 
    theWorld = TheWorld();
    await theWorld.initializeWorld();
  }

  @override
  void onTapUp(TapUpDetails details) {
    theWorld?.handleTap(details.globalPosition);
    super.onTapUp(details);
  }
}
