// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreditCardAdapter extends TypeAdapter<CreditCard> {
  @override
  final int typeId = 6;

  @override
  CreditCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreditCard(
      id: fields[0] as String,
      accountId: fields[1] as String,
      cardName: fields[2] as String,
      lastFourDigits: fields[3] as String,
      bankName: fields[4] as String,
      creditLimit: fields[5] as double,
      currentBalance: fields[6] as double,
      interestRate: fields[7] as double,
      dueDay: fields[8] as int,
      statementGenerationDay: fields[9] as int,
      gracePeriodDays: fields[10] as int,
      minimumPaymentPercentage: fields[11] as double,
      minimumPaymentFixedAmount: fields[12] as double?,
      minimumPayment: fields[13] as double,
      createdAt: fields[14] as DateTime,
      lastPaymentDate: fields[15] as DateTime?,
      isActive: fields[16] as bool,
      notes: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CreditCard obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.accountId)
      ..writeByte(2)
      ..write(obj.cardName)
      ..writeByte(3)
      ..write(obj.lastFourDigits)
      ..writeByte(4)
      ..write(obj.bankName)
      ..writeByte(5)
      ..write(obj.creditLimit)
      ..writeByte(6)
      ..write(obj.currentBalance)
      ..writeByte(7)
      ..write(obj.interestRate)
      ..writeByte(8)
      ..write(obj.dueDay)
      ..writeByte(9)
      ..write(obj.statementGenerationDay)
      ..writeByte(10)
      ..write(obj.gracePeriodDays)
      ..writeByte(11)
      ..write(obj.minimumPaymentPercentage)
      ..writeByte(12)
      ..write(obj.minimumPaymentFixedAmount)
      ..writeByte(13)
      ..write(obj.minimumPayment)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.lastPaymentDate)
      ..writeByte(16)
      ..write(obj.isActive)
      ..writeByte(17)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
