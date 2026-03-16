import 'package:flutter/material.dart';
import '../../features/shared/data/models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = user.firstName.isNotEmpty
        ? user.firstName[0].toUpperCase()
        : '?';
    final hue = (user.id * 137.5) % 360;
    final avatarColor = HSLColor.fromAHSL(1.0, hue, 0.6, 0.45).toColor();

    return CircleAvatar(
      radius: radius,
      backgroundColor: avatarColor,
      backgroundImage: user.image.isNotEmpty
          ? NetworkImage(user.image)
          : null,
      onBackgroundImageError: user.image.isNotEmpty
          ? (_, __) {}
          : null,
      child: user.image.isEmpty
          ? Text(
        initial,
        style: TextStyle(
          color: colorScheme.onSecondary,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      )
          : null,
    );
  }
}