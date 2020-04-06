import 'package:box2d_flame/box2d.dart';
import 'package:flame/box2d/box2d_component.dart';

class DummyBody extends BodyComponent {

  DummyBody(Box2DComponent box) : super(box) {
    final shape = PolygonShape();
    shape.setAsBoxXY(.1, .1);
    final fixtureDef = FixtureDef();
    fixtureDef.shape = shape;
    final bodyDef = BodyDef();
    bodyDef.position = Vector2(0, 0);
    Body groundBody = world.createBody(bodyDef);
    groundBody.createFixtureFromFixtureDef(fixtureDef);
    this.body = groundBody;
  }
}
