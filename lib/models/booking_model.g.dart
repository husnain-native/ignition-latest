// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookingRequestAdapter extends TypeAdapter<BookingRequest> {
  @override
  final int typeId = 1;

  @override
  BookingRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookingRequest(
      id: fields[0] as String,
      userId: fields[1] as String,
      userName: fields[2] as String,
      email: fields[3] as String,
      phone: fields[4] as String,
      branch: fields[5] as String,
      date: fields[6] as String,
      timeSlot: fields[7] as String,
      status: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, BookingRequest obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.branch)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.timeSlot)
      ..writeByte(8)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
