import 'dart:async';
//import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:math';
import 'dart:ui';

import 'package:box2d_flame/box2d.dart' hide Timer, Position;
import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flame/box2d/viewport.dart' as box2d_viewport;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:audioplayers/audioplayers.dart';

import 'ball_component.dart';
import 'dummy_body.dart';

class TheWorld extends Box2DComponent implements ContactListener {
  World world;
  AudioPlayer fixedPlayer;

  List<BallComponent> balls;
  List<Vector2> ankerPoints;

  DummyBody wall;
  TextConfig get debugTextConfig =>
      TextConfig(color: Color(0xFF444444), fontSize: 14);
  bool showWorldInfo = false;
  Timer impulsTrigger;
  var numberOfBalls = 3;
  double scale = 20.0;

  TheWorld({this.numberOfBalls})
      : super(
            dimensions: window.physicalSize / window.devicePixelRatio,
            scale: 20.0,
            gravity: 0);

  static const distanceBetweenBalls = 2.02;
  Vector2 ankerPoint;

  Future<void> initializeWorldWithScale(double scale) async {
    this.scale = scale;
    world = World.withGravity(Vector2(0, -10));
    viewport = box2d_viewport.Viewport(
        window.physicalSize / window.devicePixelRatio, scale);
    wall = DummyBody(this);

    add(wall);
    initializeBalls();
    world.setContactListener(this);
    if (!kIsWeb) {
      await Flame.audio.load("billiard-tick.wav");
    }
  }

  Future<void> initializeWorld() async {
    world = World.withGravity(Vector2(0, -10));
    viewport = box2d_viewport.Viewport(
        window.physicalSize / window.devicePixelRatio, scale);
    wall = DummyBody(this);

    add(wall);
    initializeBalls();
//    impulsTrigger = Timer(Duration(seconds: 3), () {
//      pushBalls(1);
//    });
    world.setContactListener(this);
    if (!kIsWeb) {
      await Flame.audio.load("billiard-tick.wav");
    }
  }

  void initializeBalls() {
    print(
        "initializeWorld viewport: ${viewport.size.width} ${viewport.size.height} ${window.devicePixelRatio} ");
    balls = [];
    ankerPoint = Vector2(0, 0);
    double x = 0 - (numberOfBalls / 2) * distanceBetweenBalls;
    var distanceToEdge = min(viewport.width, viewport.height) / 2;
    final ropeLength = distanceToEdge - distanceToEdge / 5;
    for (var ix = 0; ix < numberOfBalls; ix++) {
      var y = sqrt(ropeLength * ropeLength - x * x);
      var ballPosition = Vector2(x, -y);
      var ball = BallComponent(this, ballPosition, ix);
      add(ball);
      balls.add(ball);
      var djd = DistanceJointDef();
      //djd.frequencyHz = 10.0;
      djd.dampingRatio = 1.0;
      djd.initialize(wall.body, balls[ix].body, ankerPoint, ballPosition);
      world.createJoint(djd);
      x += distanceBetweenBalls;
    }
  }

  void pushBalls(int count) {
    for (var ix = 0; ix < count; ix++) {
      pushBall(ix);
    }
  }

  void pushBall(int ix) {
    balls[ix].impulse(Offset(-1.25, 0.0));
  }

  @override
  void update(t) {
    super.update(t);
    //cameraFollow(balls[0], horizontal: 0.5, vertical: 0.5);
  }

  @override
  void render(canvas) {
    Rect bgRect =
        Rect.fromLTWH(0, 0, viewport.size.width, viewport.size.height);
    Paint bgPaint = Paint();
    bgPaint.color = Color(0xff33aa33);
    canvas.drawRect(bgRect, bgPaint);

    Paint linePaint = Paint();
    linePaint.color = Color(0xff888888);
    linePaint.strokeWidth = 2;
    for (var ix = 0; ix < numberOfBalls; ix++) {
      var p1 = worldVector2ToScreenOffset(ankerPoint);
      var p2 = worldVector2ToScreenOffset(balls[ix].body.position);
      canvas.drawLine(p1, p2, linePaint);
    }
    if (showWorldInfo) {
      debugTextConfig.render(
          canvas,
          "window.physicalSize ${window.physicalSize}\n"
          "window.devicePixelRatio: ${window.devicePixelRatio}\n"
          "scale: $scale\n"
          "viewport width:${viewport.width.toStringAsFixed(2)} height:${viewport.height.toStringAsFixed(2)}\n"
          "screen: ${bgRect}\n"
          "viewport.size: ${viewport.size}\n"
          "viewport.extents: ${viewport.extents}\n"
          "viewport.center: ${viewport.center}",
          Position(10, 30));
    }
    super.render(canvas);
  }

  Offset screenOffsetToWorldOffset(Offset position) {
    return Offset(position.dx / scale - viewport.width / 2,
        viewport.height / 2 - position.dy / scale);
  }

  Offset worldVector2ToScreenOffset(Vector2 position) {
    return Offset((position.x + viewport.width / 2) * scale,
        (viewport.height / 2 - position.y) * scale);
  }

  void handleTap(Offset position) {
//    print("position: $position");
    for (var nn = 0; nn < balls.length; nn++) {
      if (balls[nn].checkTapOverlap(screenOffsetToWorldOffset(position))) {
        pushBall(nn);
        return;
      }
    }
    balls.forEach((ball) {
      ball.stop();
    });
  }

  void toggleShowWorldInfo() {
    showWorldInfo = !showWorldInfo;
  }

  AudioPlayer _player(PlayerMode mode) {
    return fixedPlayer ?? new AudioPlayer(mode: mode);
  }

  Future<AudioPlayer> playForWeb(String fileName,
      {double volume = 1.0,
      PlayerMode mode = PlayerMode.MEDIA_PLAYER,
      bool stayAwake}) async {
    //var baseUrl = html.window.location.href; // this didn't work
    String baseUrl = js.context['location']['href'];
    var url = baseUrl.replaceFirst('#/', 'assets/assets/audio/$fileName');
    print("baseUrl: $baseUrl, url: $url");
    AudioPlayer player = _player(mode);
    await player.play(
      url,
      volume: volume,
      respectSilence: false,
      stayAwake: stayAwake,
    );
    return player;
  }

  @override
  void beginContact(Contact contact) async {
    var ballA = contact.fixtureA.userData as BallComponent;
    var ballB = contact.fixtureB.userData as BallComponent;
//    print("beginContact");
    var vA = ballA.body.linearVelocity;
    var vB = ballB.body.linearVelocity;
    var vDiff = vA - vB;
    if (vDiff.length2 > 3) {
      var volume = min(vDiff.length2 / 1000, 1.0);
      //print("${vA.length2} ${vB.length2} ${vDiff.length2} $volume");
      if (!kIsWeb) {
        Flame.audio.play("billiard-tick.wav", volume: volume);
      } else {
        playForWeb("billiard-tick.wav", volume: volume);
      }
    }
  }

  @override
  void endContact(Contact contact) {}

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {}

  @override
  void preSolve(Contact contact, Manifold oldManifold) {}
}
