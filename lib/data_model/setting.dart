import 'package:json_annotation/json_annotation.dart';

part 'setting.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

// Used for receipt list
class Setting {
  int id;
  String key;
  String value;

  Setting();

  factory Setting.fromJason(Map<String, dynamic> json) => _$SettingFromJson(json);
  Map<String, dynamic> toJson() => _$SettingToJson(this);
}
