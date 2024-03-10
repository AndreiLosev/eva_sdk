import 'package:eva_sdk/src/enum/eva_error_kind.dart';

class EvaError {
  final EvaErrorKind code;
  final String? message;

  EvaError(this.code, this.message);

  @override
  String toString() => "$code: $message";
}
