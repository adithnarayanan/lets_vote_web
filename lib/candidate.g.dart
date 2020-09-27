// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CandidateAdapter extends TypeAdapter<Candidate> {
  @override
  final typeId = 1;

  @override
  Candidate read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Candidate(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      fields[5] as String,
      fields[6] as String,
      fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Candidate obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.party)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.ballotopediaUrl)
      ..writeByte(5)
      ..write(obj.candidateUrl)
      ..writeByte(6)
      ..write(obj.facebookUrl)
      ..writeByte(7)
      ..write(obj.twitterUrl);
  }
}
