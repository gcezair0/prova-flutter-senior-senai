import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_radar/features/tasks/bloc/task_bloc.dart';
import 'package:task_radar/features/tasks/bloc/task_event.dart';
import 'package:task_radar/features/tasks/bloc/task_state.dart';
import 'package:task_radar/features/tasks/data/models/task_model.dart';

import '../../mocks/mocks.dart';

final _fakeTasks = List.generate(
  25,
      (i) => TaskModel(
    id: i + 1,
    localId: i + 1,
    todo: 'Tarefa ${i + 1}',
    completed: i % 2 == 0,
    userId: 1,
    isSynced: true,
  ),
);

void main() {
  late MockTaskRepository taskRepository;

  setUp(() {
    taskRepository = MockTaskRepository();
  });

  group('TaskBloc', () {
    blocTest<TaskBloc, TaskState>(
      'emite [loading, success] com primeira página ao carregar tarefas',
      build: () {
        when(() => taskRepository.getTasksByUser(1, limit: 9999, skip: 0))
            .thenAnswer((_) async => _fakeTasks);
        return TaskBloc(taskRepository);
      },
      act: (bloc) => bloc.add(TasksLoadRequested(1)),
      expect: () => [
        isA<TaskState>().having(
              (s) => s.status,
          'status',
          TaskStatus.loading,
        ),
        isA<TaskState>()
            .having((s) => s.status, 'status', TaskStatus.success)
            .having((s) => s.tasks.length, 'tasks length', 20)
            .having((s) => s.hasReachedMax, 'hasReachedMax', false),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emite [loadingMore, success] com próxima página ao carregar mais',
      build: () {
        when(() => taskRepository.getTasksByUser(1, limit: 9999, skip: 0))
            .thenAnswer((_) async => _fakeTasks);
        return TaskBloc(taskRepository);
      },
      act: (bloc) async {
        bloc.add(TasksLoadRequested(1));
        await Future.delayed(const Duration(milliseconds: 200));
        bloc.add(TasksLoadMoreRequested(1));
        await Future.delayed(const Duration(milliseconds: 500));
      },
      expect: () => [
        isA<TaskState>().having((s) => s.status, 'status', TaskStatus.loading),
        isA<TaskState>()
            .having((s) => s.status, 'status', TaskStatus.success)
            .having((s) => s.tasks.length, 'tasks length', 20),
        isA<TaskState>().having((s) => s.status, 'status', TaskStatus.loadingMore),
        isA<TaskState>()
            .having((s) => s.status, 'status', TaskStatus.success)
            .having((s) => s.hasReachedMax, 'hasReachedMax', true),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'filtra tarefas pendentes corretamente',
      build: () => TaskBloc(taskRepository),
      seed: () => TaskState(
        tasks: _fakeTasks.take(20).toList(),
        status: TaskStatus.success,
      ),
      act: (bloc) => bloc.add(TaskFilterChanged(TaskFilter.pending)),
      expect: () => [
        isA<TaskState>().having(
              (s) => s.filter,
          'filter',
          TaskFilter.pending,
        ),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'busca tarefas por texto corretamente',
      build: () => TaskBloc(taskRepository),
      seed: () => TaskState(
        tasks: _fakeTasks.take(20).toList(),
        status: TaskStatus.success,
      ),
      act: (bloc) => bloc.add(TaskSearchChanged('Tarefa 1')),
      expect: () => [
        isA<TaskState>().having(
              (s) => s.searchQuery,
          'searchQuery',
          'Tarefa 1',
        ),
      ],
      verify: (bloc) {
        expect(
          bloc.state.displayTasks
              .every((t) => t.todo.contains('Tarefa 1')),
          true,
        );
      },
    );
  });
}