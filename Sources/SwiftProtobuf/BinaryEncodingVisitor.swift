// Sources/SwiftProtobuf/BinaryEncodingVisitor.swift - Binary encoding support
//
// Copyright (c) 2014 - 2016 Apple Inc. and the project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information:
// https://github.com/apple/swift-protobuf/blob/master/LICENSE.txt
//
// -----------------------------------------------------------------------------
///
/// Core support for protobuf binary encoding.  Note that this is built
/// on the general traversal machinery.
///
// -----------------------------------------------------------------------------

import Foundation

/// Visitor that encodes a message graph in the protobuf binary wire format.
final class BinaryEncodingVisitor: Visitor {

  private var encoder: BinaryEncoder

  /// Creates a new visitor that writes the binary-coded message into the memory
  /// at the given pointer.
  ///
  /// - Precondition: `pointer` must point to an allocated block of memory that
  ///   is large enough to hold the entire encoded message. For performance
  ///   reasons, the encoder does not make any attempts to verify this.
  init(forWritingInto pointer: UnsafeMutablePointer<UInt8>) {
    encoder = BinaryEncoder(forWritingInto: pointer)
  }

  func visitUnknown(bytes: Data) {
    encoder.appendUnknown(data: bytes)
  }

  func visitSingularField<S: FieldType>(fieldType: S.Type,
                                        value: S.BaseType,
                                        fieldNumber: Int) throws {
    encoder.startField(fieldNumber: fieldNumber,
                       wireFormat: S.protobufWireFormat)
    S.serializeProtobufValue(encoder: &encoder, value: value)
  }

  func visitRepeatedField<S: FieldType>(fieldType: S.Type,
                                        value: [S.BaseType],
                                        fieldNumber: Int) throws {
    for v in value {
      encoder.startField(fieldNumber: fieldNumber,
                         wireFormat: S.protobufWireFormat)
      S.serializeProtobufValue(encoder: &encoder, value: v)
    }
  }

  func visitPackedField<S: FieldType>(fieldType: S.Type,
                                      value: [S.BaseType],
                                      fieldNumber: Int) throws {
    encoder.startField(fieldNumber: fieldNumber, wireFormat: .lengthDelimited)
    var packedSize = 0
    for v in value {
      packedSize += try S.encodedSizeWithoutTag(of: v)
    }
    encoder.putVarInt(value: packedSize)
    for v in value {
      S.serializeProtobufValue(encoder: &encoder, value: v)
    }
  }

  func visitSingularEnumField<E: Enum>(value: E,
                                       fieldNumber: Int) throws {
    encoder.startField(fieldNumber: fieldNumber,
                       wireFormat: .varint)
    encoder.putVarInt(value: value.rawValue)
  }

  func visitRepeatedEnumField<E: Enum>(value: [E],
                                   fieldNumber: Int) throws {
    for v in value {
      encoder.startField(fieldNumber: fieldNumber,
                         wireFormat: .varint)
      encoder.putVarInt(value: v.rawValue)
    }
  }

  func visitPackedEnumField<E: Enum>(value: [E],
                                 fieldNumber: Int) throws {
    encoder.startField(fieldNumber: fieldNumber, wireFormat: .lengthDelimited)
    var packedSize = 0
    for v in value {
      packedSize += Varint.encodedSize(of: Int32(truncatingBitPattern: v.rawValue))
    }
    encoder.putVarInt(value: packedSize)
    for v in value {
      encoder.putVarInt(value: v.rawValue)
    }
  }

  func visitSingularMessageField<M: Message>(value: M,
                                             fieldNumber: Int) throws {
    let t = try value.serializedData()
    encoder.startField(fieldNumber: fieldNumber,
                       wireFormat: .lengthDelimited)
    encoder.putBytesValue(value: t)
  }

  func visitRepeatedMessageField<M: Message>(value: [M],
                                             fieldNumber: Int) throws {
    for v in value {
      let t = try v.serializedData()
      encoder.startField(fieldNumber: fieldNumber,
                         wireFormat: .lengthDelimited)
      encoder.putBytesValue(value: t)
    }
  }

  func visitSingularGroupField<G: Message>(value: G, fieldNumber: Int) throws {
    encoder.startField(fieldNumber: fieldNumber, wireFormat: .startGroup)
    try value.traverse(visitor: self)
    encoder.startField(fieldNumber: fieldNumber, wireFormat: .endGroup)
  }

