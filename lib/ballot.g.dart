// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ballot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BallotAdapter extends TypeAdapter<Ballot> {
  @override
  final typeId = 2;

  @override
  Ballot read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ballot(
      fields[0] as String,
      fields[1] as int,
      fields[2] as DateTime,
      fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Ballot obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.googleBallotId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.deadline);
  }
}
