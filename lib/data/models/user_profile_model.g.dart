// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 0;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel(
      id: fields[0] as String,
      fullName: fields[1] as String,
      age: fields[2] as int,
      email: fields[3] as String,
      phone: fields[4] as String,
      occupation: fields[5] as String,
      location: fields[6] as String,
      aboutMe: fields[7] as String,
      photoUrl: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.occupation)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.aboutMe)
      ..writeByte(8)
      ..write(obj.photoUrl);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
