// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanAdapter extends TypeAdapter<Loan> {
  @override
  final int typeId = 13;

  @override
  Loan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Loan(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as LoanType,
      principalAmount: fields[3] as double,
      currentBalance: fields[4] as double,
      interestRate: fields[5] as double,
      termMonths: fields[6] as int,
      monthlyPayment: fields[7] as double,
      startDate: fields[8] as DateTime,
      endDate: fields[9] as DateTime,
      nextPaymentDate: fields[10] as DateTime,
      accountId: fields[11] as String?,
      lender: fields[12] as String,
      notes: fields[13] as String?,
      isActive: fields[14] as bool,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Loan obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.principalAmount)
      ..writeByte(4)
      ..write(obj.currentBalance)
      ..writeByte(5)
      ..write(obj.interestRate)
      ..writeByte(6)
      ..write(obj.termMonths)
      ..writeByte(7)
      ..write(obj.monthlyPayment)
      ..writeByte(8)
      ..write(obj.startDate)
      ..writeByte(9)
      ..write(obj.endDate)
      ..writeByte(10)
      ..write(obj.nextPaymentDate)
      ..writeByte(11)
      ..write(obj.accountId)
      ..writeByte(12)
      ..write(obj.lender)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.isActive)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoanTypeAdapter extends TypeAdapter<LoanType> {
  @override
  final int typeId = 14;

  @override
  LoanType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LoanType.personal;
      case 1:
        return LoanType.mortgage;
      case 2:
        return LoanType.auto;
      case 3:
        return LoanType.student;
      case 4:
        return LoanType.business;
      case 5:
        return LoanType.homeEquity;
      case 6:
        return LoanType.creditLine;
      case 7:
        return LoanType.other;
      default:
        return LoanType.personal;
    }
  }

  @override
  void write(BinaryWriter writer, LoanType obj) {
    switch (obj) {
      case LoanType.personal:
        writer.writeByte(0);
        break;
      case LoanType.mortgage:
        writer.writeByte(1);
        break;
      case LoanType.auto:
        writer.writeByte(2);
        break;
      case LoanType.student:
        writer.writeByte(3);
        break;
      case LoanType.business:
        writer.writeByte(4);
        break;
      case LoanType.homeEquity:
        writer.writeByte(5);
        break;
      case LoanType.creditLine:
        writer.writeByte(6);
        break;
      case LoanType.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