  func visitRepeatedGroupField<G: Message>(value: [G],
                                           fieldNumber: Int) throws {
    for v in value {
      encoder.startField(fieldNumber: fieldNumber, wireFormat: .startGroup)
      try v.traverse(visitor: self)
      encoder.startField(fieldNumber: fieldNumber, wireFormat: .endGroup)
    }
  }

  func visitMapField<KeyType: MapKeyType, ValueType: MapValueType>(
    fieldType: ProtobufMap<KeyType, ValueType>.Type,
    value: ProtobufMap<KeyType, ValueType>.BaseType,
    fieldNumber: Int
  ) throws where KeyType.BaseType: Hashable {
    for (k,v) in value {
      encoder.startField(fieldNumber: fieldNumber, wireFormat: .lengthDelimited)
      let keyTagSize =
        Varint.encodedSize(of: UInt32(truncatingBitPattern: 1 << 3))
      let valueTagSize =
        Varint.encodedSize(of: UInt32(truncatingBitPattern: 2 << 3))
      let entrySize = try keyTagSize + KeyType.encodedSizeWithoutTag(of: k) +
        valueTagSize + ValueType.encodedSizeWithoutTag(of: v)
      encoder.putVarInt(value: entrySize)
      encoder.startField(fieldNumber: 1, wireFormat: KeyType.protobufWireFormat)
      KeyType.serializeProtobufValue(encoder: &encoder, value: k)
      encoder.startField(fieldNumber: 2,
                         wireFormat: ValueType.protobufWireFormat)
      ValueType.serializeProtobufValue(encoder: &encoder, value: v)
    }
  }

  func visitMapField<KeyType: MapKeyType, ValueType: Enum>(
    fieldType: ProtobufEnumMap<KeyType, ValueType>.Type,
    value: ProtobufEnumMap<KeyType, ValueType>.BaseType,
    fieldNumber: Int
  ) throws where KeyType.BaseType: Hashable, ValueType.RawValue == Int {
    for (k,v) in value {
      encoder.startField(fieldNumber: fieldNumber, wireFormat: .lengthDelimited)
      let keyTagSize =
        Varint.encodedSize(of: UInt32(truncatingBitPattern: 1 << 3))
      let valueTagSize =
        Varint.encodedSize(of: UInt32(truncatingBitPattern: 2 << 3))
      let entrySize = try keyTagSize + KeyType.encodedSizeWithoutTag(of: k) +
        valueTagSize + Varint.encodedSize(of: Int32(truncatingBitPattern: v.rawValue))
      encoder.putVarInt(value: entrySize)
      encoder.startField(fieldNumber: 1, wireFormat: KeyType.protobufWireFormat)
      KeyType.serializeProtobufValue(encoder: &encoder, value: k)
      encoder.startField(fieldNumber: 2, wireFormat: .varint)
      encoder.putVarInt(value: v.rawValue)
    }
  }

  func visitMapField<KeyType: MapKeyType, ValueType: Message>(
    fieldType: ProtobufMessageMap<KeyType, ValueType>.Type,
    value: ProtobufMessageMap<KeyType, ValueType>.BaseType,
    fieldNumber: Int
  ) throws where KeyType.BaseType: Hashable {
    for (k,v) in value {
      encoder.startField(fieldNumber: fieldNumber, wireFormat: .lengthDelimited)
      let keyTagSize =
        Varint.encodedSize(of: UInt32(truncatingBitPattern: 1 << 3))
      let keyValueSize = try KeyType.encodedSizeWithoutTag(of: k)
      let valueTagSize =
        Varint.encodedSize(of: UInt32(truncatingBitPattern: 2 << 3))
      let messageSize = try v.serializedDataSize()
      let valueValueSize = Varint.encodedSize(of: Int64(messageSize)) + messageSize
      let entrySize = keyTagSize + keyValueSize + valueTagSize + valueValueSize
      encoder.putVarInt(value: entrySize)
      encoder.startField(fieldNumber: 1, wireFormat: KeyType.protobufWireFormat)
      KeyType.serializeProtobufValue(encoder: &encoder, value: k)
      encoder.startField(fieldNumber: 2, wireFormat: .lengthDelimited)
      let messageBytes = try! v.serializedData()
      encoder.putBytesValue(value: messageBytes)
    }
  }

  /// Called for each extension range.
  func visitExtensionFields(fields: ExtensionFieldValueSet, start: Int, end: Int) throws {
    try fields.traverse(visitor: self, start: start, end: end)
  }
}
