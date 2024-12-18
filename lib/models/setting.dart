import 'package:hive/hive.dart';

part 'setting.g.dart';

@HiveType(typeId: 2)
class SettingModel {
  @HiveField(0)
  String settingName;
  @HiveField(1)
  String settingDescription;
  @HiveField(2)
  dynamic settingValue;
  SettingModel({
    required this.settingValue,
    required this.settingName,
    this.settingDescription = '',
  });
  factory SettingModel.fromMap(Map<String, dynamic> map) {
    return SettingModel(
      settingValue: map['settingValue'] ?? '',
      settingName: map['settingName'] ?? '',
      settingDescription: map['settingDescription'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'settingValue': settingValue,
      'settingName': settingName,
      'settingDescription': settingDescription,
    };
  }
}
