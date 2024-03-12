import 'dart:async';
import 'dart:typed_data';

import 'package:busrt_client/busrt_client.dart';

class ServiceMethodParam {
  final String name;
  final String type;
  final String description;
  final bool required;

  ServiceMethodParam(this.name, this.type, this.required,
      [this.description = '']);

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'description': description,
        'required': required,
      };
}

class ServiceMethod {
  final String name;
  final String description;
  final FutureOr<Uint8List?> Function(Map<String, dynamic>) fn;
  final List<ServiceMethodParam> params = [];

  ServiceMethod(this.name, this.fn, [this.description = ""]);

  void required(String name, String type, [String description = ""]) =>
      params.add(ServiceMethodParam(name, type, true, description));

  void optional(String name, String type, [String description = ""]) =>
      params.add(ServiceMethodParam(name, type, false, description));

  Iterable<String> getRequared() =>
      params.where((e) => e.required).map((e) => e.name);

  Iterable<String> getOptional() =>
      params.where((e) => !e.required).map((e) => e.name);

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'params': params.map((e) => e.toMap()),
      };
}

class ServiceInfo {
  final String author;
  final String description;
  final String version;
  final methods = <ServiceMethod>[];

  ServiceInfo(this.author, this.version, [this.description = ""]);

  void addMethod(ServiceMethod method) {
    methods.add(method);
  }

  Map<String, dynamic> toMap() => {
        'author': author,
        'description': description,
        'version': version,
        'methods': methods.map((e) => e.toMap()),
      };
}
