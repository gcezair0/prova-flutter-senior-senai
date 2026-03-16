import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../shared/data/models/user_model.dart';
import '../bloc/loading_bloc.dart';
import '../bloc/loading_event.dart';
import '../bloc/loading_state.dart';
import '../../../core/widgets/app_snack_bar.dart';

class LoadingScreen extends StatefulWidget {
  final UserModel user;

  const LoadingScreen({super.key, required this.user});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    context.read<LoadingBloc>().add(LoadingStarted(widget.user));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<LoadingBloc, LoadingState>(
      listener: (context, state) {
        switch (state.status) {
          case LoadingStatus.success:
            context.go('/dashboard', extra: widget.user);
          case LoadingStatus.failure:
            AppSnackBar.showError(
              context,
              message: state.errorMessage ??
                  'Erro ao carregar dados. Tente novamente.',
            );
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) context.go('/login');
            });
          case LoadingStatus.loading:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo.png', height: 80),

              const SizedBox(height: 32),
              _DotsLoader(controller: _controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotsLoader extends StatelessWidget {
  final AnimationController controller;

  const _DotsLoader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const dotCount = 8;
    const radius = 18.0;
    const dotSize = 5.0;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SizedBox(
          width: (radius * 2) + dotSize * 2,
          height: (radius * 2) + dotSize * 2,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(dotCount, (index) {
              final angle = (2 * pi / dotCount) * index;
              final dx = radius * cos(angle);
              final dy = radius * sin(angle);

              final progress = controller.value;
              final dotProgress = (progress - index / dotCount) % 1.0;
              final opacity = dotProgress < 0.5
                  ? dotProgress * 2
                  : (1.0 - dotProgress) * 2;

              return Transform.translate(
                offset: Offset(dx, dy),
                child: Opacity(
                  opacity: opacity.clamp(0.2, 1.0),
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}