import 'package:json_annotation/json_annotation.dart';

part 'commitVoteRes.g.dart';

@JsonSerializable()
class CommitVoteRes {
  CommitVoteRes();

  @JsonKey(name: 'comment_id')
  int commentId;
  @JsonKey(name: 'comment_score')
  int commentScore;
  @JsonKey(name: 'comment_vote')
  int commentVote;

  factory CommitVoteRes.fromJson(Map<String, dynamic> json) =>
      _$CommitVoteResFromJson(json);
  Map<String, dynamic> toJson() => _$CommitVoteResToJson(this);
}
