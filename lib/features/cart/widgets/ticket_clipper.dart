import 'package:flutter/material.dart';

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    // Left Cutout
    double radius = 10;
    path.addOval(Rect.fromCircle(center: Offset(0, size.height / 2), radius: radius));
    
    // Right Cutout
    path.addOval(Rect.fromCircle(center: Offset(size.width, size.height / 2), radius: radius));

    return Path.combine(PathOperation.difference, path, Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)))..addPath(path, Offset.zero);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CouponTicketPainter extends CustomPainter {
  final Color color;
  const CouponTicketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double radius = 10;
    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, (size.height / 2) - radius)
      ..arcToPoint(Offset(0, (size.height / 2) + radius), radius: Radius.circular(radius), clockwise: true)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, (size.height / 2) + radius)
      ..arcToPoint(Offset(size.width, (size.height / 2) - radius), radius: Radius.circular(radius), clockwise: true)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
