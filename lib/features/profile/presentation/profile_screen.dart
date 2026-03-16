import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_cubit.dart';
import '../../../core/di/injection.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/data/domain/auth_repository.dart';
import '../../shared/data/models/user_model.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(
        authRepository: getIt<AuthRepository>(),
        localDataSource: getIt(),
      )..add(ProfileLoadRequested()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.failure) {
            AppSnackBar.showError(
              context,
              message: state.errorMessage ??
                  'Não foi possível carregar as informações',
              onRetry: () =>
                  context.read<ProfileBloc>().add(ProfileRetryRequested()),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: switch (state.status) {
              ProfileStatus.loading || ProfileStatus.initial =>
              const _ProfileSkeleton(),
              ProfileStatus.failure =>
              const _ProfileSkeleton(),
              ProfileStatus.success => _ProfileContent(user: state.user!),
            },
          );
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserModel user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  final isDark = themeMode == ThemeMode.dark ||
                      (themeMode == ThemeMode.system &&
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark);

                  return GestureDetector(
                    onTap: () => getIt<ThemeCubit>().toggleTheme(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: !isDark
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.wb_sunny_outlined,
                              size: 20,
                              color: !isDark
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.dark_mode_outlined,
                              size: 20,
                              color: isDark
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              TextButton.icon(
                onPressed: () => _logout(context),
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    colorScheme.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset('assets/icons/logout.png', height: 19, width: 19),
                ),
                label: const Text('Sair'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          UserAvatar(user: user, radius: 44),

          const SizedBox(height: 12),

          Text(
            user.firstName,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            user.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  user.role == 'admin' ? 'Admin' : 'Moderador',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Divider(color: colorScheme.outlineVariant),
          _InfoItem(
            label: 'Nome completo',
            value: '${user.firstName} ${user.lastName}',
          ),
          SizedBox(height: 2),
          _InfoItem(
            label: 'E-mail',
            value: user.email,
          ),
          if (user.phone != null) ...[
            SizedBox(height: 2),
            _InfoItem(
              label: 'Telefone',
              value: user.phone!,
            ),
          ],
          if (user.company != null) ...[
            SizedBox(height: 2),
            _InfoItem(
              label: 'Empresa',
              value: user.company!,
            ),
          ],
          if (user.department != null) ...[
            SizedBox(height: 2),
            _InfoItem(
              label: 'Departamento',
              value: user.department!,
            ),
          ],
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    await getIt<AuthRepository>().logout();
    if (context.mounted) context.go('/login');
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatefulWidget {
  const _ProfileSkeleton();

  @override
  State<_ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends State<_ProfileSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Opacity(
          opacity: _animation.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _SkeletonBox(width: 120, height: 24, color: color),
                const SizedBox(height: 24),
                CircleAvatar(radius: 48, backgroundColor: color),
                const SizedBox(height: 12),
                _SkeletonBox(width: 160, height: 20, color: color),
                const SizedBox(height: 8),
                _SkeletonBox(width: 200, height: 14, color: color),
                const SizedBox(height: 8),
                _SkeletonBox(width: 80, height: 24, color: color, radius: 32),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: List.generate(5, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          _SkeletonBox(width: 20, height: 20, color: color, radius: 4),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SkeletonBox(width: 80, height: 10, color: color),
                                const SizedBox(height: 6),
                                _SkeletonBox(width: double.infinity, height: 14, color: color),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}