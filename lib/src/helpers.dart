import 'package:eva_sdk/src/dto/eva_error.dart';
import 'package:eva_sdk/src/enum/eva_error_kind.dart';

void noRpcMethod(String? name) {
  throw EvaError(EvaErrorKind.methodNotFound, "method $name not found");
}
