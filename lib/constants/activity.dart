enum Activity { none, create, read, update, delete }

extension ActivityExtension on Activity {
  bool get isNone => this == Activity.none;

  bool get isUpdate => this == Activity.update;

  bool get isDelete => this == Activity.delete;

  bool get isCreate => this == Activity.create;
}
