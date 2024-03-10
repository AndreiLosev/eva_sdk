import 'package:eva_sdk/src/const_and_dto.dart';
import 'package:eva_sdk/src/enums.dart';

void noRpcMethod(String? name) {
  throw EvaError(EvaErrorKind.methodNotFound, "method $name not found");
}
