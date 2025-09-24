// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanPaymentAdapter extends TypeAdapter<LoanPayment> {
  @override
  final int typeId = 15;

  @override
  LoanPayment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanPayment(
      id: fields[0] as String,
      loanId: fields[1] as String,
      amount: fields[2] as double,
      principalAmount: fields[3] as double,
      interestAmount: fields[4] as double,
      paymentDate: fields[5] as DateTime,
      dueDate: fields[6] as DateTime,
      paymentMethod: fields[7] as PaymentMethod,
      accountId: fields[8] as String?,
      transactionId: fields[9] as String?,
      status: fields[10] as PaymentStatus,
      notes: fields[11] as String?,
      isExtraPayment: fields[12] as bool,
      createdAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LoanPayment obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.loanId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.principalAmount)
      ..writeByte(4)
      ..write(obj.interestAmount)
      ..writeByte(5)
      ..write(obj.paymentDate)
      ..writeByte(6)
      ..write(obj.dueDate)
      ..writeByte(7)
      ..write(obj.paymentMethod)
      ..writeByte(8)
      ..write(obj.accountId)
      ..writeByte(9)
      ..write(obj.transactionId)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.isExtraPayment)
      ..writeByte(13)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanPaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 16;

  @override
  PaymentMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethod.bankTransfer;
      case 1:
        return PaymentMethod.creditCard;
      case 2:
        return PaymentMethod.cash;
      case 3:
        return PaymentMethod.check;
      case 4:
        return PaymentMethod.automatic;
      case 5:
        return PaymentMethod.online;
      case 6:
        return PaymentMethod.other;
      default:
        return PaymentMethod.bankTransfer;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    switch (obj) {
      case PaymentMethod.bankTransfer:
        writer.writeByte(0);
        break;
      case PaymentMethod.creditCard:
        writer.writeByte(1);
        break;
      case PaymentMethod.cash:
        writer.writeByte(2);
        break;
      case PaymentMethod.check:
        writer.writeByte(3);
        break;
      case PaymentMethod.automatic:
        writer.writeByte(4);
        break;
      case PaymentMethod.online:
        writer.writeByte(5);
        break;
      case PaymentMethod.other:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentStatusAdapter extends TypeAdapter<PaymentStatus> {
  @override
  final int typeId = 17;

  @override
  PaymentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentStatus.pending;
      case 1:
        return PaymentStatus.completed;
      case 2:
        return PaymentStatus.failed;
      case 3:
        return PaymentStatus.overdue;
      case 4:
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentStatus obj) {
    switch (obj) {
      case PaymentStatus.pending:
        writer.writeByte(0);
        break;
      case PaymentStatus.completed:
        writer.writeByte(1);
        break;
      case PaymentStatus.failed:
        writer.writeByte(2);
        break;
      case PaymentStatus.overdue:
        writer.writeByte(3);
        break;
      case PaymentStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
