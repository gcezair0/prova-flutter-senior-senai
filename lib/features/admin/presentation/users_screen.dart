import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/features/shared/data/models/user_model.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../../tasks/bloc/task_state.dart';
import '../../tasks/data/models/task_model.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';
import '../bloc/users_state.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(UsersLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<UsersBloc, UsersState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              AppSnackBar.showError(
                context,
                message: state.errorMessage!,
                onRetry: () =>
                    context.read<UsersBloc>().add(UsersLoadRequested()),
              );
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Text('Usuários', style: theme.textTheme.headlineLarge),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => context
                        .read<UsersBloc>()
                        .add(UsersSearchChanged(v)),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar usuários',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<UsersBloc>()
                              .add(UsersSearchChanged(''));
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _FilterChips(state: state),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: switch (state.status) {
                    UsersStatus.loading => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    UsersStatus.failure => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sem conexão',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Verifique sua internet e tente novamente.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.read<UsersBloc>().add(UsersLoadRequested()),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tentar novamente'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _ => _UserList(state: state),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final UsersState state;

  const _FilterChips({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(
          label: 'Todos',
          selected: state.filter == UsersFilter.all,
          onTap: () => context
              .read<UsersBloc>()
              .add(UsersFilterChanged(UsersFilter.all)),
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'Administradores',
          selected: state.filter == UsersFilter.admin,
          onTap: () => context
              .read<UsersBloc>()
              .add(UsersFilterChanged(UsersFilter.admin)),
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'Moderadores',
          selected: state.filter == UsersFilter.moderator,
          onTap: () => context
              .read<UsersBloc>()
              .add(UsersFilterChanged(UsersFilter.moderator)),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check, size: 14, color: colorScheme.onPrimary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final UsersState state;

  const _UserList({required this.state});

  @override
  Widget build(BuildContext context) {
    final admins = state.admins;
    final moderators = state.moderators;

    if (state.displayUsers.isEmpty) {
      return const Center(child: Text('Nenhum usuário encontrado'));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        if (admins.isNotEmpty && state.filter != UsersFilter.moderator) ...[
          _SectionHeader(label: 'Administradores'),
          ...admins.map((u) => _UserItem(user: u)),
        ],
        if (moderators.isNotEmpty && state.filter != UsersFilter.admin) ...[
          _SectionHeader(label: 'Moderadores'),
          ...moderators.map((u) => _UserItem(user: u)),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

Color _userColor(int userId) {
  final hue = (userId * 137.5) % 360;
  return HSLColor.fromAHSL(1.0, hue, 0.6, 0.45).toColor();
}

class _UserItem extends StatelessWidget {
  final UserModel user;

  const _UserItem({required this.user});


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = user.firstName.isNotEmpty
        ? user.firstName[0].toUpperCase()
        : '?';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      onTap: () => _showUserTasks(context, user),
      leading: UserAvatar(user: user),
      title: Text('${user.firstName} ${user.lastName}'),
      subtitle: Text(
        user.role == 'admin' ? 'Admin' : 'Moderador',
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showUserTasks(BuildContext context, UserModel user) {
    final taskBloc = context.read<TaskBloc>();
    taskBloc.add(TasksLoadRequested(user.id));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: taskBloc,
        child: _UserTasksSheet(user: user),
      ),
    );
  }
}

class _UserTasksSheet extends StatefulWidget {
  final UserModel user;

  const _UserTasksSheet({required this.user});

  @override
  State<_UserTasksSheet> createState() => _UserTasksSheetState();
}

class _UserTasksSheetState extends State<_UserTasksSheet> {
  TaskFilter _filter = TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  UserAvatar(user: widget.user, radius: 24),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.user.firstName} ${widget.user.lastName}',
                    style: theme.textTheme.headlineMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Todas',
                    selected: _filter == TaskFilter.all,
                    onTap: () => setState(() => _filter = TaskFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pendentes',
                    selected: _filter == TaskFilter.pending,
                    onTap: () => setState(() => _filter = TaskFilter.pending),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Concluídas',
                    selected: _filter == TaskFilter.completed,
                    onTap: () => setState(() => _filter = TaskFilter.completed),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state.status == TaskStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tasks = switch (_filter) {
                    TaskFilter.pending =>
                        state.displayTasks.where((t) => !t.completed).toList(),
                    TaskFilter.completed =>
                        state.displayTasks.where((t) => t.completed).toList(),
                    TaskFilter.all => state.displayTasks,
                  };

                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma tarefa encontrada'),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: tasks.length,
                    itemBuilder: (_, index) => _TaskItem(task: tasks[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check, size: 14, color: colorScheme.onPrimary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final TaskModel task;

  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor:
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        leading: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: task.completed
                ? const Color(0xFF4CAF50)
                : Colors.transparent,
            border: task.completed
                ? null
                : Border.all(
              color: colorScheme.onSurfaceVariant,
              width: 1.5,
            ),
          ),
          child: task.completed
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        title: Text(
          task.todo,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
