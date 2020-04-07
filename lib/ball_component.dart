import 'dart:async';
import 'dart:ui';

import 'package:box2d_flame/box2d.dart' hide Timer, Position;
import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/components/mixins/tapable.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';

import 'utils.dart';

class BallComponent extends BodyComponent with Tapable {
  static const num PERSON_RADIUS = 1.0;
  double x = 0.0, y = 0.0, angle = 0.0;
  double width = 150.0, height = 20.0;
  Color get debugColor => const Color(0xFF444444);
  Paint get _debugPaint => Paint()
    ..color = debugColor
    ..style = PaintingStyle.stroke;
  TextConfig get debugTextConfig => TextConfig(color: debugColor, fontSize: 12);

  ImagesLoader images = ImagesLoader();
  Timer impulsTrigger;
  int id;

  BallComponent(box2d, Vector2 position, this.id) : super(box2d) {
    _loadImages();
    _createBody(position);
  }

  void _loadImages() {
    images.load("smiley0", "icons8-neutral-transparent.png");
    images.load("smiley1", "icons8-neutral-yellow.png");
  }

  Offset worldVector2ToScreenOffset(Vector2 position) {
    return Offset((position.x + viewport.width / 2) * 20,
        (viewport.height / 2 - position.y) * 20);
  }

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    if (images.isLoading) {
      return;
    }
    var image = images.get("smiley$id");
    paintImage(
        canvas: canvas,
        image: image,
        rect: Rect.fromCircle(center: center, radius: radius),
        flipHorizontally: false,
        fit: BoxFit.contain);
  }

  // void render(Canvas canvas) {
  //   if (images.isLoading) {
  //     return;
  //   }
  //   Fixture fixture = body.getFixtureList();
  //   final CircleShape circle = fixture.getShape();
  //   Offset center = worldVector2ToScreenOffset(body.position);
  //   paintImage(
  //       canvas: canvas,
  //       image: images.get("smiley$id"),
  //       rect: Rect.fromCircle(
  //           center: center, radius: circle.radius * viewport.scale),
  //       fit: BoxFit.contain);
  //   renderDebugMode(canvas);    
  // }

  void _createBody(Vector2 position) {
    final shape = CircleShape();
    shape.radius = BallComponent.PERSON_RADIUS;
    shape.p.x = 0.0;

    final fixtureDef = FixtureDef();
    fixtureDef.shape = shape;
    fixtureDef.restitution = 1.0;
    fixtureDef.density = 0.99;
    fixtureDef.friction = 0.00;
    fixtureDef.userData = this;

    final bodyDef = BodyDef();
    bodyDef.linearVelocity = Vector2(0.0, 0.0);
    bodyDef.position = position;
    bodyDef.type = BodyType.DYNAMIC;
    this.body = world.createBody(bodyDef)
      ..createFixtureFromFixtureDef(fixtureDef);
  }

  void impulse(Offset velocity) {
    //print("impulse on person $id ${velocity.dx}/${velocity.dy}}");
    Vector2 force = Vector2(velocity.dx, velocity.dy)..scale(100.0);
    body.applyLinearImpulse(force, center, true);
  }

  void stop() {
    body.linearVelocity = Vector2(0.0, 0.0);
    body.angularVelocity = 0.0;
  }

  void setVelocity(Vector2 direction, double speed) {
    body.linearVelocity = direction;
    body.angularVelocity = speed;
  }

  @override
  String toString() {
    return "linearVelocity ${body.linearVelocity}";
  }

  Rect toRect() {
    var rect = Rect.fromCircle(
        center: Offset(body.position.x, body.position.y),
        radius: BallComponent.PERSON_RADIUS);
    return rect;
  }

  void renderDebugMode(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, width, height), _debugPaint);
    Offset center = worldVector2ToScreenOffset(body.position);
    debugTextConfig.render(
        canvas,
        "x: ${center.dx.toStringAsFixed(1)} y:${center.dy.toStringAsFixed(1)}",
        Position(10, height*2));

    final Rect rect = toRect();
    final dx = rect.right;
    final dy = rect.bottom;
    
    debugTextConfig.render(
        canvas,
        "W x:${rect.center.dx.toStringAsFixed(2)} y:${rect.center.dy.toStringAsFixed(2)}",
        Position(10, height));
  }
}
