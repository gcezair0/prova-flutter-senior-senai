import 'package:json_annotation/json_annotation.dart';

class CompanyNameConverter implements JsonConverter<String?, dynamic> {
  const CompanyNameConverter();

  @override
  String? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return json;
    if (json is Map<String, dynamic>) return json['name'] as String?;
    return null;
  }

  @override
  dynamic toJson(String? value) => value;
}

class CompanyDepartmentConverter implements JsonConverter<String?, dynamic> {
  const CompanyDepartmentConverter();

  @override
  String? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return json;
    if (json is Map<String, dynamic>) return json['department'] as String?;
    return null;
  }

  @override
  dynamic toJson(String? value) => value;
}