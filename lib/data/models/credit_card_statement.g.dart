// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_statement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreditCardStatementAdapter extends TypeAdapter<CreditCardStatement> {
  @override
  final int typeId = 10;

  @override
  CreditCardStatement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreditCardStatement(
      id: fields[0] as String,
      creditCardId: fields[1] as String,
      statementDate: fields[2] as DateTime,
      cycleStartDate: fields[3] as DateTime,
      cycleEndDate: fields[4] as DateTime,
      dueDate: fields[5] as DateTime,
      previousBalance: fields[6] as double,
      totalPurchases: fields[7] as double,
      totalPayments: fields[8] as double,
      totalFees: fields[9] as double,
      totalInterest: fields[10] as double,
      newBalance: fields[11] as double,
      minimumPayment: fields[12] as double,
      creditLimit: fields[13] as double,
      availableCredit: fields[14] as double,
      creditUtilization: fields[15] as double,
      transactionIds: (fields[16] as List).cast<String>(),
      status: fields[17] as StatementStatus,
      generatedAt: fields[18] as DateTime,
      paidAt: fields[19] as DateTime?,
      paymentAmount: fields[20] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, CreditCardStatement obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.creditCardId)
      ..writeByte(2)
      ..write(obj.statementDate)
      ..writeByte(3)
      ..write(obj.cycleStartDate)
      ..writeByte(4)
      ..write(obj.cycleEndDate)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.previousBalance)
      ..writeByte(7)
      ..write(obj.totalPurchases)
      ..writeByte(8)
      ..write(obj.totalPayments)
      ..writeByte(9)
      ..write(obj.totalFees)
      ..writeByte(10)
      ..write(obj.totalInterest)
      ..writeByte(11)
      ..write(obj.newBalance)
      ..writeByte(12)
      ..write(obj.minimumPayment)
      ..writeByte(13)
      ..write(obj.creditLimit)
      ..writeByte(14)
      ..write(obj.availableCredit)
      ..writeByte(15)
      ..write(obj.creditUtilization)
      ..writeByte(16)
      ..write(obj.transactionIds)
      ..writeByte(17)
      ..write(obj.status)
      ..writeByte(18)
      ..write(obj.generatedAt)
      ..writeByte(19)
      ..write(obj.paidAt)
      ..writeByte(20)
      ..write(obj.paymentAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditCardStatementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatementStatusAdapter extends TypeAdapter<StatementStatus> {
  @override
  final int typeId = 9;

  @override
  StatementStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StatementStatus.generated;
      case 1:
        return StatementStatus.paid;
      case 2:
        return StatementStatus.overdue;
      default:
        return StatementStatus.generated;
    }
  }

  @override
  void write(BinaryWriter writer, StatementStatus obj) {
    switch (obj) {
      case StatementStatus.generated:
        writer.writeByte(0);
        break;
      case StatementStatus.paid:
        writer.writeByte(1);
        break;
      case StatementStatus.overdue:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatementStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
