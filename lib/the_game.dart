import 'dart:ui';

import 'package:flame/gestures.dart';
import 'package:flame/game.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'the_world.dart';

// This is the type used by the popup menu below.
enum MenuEntry { toggleWorldInfo, addBall, removeBall, increaseScale, decreaseScale }

class TheGame extends BaseGame with TapDetector, HasWidgetsOverlay {
  TheWorld theWorld;
  bool debounceActive = false;
  var numberOfBalls = 2;

  TheGame() {
    addWidgetOverlay(
      'Menu',
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
            alignment: Alignment.bottomRight,
            child: PopupMenuButton<MenuEntry>(
              onSelected: (MenuEntry result) async {
                print("onSelected $result");
                switch (result) {
                  case MenuEntry.toggleWorldInfo:
                    theWorld?.toggleShowWorldInfo();
                    break;
                  case MenuEntry.addBall:
                    numberOfBalls += 1;
                    theWorld = TheWorld(numberOfBalls: numberOfBalls);
                    await theWorld.initializeWorld();
                    break;
                  case MenuEntry.removeBall:
                    numberOfBalls -= 1;
                    theWorld = TheWorld(numberOfBalls: numberOfBalls);
                    await theWorld.initializeWorld();
                    break;
                  case MenuEntry.increaseScale:
                    // TODO: Handle this case.
                    break;
                  case MenuEntry.decreaseScale:
                    // TODO: Handle this case.
                    break;
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<MenuEntry>>[
                const PopupMenuItem<MenuEntry>(
                  value: MenuEntry.toggleWorldInfo,
                  child: Text('Toggle World Info'),
                ),
                const PopupMenuItem<MenuEntry>(
                  value: MenuEntry.addBall,
                  child: Text('Add Ball'),
                ),
                const PopupMenuItem<MenuEntry>(
                  value: MenuEntry.removeBall,
                  child: Text('Remove Ball'),
                ),
                const PopupMenuItem<MenuEntry>(
                  value: MenuEntry.increaseScale,
                  child: Text('Increase scale by 5'),
                ),
                const PopupMenuItem<MenuEntry>(
                  value: MenuEntry.decreaseScale,
                  child: Text('Decrease scale by 5'),
                ),
              ],
            )),
      ),
    );
  }

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
    theWorld = TheWorld(numberOfBalls: numberOfBalls);
    await theWorld.initializeWorld();
  }

  @override
  void onTapUp(TapUpDetails details) {
    theWorld?.handleTap(details.globalPosition);
    super.onTapUp(details);
  }

// This menu button widget updates a _selection field (of type WhyFarther,
// not shown here).

}
