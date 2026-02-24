// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zikr_phrase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZikrPhraseAdapter extends TypeAdapter<ZikrPhrase> {
  @override
  final int typeId = 0;

  @override
  ZikrPhrase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZikrPhrase(
      id: fields[0] as String,
      arabicText: fields[1] as String,
      transliteration: fields[2] as String,
      totalCount: fields[3] as int,
      sessionCount: fields[4] as int,
      isActive: fields[5] as bool,
      isDefault: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      lastUpdatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ZikrPhrase obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.arabicText)
      ..writeByte(2)
      ..write(obj.transliteration)
      ..writeByte(3)
      ..write(obj.totalCount)
      ..writeByte(4)
      ..write(obj.sessionCount)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.isDefault)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.lastUpdatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZikrPhraseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
