// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillAdapter extends TypeAdapter<Bill> {
  @override
  final int typeId = 11;

  @override
  Bill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bill(
      id: fields[0] as String,
      creditCardId: fields[1] as String,
      billDate: fields[2] as DateTime,
      dueDate: fields[3] as DateTime,
      statementPeriodStart: fields[4] as DateTime,
      statementPeriodEnd: fields[5] as DateTime,
      previousBalance: fields[6] as double,
      totalPayments: fields[7] as double,
      totalPurchases: fields[8] as double,
      totalInterest: fields[9] as double,
      totalFees: fields[10] as double,
      newBalance: fields[11] as double,
      minimumPayment: fields[12] as double,
      availableCredit: fields[13] as double,
      status: fields[14] as BillStatus,
      paymentDate: fields[15] as DateTime?,
      paymentAmount: fields[16] as double?,
      filePath: fields[17] as String?,
      notes: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Bill obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.creditCardId)
      ..writeByte(2)
      ..write(obj.billDate)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.statementPeriodStart)
      ..writeByte(5)
      ..write(obj.statementPeriodEnd)
      ..writeByte(6)
      ..write(obj.previousBalance)
      ..writeByte(7)
      ..write(obj.totalPayments)
      ..writeByte(8)
      ..write(obj.totalPurchases)
      ..writeByte(9)
      ..write(obj.totalInterest)
      ..writeByte(10)
      ..write(obj.totalFees)
      ..writeByte(11)
      ..write(obj.newBalance)
      ..writeByte(12)
      ..write(obj.minimumPayment)
      ..writeByte(13)
      ..write(obj.availableCredit)
      ..writeByte(14)
      ..write(obj.status)
      ..writeByte(15)
      ..write(obj.paymentDate)
      ..writeByte(16)
      ..write(obj.paymentAmount)
      ..writeByte(17)
      ..write(obj.filePath)
      ..writeByte(18)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillStatusAdapter extends TypeAdapter<BillStatus> {
  @override
  final int typeId = 12;

  @override
  BillStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BillStatus.pending;
      case 1:
        return BillStatus.dueSoon;
      case 2:
        return BillStatus.overdue;
      case 3:
        return BillStatus.paid;
      case 4:
        return BillStatus.cancelled;
      default:
        return BillStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, BillStatus obj) {
    switch (obj) {
      case BillStatus.pending:
        writer.writeByte(0);
        break;
      case BillStatus.dueSoon:
        writer.writeByte(1);
        break;
      case BillStatus.overdue:
        writer.writeByte(2);
        break;
      case BillStatus.paid:
        writer.writeByte(3);
        break;
      case BillStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
