// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simpleTag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SimpleTag _$SimpleTagFromJson(Map<String, dynamic> json) {
  return SimpleTag()
    ..text = json['text'] as String
    ..translat = json['Translat'] as String
    ..color = json['color'] as String
    ..backgrondColor = json['backgrondColor'] as String;
}

Map<String, dynamic> _$SimpleTagToJson(SimpleTag instance) => <String, dynamic>{
      'text': instance.text,
      'Translat': instance.translat,
      'color': instance.color,
      'backgrondColor': instance.backgrondColor,
    };
