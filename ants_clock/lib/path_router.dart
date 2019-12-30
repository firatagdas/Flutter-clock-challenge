import 'dart:math';

import 'ant.dart';

class BoundingCircle {
  final Point<double> center;

  final double radius;

  BoundingCircle(this.center, this.radius);

  factory BoundingCircle.fromAnt(Ant ant) {
    return BoundingCircle(Point(ant.position.x, ant.position.y), Ant.size);
  }

  Point<double> getTangentIntersectionPoint(Point<double> point) {
    // Let circle center be 0,0
    // a^2 + b^2 = radius^2

    // 9a^2 + (4 - 5a)^2 - 36 = 0
    // -> 16 - 20a - 20a + 25a^2
    // 34a^2 -40a - 20 = 0

    // a^2 + ((radius^2 - x * a) / y)^2 = radius^2
    // a^2 + ((radius^2 - x * a)^2 / y^2) = radius^2
    // y^2 * a^2 + (radius^2 - x * a)^2 = radius^2 * y^2
    // y^2 * a^2 + (radius^2 - x * a)^2 - (radius^2 * y^2) = 0
    // y^2 * a^2 + radius^4 - (radius^2 * x)a - (radius^2 * x)a + x^2 * a^2 - (radius^2 * y^2) = 0
    // y^2 * a^2 + x^2 * a^2 - (radius^2 * x)a - (radius^2 * x)a - (radius^2 * y^2) + radius^4 = 0

    final p = point - center;
    final a = pow(p.x, 2) + pow(p.y, 2);
    final b = -2 * (pow(radius, 2) * p.x);
    final c = pow(radius, 4) - (pow(radius, 2) * pow(p.y, 2));

    final x = (-b + sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);
    final y = p.y != 0 ? (pow(radius, 2) - x * p.x) / p.y : sqrt(pow(radius, 2) - pow(x, 2));

    return Point(x, y) + center;
  }
}

class Segment {
  final Point<double> begin;

  final Point<double> end;

  final Rectangle<double> rectangle;

  Segment(this.begin, this.end) : rectangle = Rectangle.fromPoints(begin, end);

  bool intersectsWithBoundingCircle(BoundingCircle circle) {
    // Having line formula as: y = x * a + b

    // Segment line formula params
    final a1 = (end.y - begin.y) / (end.x - begin.x);
    final b1 = -((begin.x * a1) - begin.y);

    // Intersection point of segment with perpendicular line from segment to
    // circle center
    double x;
    double y;

    if (a1 == 0.0) {
      // Segment is an horizontal line so perpendicular line will be vertical
      x = circle.center.x;
      y = begin.y;
    } else {
      // Perpendicular line from segment to circle center formula params
      final a2 = a1 != 0.0 ? -1.0 / a1 : 1.0;
      final b2 = -((circle.center.x * a2) - circle.center.y);

      x = (b2 - b1) / (a1 - a2);
      y = (a1 * x) + b1;
    }

    if (!_isLinePointInsideSegment(Point(x, y))) return false;

    // Distance from intersection point to circle center
    final dx = circle.center.x - x;
    final dy = circle.center.y - y;
    final distance = sqrt(dx * dx + dy * dy);

    return distance <= circle.radius;
  }

  /*bool intersects(Segment other) {
    if (!rectangle.intersects(other.rectangle)) return false;

    Point<double> intersectionPoint = _calcIntersectionPoint(other);

    return rectangle.containsPoint(intersectionPoint) &&
        other.rectangle.containsPoint(intersectionPoint);
  }*/

  /*Point<double> _calcIntersectionPoint(Segment other) {
    final a1 = (end.y - begin.y) / (end.x - begin.x);
    final b1 = -((begin.x * a1) - begin.y);

    final a2 = (other.end.y - other.begin.y) / (other.end.x - other.begin.x);
    final b2 = -((other.begin.x * a2) - other.begin.y);

    final x = (b2 - b1) / (a1 - a2);
    final y = (a1 * x) + b2;

    return Point(x, y);
  }*/

  bool _isLinePointInsideSegment(Point point) {
    return Rectangle.fromPoints(begin, end).containsPoint(point);
  }
}

/*class BoundingBox {
  final Segment top;
  final Segment left;
  final Segment right;
  final Segment bottom;

  BoundingBox(this.top, this.left, this.right, this.bottom);
}*/
