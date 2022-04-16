enum Status { none, progress, success, failure }

extension StatusExtension on Status {
  bool get isNone => this == Status.none;

  bool get inProgress => this == Status.progress;

  bool get isSuccess => this == Status.success;

  bool get isFailure => this == Status.failure;

}
