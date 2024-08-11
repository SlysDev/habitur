import 'package:hive/hive.dart';

part 'setting.g.dart';

@HiveType(typeId: 2)
class Setting {
  @HiveField(0)
  String settingName;
  @HiveField(1)
  String settingDescription;
  @HiveField(2)
  dynamic settingValue;
  Setting({
    required this.settingValue,
    required this.settingName,
    this.settingDescription = '',
  });
}
