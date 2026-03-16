

import '../../tasks/data/models/task_model.dart';
import '../data/models/quote_model.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState {
  final List<TaskModel> tasks;
  final DashboardStatus status;
  final String? errorMessage;
  final QuoteModel? quote;
  final bool isLoadingQuote;
  final String? quoteError;

  const DashboardState({
    this.tasks = const [],
    this.status = DashboardStatus.initial,
    this.errorMessage,
    this.quote,
    this.isLoadingQuote = false,
    this.quoteError,
  });

  int get total => tasks.length;
  int get completed => tasks.where((t) => t.completed).length;
  int get pending => tasks.where((t) => !t.completed).length;

  DashboardState copyWith({
    List<TaskModel>? tasks,
    DashboardStatus? status,
    String? errorMessage,
    QuoteModel? quote,
    bool? isLoadingQuote,
    String? quoteError,
  }) {
    return DashboardState(
      tasks: tasks ?? this.tasks,
      status: status ?? this.status,
      errorMessage: errorMessage,
      quote: quote ?? this.quote,
      isLoadingQuote: isLoadingQuote ?? this.isLoadingQuote,
      quoteError: quoteError,
    );
  }
}