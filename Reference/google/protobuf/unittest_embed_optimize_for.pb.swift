/*
 * DO NOT EDIT.
 *
 * Generated by the protocol buffer compiler.
 * Source: google/protobuf/unittest_embed_optimize_for.proto
 *
 */

//  Protocol Buffers - Google's data interchange format
//  Copyright 2008 Google Inc.  All rights reserved.
//  https://developers.google.com/protocol-buffers/
// 
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are
//  met:
// 
//      * Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above
//  copyright notice, this list of conditions and the following disclaimer
//  in the documentation and/or other materials provided with the
//  distribution.
//      * Neither the name of Google Inc. nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
// 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
//  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
//  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

//  Author: kenton@google.com (Kenton Varda)
//   Based on original Protocol Buffers design by
//   Sanjay Ghemawat, Jeff Dean, and others.
// 
//  A proto file which imports a proto file that uses optimize_for = CODE_SIZE.

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _1: SwiftProtobuf.ProtobufAPIVersion_1 {}
  typealias Version = _1
}

struct ProtobufUnittest_TestEmbedOptimizedForSize: SwiftProtobuf.Message, SwiftProtobuf.Proto2Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf.ProtoNameProviding {
  static let protoMessageName: String = "TestEmbedOptimizedForSize"
  static let protoPackageName: String = "protobuf_unittest"
  static let _protobuf_fieldNames: FieldNameMap = [
    1: .unique(proto: "optional_message", json: "optionalMessage"),
    2: .unique(proto: "repeated_message", json: "repeatedMessage"),
  ]

  private class _StorageClass {
    var unknownFields = SwiftProtobuf.UnknownStorage()
    var _optionalMessage: ProtobufUnittest_TestOptimizedForSize? = nil
    var _repeatedMessage: [ProtobufUnittest_TestOptimizedForSize] = []

    init() {}

    var isInitialized: Bool {
      if let v = _optionalMessage, !v.isInitialized {return false}
      if !SwiftProtobuf.Internal.areAllInitialized(_repeatedMessage) {return false}
      return true
    }

    func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
      while let fieldNumber = try decoder.nextFieldNumber() {
        try decodeField(decoder: &decoder, fieldNumber: fieldNumber)
      }
    }

    func decodeField<D: SwiftProtobuf.Decoder>(decoder: inout D, fieldNumber: Int) throws {
      switch fieldNumber {
      case 1: try decoder.decodeSingularMessageField(value: &_optionalMessage)
      case 2: try decoder.decodeRepeatedMessageField(value: &_repeatedMessage)
      default: break
      }
    }

    func traverse(visitor: SwiftProtobuf.Visitor) throws {
      if let v = _optionalMessage {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      }
      if !_repeatedMessage.isEmpty {
        try visitor.visitRepeatedMessageField(value: _repeatedMessage, fieldNumber: 2)
      }
      unknownFields.traverse(visitor: visitor)
    }

    func isEqualTo(other: _StorageClass) -> Bool {
      if _optionalMessage != other._optionalMessage {return false}
      if _repeatedMessage != other._repeatedMessage {return false}
      if unknownFields != other.unknownFields {return false}
      return true
    }

    func copy() -> _StorageClass {
      let clone = _StorageClass()
      clone.unknownFields = unknownFields
      clone._optionalMessage = _optionalMessage
      clone._repeatedMessage = _repeatedMessage
      return clone
    }
  }

  private var _storage = _StorageClass()

  var unknownFields: SwiftProtobuf.UnknownStorage {
    get {return _storage.unknownFields}
    set {_storage.unknownFields = newValue}
  }

  ///   Test that embedding a message which has optimize_for = CODE_SIZE into
  ///   one optimized for speed works.
  var optionalMessage: ProtobufUnittest_TestOptimizedForSize {
    get {return _storage._optionalMessage ?? ProtobufUnittest_TestOptimizedForSize()}
    set {_uniqueStorage()._optionalMessage = newValue}
  }
  var hasOptionalMessage: Bool {
    return _storage._optionalMessage != nil
  }
  mutating func clearOptionalMessage() {
    return _storage._optionalMessage = nil
  }

  var repeatedMessage: [ProtobufUnittest_TestOptimizedForSize] {
    get {return _storage._repeatedMessage}
    set {_uniqueStorage()._repeatedMessage = newValue}
  }

  init() {}

  public var isInitialized: Bool {
    return _storage.isInitialized
  }

  mutating func _protoc_generated_decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    try _uniqueStorage().decodeMessage(decoder: &decoder)
  }

  mutating func _protoc_generated_decodeField<D: SwiftProtobuf.Decoder>(decoder: inout D, fieldNumber: Int) throws {
    try _uniqueStorage().decodeField(decoder: &decoder, fieldNumber: fieldNumber)
  }

  func _protoc_generated_traverse(visitor: SwiftProtobuf.Visitor) throws {
    try _storage.traverse(visitor: visitor)
  }

  func _protoc_generated_isEqualTo(other: ProtobufUnittest_TestEmbedOptimizedForSize) -> Bool {
    return _storage === other._storage || _storage.isEqualTo(other: other._storage)
  }

  private mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _storage.copy()
    }
    return _storage
  }
}
