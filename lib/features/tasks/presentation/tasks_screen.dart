import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../shared/data/models/user_model.dart';
import '../../../core/widgets/task_sheet.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../data/models/task_model.dart';

class TasksScreen extends StatefulWidget {
  final UserModel user;

  const TasksScreen({super.key, required this.user});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(TasksLoadRequested(widget.user.id));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<TaskBloc>().state;

    if (state.hasReachedMax) return;
    if (state.status == TaskStatus.loadingMore) return;
    if (state.status == TaskStatus.loading) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      context.read<TaskBloc>().add(TasksLoadMoreRequested(widget.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<TaskBloc, TaskState>(
          listenWhen: (prev, curr) => curr.errorMessage != null,
          buildWhen: (prev, curr) =>
          prev.tasks != curr.tasks ||
              prev.status != curr.status ||
              prev.filter != curr.filter ||
              prev.sort != curr.sort ||
              prev.ascending != curr.ascending ||
              prev.searchQuery != curr.searchQuery,
          listener: (context, state) {
            if (state.errorMessage != null) {
              AppSnackBar.showError(
                context,
                message: state.errorMessage!,
                onRetry: () => context.read<TaskBloc>().add(
                  TasksLoadRequested(widget.user.id),
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Text(
                    'Tarefas',
                    style: theme.textTheme.headlineLarge,
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => context
                        .read<TaskBloc>()
                        .add(TaskSearchChanged(v)),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar tarefas',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<TaskBloc>()
                              .add(TaskSearchChanged(''));
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

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _SortDropdown(state: state),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: state.status == TaskStatus.loading
                      ? const _TasksSkeleton()
                      : _TaskList(
                    state: state,
                    scrollController: _scrollController,
                    userId: widget.user.id,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => TaskSheet.showCreate(context, userId: widget.user.id),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final TaskState state;

  const _FilterChips({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(
          label: 'Todas',
          selected: state.filter == TaskFilter.all,
          onTap: () => context
              .read<TaskBloc>()
              .add(TaskFilterChanged(TaskFilter.all)),
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'Pendentes',
          selected: state.filter == TaskFilter.pending,
          onTap: () => context
              .read<TaskBloc>()
              .add(TaskFilterChanged(TaskFilter.pending)),
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'Concluídas',
          selected: state.filter == TaskFilter.completed,
          onTap: () => context
              .read<TaskBloc>()
              .add(TaskFilterChanged(TaskFilter.completed)),
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

class _SortDropdown extends StatelessWidget {
  final TaskState state;

  const _SortDropdown({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          'Ordenar por',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'asc' || value == 'desc') {
              context.read<TaskBloc>().add(TaskSortOrderToggled());
            } else {
              final sort = switch (value) {
                'name' => TaskSort.name,
                'status' => TaskSort.status,
                'completedAt' => TaskSort.completedAt,
                _ => TaskSort.defaultOrder,
              };
              context.read<TaskBloc>().add(TaskSortChanged(sort));
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'default', child: Text('Padrão')),
            const PopupMenuItem(value: 'name', child: Text('Nome')),
            const PopupMenuItem(value: 'status', child: Text('Status')),
            const PopupMenuItem(value: 'completedAt', child: Text('Data de conclusão')),
            const PopupMenuDivider(),
            const PopupMenuItem(
                value: 'desc', child: Text('Ordem crescente')),
            const PopupMenuItem(
                value: 'asc', child: Text('Ordem decrescente')),
          ],
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  switch (state.sort) {
                    TaskSort.name => 'Nome',
                    TaskSort.status => 'Status',
                    TaskSort.completedAt => 'Conclusão',
                    TaskSort.defaultOrder => 'Padrão',
                  },
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskList extends StatelessWidget {
  final TaskState state;
  final ScrollController scrollController;
  final int userId;

  const _TaskList({
    required this.state,
    required this.scrollController,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final pending = state.pendingTasks;
    final completed = state.completedTasks;

    if (state.displayTasks.isEmpty) {
      return const Center(child: Text('Nenhuma tarefa encontrada'));
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        if (pending.isNotEmpty) ...[
          _SectionHeader(label: 'Pendentes'),
          ...pending.map((t) => _TaskItem(task: t)),
        ],
        if (completed.isNotEmpty) ...[
          _SectionHeader(label: 'Concluídas'),
          ...completed.map((t) => _TaskItem(task: t)),
        ],

        if (state.status == TaskStatus.loadingMore)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),

        if (state.showReachedMax && state.displayTasks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Todas as tarefas carregadas',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
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

class _TaskItem extends StatelessWidget {
  final TaskModel task;

  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => TaskSheet.showEdit(context, task: task),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        leading: GestureDetector(
          onTap: () => context
              .read<TaskBloc>()
              .add(TaskToggleCompleted(task)),
          child: Container(
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

class _NewTaskSheet extends StatefulWidget {
  final int userId;

  const _NewTaskSheet({required this.userId});

  @override
  State<_NewTaskSheet> createState() => _NewTaskSheetState();
}

class _NewTaskSheetState extends State<_NewTaskSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(
          () => setState(() => _hasText = _nameController.text.trim().isNotEmpty),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_hasText) return;
    context.read<TaskBloc>().add(
      TaskCreateRequested(
        todo: _nameController.text.trim(),
        description: _descController.text.trim(),
        userId: widget.userId,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text('Nova tarefa', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Nome da tarefa',
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.surface.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _descController,
            decoration: InputDecoration(
              hintText: 'Descrição',
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 1.5,
                ),
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _hasText ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                disabledBackgroundColor:
                colorScheme.onSurface.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                elevation: 0,
              ),
              child: Text(
                'Criar tarefa',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _hasText
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TasksSkeleton extends StatelessWidget {
  const _TasksSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 6,
      itemBuilder: (context, index) => const _TaskItemSkeleton(),
    );
  }
}

class _TaskItemSkeleton extends StatefulWidget {
  const _TaskItemSkeleton();

  @override
  State<_TaskItemSkeleton> createState() => _TaskItemSkeletonState();
}

class _TaskItemSkeletonState extends State<_TaskItemSkeleton>
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
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 100,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
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