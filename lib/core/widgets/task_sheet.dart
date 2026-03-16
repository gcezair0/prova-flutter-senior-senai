import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/tasks/bloc/task_bloc.dart';
import '../../features/tasks/bloc/task_event.dart';
import '../../features/tasks/data/models/task_model.dart';

class TaskSheet extends StatefulWidget {
  final int userId;
  final TaskModel? task;

  const TaskSheet({
    super.key,
    required this.userId,
    this.task,
  });

  static void showCreate(BuildContext context, {required int userId}) {
    _show(context, userId: userId, task: null);
  }

  static void showEdit(BuildContext context, {required TaskModel task}) {
    _show(context, userId: task.userId, task: task);
  }

  static void _show(
      BuildContext context, {
        required int userId,
        TaskModel? task,
      }) {

    final taskBloc = context.read<TaskBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: taskBloc,
        child: TaskSheet(userId: userId, task: task),
      ),
    );
  }

  @override
  State<TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<TaskSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  bool _hasText = false;
  bool _hasChanges = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task?.todo ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );

    _nameController.addListener(_onChange);
    _descController.addListener(_onChange);

    _hasText = _nameController.text.trim().isNotEmpty;
  }

  void _onChange() {
    final name = _nameController.text.trim();
    setState(() {
      _hasText = name.isNotEmpty;
      _hasChanges = name != (widget.task?.todo ?? '') ||
          _descController.text.trim() != (widget.task?.description ?? '');
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final description = _descController.text.trim();
    if (name.isEmpty) return;

    if (_isEditing) {
      context.read<TaskBloc>().add(
        TaskUpdateRequested(
          id: widget.task!.id,
          localId: widget.task!.localId,
          todo: name,
          description: description
        ),
      );
    } else {
      context.read<TaskBloc>().add(
        TaskCreateRequested(todo: name, description: description,userId: widget.userId),
      );
    }

    Navigator.pop(context);
  }

  void _delete() {
    final taskBloc = context.read<TaskBloc>();
    final localId = widget.task!.localId!;
    final dialogContext = context;

    Navigator.pop(context);

    showDialog(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: const Text(
          'A tarefa desaparecerá e não poderá ser recuperada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              taskBloc.add(TaskDeleteRequested(localId));
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canSubmit = _isEditing ? _hasChanges : _hasText;

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

          Text(
            _isEditing ? 'Editar tarefa' : 'Nova tarefa',
            style: theme.textTheme.headlineMedium,
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Nome da tarefa',
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline, width: 1),
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
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
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
                borderSide: BorderSide(color: colorScheme.outline, width: 1),
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
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              if (_isEditing)
                TextButton.icon(
                  onPressed: _delete,
                  icon: Icon(Icons.delete_outline, size: 18, color: colorScheme.error),
                  label: Text('Excluir', style: TextStyle(color: colorScheme.error)),
                ),

              const Spacer(),

              ElevatedButton(
                onPressed: canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  disabledBackgroundColor:
                  colorScheme.onSurface.withValues(alpha: 0.12),
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isEditing ? 'Salvar' : 'Criar tarefa',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: canSubmit
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}