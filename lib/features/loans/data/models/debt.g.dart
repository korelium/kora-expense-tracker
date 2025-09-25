// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtAdapter extends TypeAdapter<Debt> {
  @override
  final int typeId = 20;

  @override
  Debt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Debt(
      id: fields[0] as String,
      personName: fields[1] as String,
      amount: fields[2] as double,
      paidAmount: fields[3] as double,
      date: fields[4] as DateTime,
      description: fields[5] as String?,
      isYouOwe: fields[6] as bool,
      linkedAccountId: fields[7] as String?,
      isPaidOff: fields[8] as bool,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Debt obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.paidAmount)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.isYouOwe)
      ..writeByte(7)
      ..write(obj.linkedAccountId)
      ..writeByte(8)
      ..write(obj.isPaidOff)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DebtPaymentAdapter extends TypeAdapter<DebtPayment> {
  @override
  final int typeId = 21;

  @override
  DebtPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DebtPayment(
      id: fields[0] as String,
      debtId: fields[1] as String,
      amount: fields[2] as double,
      paymentDate: fields[3] as DateTime,
      description: fields[4] as String?,
      linkedAccountId: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      proofImages: (fields[7] as List).cast<String>(),
      transactionType: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DebtPayment obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.debtId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.paymentDate)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.linkedAccountId)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.proofImages)
      ..writeByte(8)
      ..write(obj.transactionType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
