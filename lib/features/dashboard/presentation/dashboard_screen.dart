import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/data/models/user_model.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardScreen extends StatelessWidget {
  final UserModel user;

  const DashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    void _showNewTaskSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => BlocProvider.value(
          value: context.read<DashboardBloc>(),
          child: _NewTaskSheet(userId: user.id),
        ),
      );
    }

    return Scaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(DashboardRefreshed(user));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, ${user.firstName}!',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 16),
                    _QuoteCard(state: state),
                    const SizedBox(height: 24),
                    Text(
                      'Suas tarefas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TasksSummaryCard(state: state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewTaskSheet(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}


class _QuoteCard extends StatelessWidget {
  final DashboardState state;

  const _QuoteCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.isLoadingQuote) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 14,
            width: 200,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 12,
              width: 100,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      );
    }

    if (state.quote == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '" ${state.quote!.quote}"',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '- ${state.quote!.author}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TasksSummaryCard extends StatelessWidget {
  final DashboardState state;

  const _TasksSummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.status == DashboardStatus.loading) {
      return _SummarySkeleton();
    }

    const completedColor = Color(0xFF4CAF50);
    const pendingColor = Color(0xFFE0D7F5);

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 25,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    valueColor: const AlwaysStoppedAnimation(pendingColor),
                  ),
                ),
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: state.total > 0 ? state.completed / state.total : 0,
                    strokeWidth: 25,
                    strokeCap: StrokeCap.round,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    valueColor: const AlwaysStoppedAnimation(completedColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.total}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 28),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(
                color: completedColor,
                label: 'Concluídas: ${state.completed}',
              ),
              const SizedBox(height: 12),
              _LegendItem(
                color: Theme.of(context).colorScheme.onPrimary,
                label: 'Pendentes: ${state.pending}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
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
    _nameController.addListener(() {
      setState(() => _hasText = _nameController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_hasText) return;
    final todo = _nameController.text.trim();
    final description = _descController.text.trim();
    Navigator.pop(context);

    context.read<DashboardBloc>().add(
      DashboardTaskCreateRequested(
        todo: todo,
        description: description,
        userId: widget.userId,
      ),
    );
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
                borderSide: BorderSide.none,
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
                borderSide: BorderSide.none,
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
                disabledBackgroundColor: colorScheme.onSurface.withValues(
                  alpha: 0.12,
                ),
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
