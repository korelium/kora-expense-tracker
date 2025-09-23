// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreditCardTransactionAdapter extends TypeAdapter<CreditCardTransaction> {
  @override
  final int typeId = 7;

  @override
  CreditCardTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreditCardTransaction(
      id: fields[0] as String,
      creditCardId: fields[1] as String,
      transactionId: fields[2] as String,
      categoryId: fields[3] as String,
      amount: fields[4] as double,
      description: fields[5] as String,
      transactionDate: fields[6] as DateTime,
      postingDate: fields[7] as DateTime,
      type: fields[8] as CreditCardTransactionType,
      merchantName: fields[9] as String?,
      location: fields[10] as String?,
      isPending: fields[11] as bool,
      receiptImagePath: fields[12] as String?,
      notes: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CreditCardTransaction obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.creditCardId)
      ..writeByte(2)
      ..write(obj.transactionId)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.transactionDate)
      ..writeByte(7)
      ..write(obj.postingDate)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.merchantName)
      ..writeByte(10)
      ..write(obj.location)
      ..writeByte(11)
      ..write(obj.isPending)
      ..writeByte(12)
      ..write(obj.receiptImagePath)
      ..writeByte(13)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditCardTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CreditCardTransactionTypeAdapter
    extends TypeAdapter<CreditCardTransactionType> {
  @override
  final int typeId = 8;

  @override
  CreditCardTransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CreditCardTransactionType.purchase;
      case 1:
        return CreditCardTransactionType.payment;
      case 2:
        return CreditCardTransactionType.interest;
      case 3:
        return CreditCardTransactionType.fee;
      case 4:
        return CreditCardTransactionType.refund;
      case 5:
        return CreditCardTransactionType.cashAdvance;
      default:
        return CreditCardTransactionType.purchase;
    }
  }

  @override
  void write(BinaryWriter writer, CreditCardTransactionType obj) {
    switch (obj) {
      case CreditCardTransactionType.purchase:
        writer.writeByte(0);
        break;
      case CreditCardTransactionType.payment:
        writer.writeByte(1);
        break;
      case CreditCardTransactionType.interest:
        writer.writeByte(2);
        break;
      case CreditCardTransactionType.fee:
        writer.writeByte(3);
        break;
      case CreditCardTransactionType.refund:
        writer.writeByte(4);
        break;
      case CreditCardTransactionType.cashAdvance:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditCardTransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
