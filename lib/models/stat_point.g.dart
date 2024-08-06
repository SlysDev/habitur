// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stat_point.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StatPointAdapter extends TypeAdapter<StatPoint> {
  @override
  final int typeId = 1;

  @override
  StatPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatPoint(
      date: fields[0] as DateTime,
      completions: fields[1] as int,
      confidenceLevel: fields[3] as double,
      streak: fields[4] as int,
      consistencyFactor: fields[2] as double,
      difficultyRating: fields[5] as double,
      slopeCompletions: fields[6] as double,
      slopeConfidenceLevel: fields[7] as double,
      slopeConsistency: fields[8] as double,
      slopeDifficultyRating: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, StatPoint obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.completions)
      ..writeByte(2)
      ..write(obj.consistencyFactor)
      ..writeByte(3)
      ..write(obj.confidenceLevel)
      ..writeByte(4)
      ..write(obj.streak)
      ..writeByte(5)
      ..write(obj.difficultyRating)
      ..writeByte(6)
      ..write(obj.slopeCompletions)
      ..writeByte(7)
      ..write(obj.slopeConfidenceLevel)
      ..writeByte(8)
      ..write(obj.slopeConsistency)
      ..writeByte(9)
      ..write(obj.slopeDifficultyRating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatPointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
