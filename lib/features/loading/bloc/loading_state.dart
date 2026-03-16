enum LoadingStatus { loading, success, failure }

class LoadingState {
  final LoadingStatus status;
  final String? errorMessage;

  const LoadingState({
    this.status = LoadingStatus.loading,
    this.errorMessage,
  });

  LoadingState copyWith({
    LoadingStatus? status,
    String? errorMessage,
  }) {
    return LoadingState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}