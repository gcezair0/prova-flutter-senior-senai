import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/converters/user_converter.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String gender,
    required String image,
    @Default('moderator') String role,
    String? phone,
    @CompanyNameConverter() String? company,
    @CompanyDepartmentConverter() String? department,
    String? accessToken,
    String? refreshToken,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}