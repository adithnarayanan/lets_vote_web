import 'package:hive/hive.dart';

import 'candidate.dart';

part 'election.g.dart';

@HiveType(typeId: 0)
class Election extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int id;

  @HiveField(2)
  int googleCivicId;

  @HiveField(3)
  String officeLevel;

  @HiveField(4)
  List<Candidate> candidates;

  @HiveField(5)
  int chosenIndex;

  Election(
    this.name,
    this.id,
    this.googleCivicId,
    this.officeLevel,
    this.candidates,
    this.chosenIndex,
  );
}
