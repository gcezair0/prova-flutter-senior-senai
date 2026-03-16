import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/splash_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animacaoSlide;
  late Animation<double> _animacaoRotacao;
  late Animation<double> _animacaoEscala;
  late Animation<double> _animacaoRadius;
  late Animation<double> _animacaoExpansao;

  bool _isIniciado = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isIniciado) {
      _isIniciado = true;
      Future.wait([
        _controller.forward(),
        context.read<SplashCubit>().checkAuth(),
      ]);
    }
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _animacaoSlide = Tween<Offset>(
      begin: const Offset(0, 3.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
    ));

    _animacaoRotacao = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.125)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.125, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 1.0),
    ));
    _animacaoEscala = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.75)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.75, end: 0.12)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.12, end: 40.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_controller);

    _animacaoRadius = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(16.0),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 16.0, end: 200.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(200.0),
        weight: 25,
      ),
    ]).animate(_controller);

    _animacaoExpansao = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.90, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<SplashCubit, SplashStatus>(
      listener: (context, status) {
        if (!_controller.isAnimating) {
          _navigate(status);
        } else {
          _controller.addStatusListener((animStatus) {
            if (animStatus == AnimationStatus.completed) {
              _navigate(status);
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                if (_controller.value >= 0.90)
                  Opacity(
                    opacity: _animacaoExpansao.value,
                    child: Container(
                      color: colorScheme.primary,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

                Center(
                  child: SlideTransition(
                    position: _animacaoSlide,
                    child: Transform.rotate(
                      angle: _animacaoRotacao.value * 2 * 3.14159,
                      child: Transform.scale(
                        scale: _animacaoEscala.value.clamp(0.0, 50.0),
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(
                              _animacaoRadius.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _navigate(SplashStatus status) {
    if (!mounted) return;
    switch (status) {
      case SplashStatus.authenticated:
        final user = context.read<SplashCubit>().currentUser;
        if (user == null) return;
        context.go('/loading', extra: user);
      case SplashStatus.unauthenticated:
        context.go('/login');
      case SplashStatus.loading:
        break;
    }
  }
}