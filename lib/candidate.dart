import 'package:hive/hive.dart';

part 'candidate.g.dart';

@HiveType(typeId: 1)
class Candidate {
  @HiveField(0)
  String name;
  @HiveField(1)
  String description;
  @HiveField(2)
  String party;
  @HiveField(3)
  String photoUrl;
  @HiveField(4)
  String ballotopediaUrl;
  @HiveField(5)
  String candidateUrl;
  @HiveField(6)
  String facebookUrl;
  @HiveField(7)
  String twitterUrl;

  Candidate(
      this.name,
      this.description,
      this.party,
      this.photoUrl,
      this.ballotopediaUrl,
      this.candidateUrl,
      this.facebookUrl,
      this.twitterUrl);
}
