// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measure.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeasureAdapter extends TypeAdapter<Measure> {
  @override
  final typeId = 3;

  @override
  Measure read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Measure(
      fields[0] as String,
      fields[1] as int,
      fields[2] as int,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      fields[6] as String,
      fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Measure obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.googleCivicId)
      ..writeByte(3)
      ..write(obj.measureText)
      ..writeByte(4)
      ..write(obj.noVoteDescription)
      ..writeByte(5)
      ..write(obj.yesVoteDescription)
      ..writeByte(6)
      ..write(obj.url)
      ..writeByte(7)
      ..write(obj.isYes);
  }
}
