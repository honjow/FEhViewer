// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commitVoteRes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommitVoteRes _$CommitVoteResFromJson(Map<String, dynamic> json) {
  return CommitVoteRes()
    ..commentId = json['comment_id'] as int
    ..commentScore = json['comment_score'] as int
    ..commentVote = json['comment_vote'] as int;
}

Map<String, dynamic> _$CommitVoteResToJson(CommitVoteRes instance) =>
    <String, dynamic>{
      'comment_id': instance.commentId,
      'comment_score': instance.commentScore,
      'comment_vote': instance.commentVote,
    };
