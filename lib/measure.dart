import 'package:hive/hive.dart';

part 'measure.g.dart';

@HiveType(typeId: 3)
class Measure extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int id;

  @HiveField(2)
  int googleCivicId;

  @HiveField(3)
  String measureText;

  @HiveField(4)
  String noVoteDescription;

  @HiveField(5)
  String yesVoteDescription;

  @HiveField(6)
  String url;

  @HiveField(7)
  bool isYes;

  Measure(this.name, this.id, this.googleCivicId, this.measureText,
      this.noVoteDescription, this.yesVoteDescription, this.url, this.isYes);
}
