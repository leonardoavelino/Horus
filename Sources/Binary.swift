//
//  Binary.swift
//  Horus
//
//  Created by Caynan Sousa on 5/27/17.
//  Copyright © 2017 Caynan. All rights reserved.
//

import Foundation

/// Wrapper for immutable parsing of binary data.
public struct Binary: ExpressibleByArrayLiteral {
    public typealias Element = UInt8

    // MARK: - Properties

    /// Underlaying data for this struct.
    private let data: Data

    // MARK: - Initializers

    /**
     Initialize with an array literal.
     
     You may initialize `Binary` with an array literal like so:
     ```
     let data: Binary = [0x63, 0x61, 0x79, 0x6E, 0x61, 0x6E, 0x00]
     ```
     
     - parameter elements: Array literal of bytes (aka `UInt8`).
     
     - Returns: Initialized object.
     
     - Note: Data is copied, so be careful if you're trying to parse a large amount of data.
     */
    public init(arrayLiteral elements: Element...) {
        self.data = Data(bytes: elements)
    }

    /**
     Initialize with a `Data` Object.
     
     You may initialize `Binary` with a `Data` object.
     
     - parameter data: `Data` object to parse.
     
     - Returns: Initialized object.
     
     - Note: Data is copied, so be careful if you're trying to parse a large amount of data.
     */
    public init(with data: Data) {
        self.data = data
    }

    /**
     Initialize with an Array.
     
     You may initialize `Binary` with an `Array` of `UInt8`.
     
     - parameter data: `[UInt8]` object to parse.
     
     - Returns: Initialized object.
     
     - Note: Data is copied, so be careful if you're trying to parse a large amount of data.
     */
    public init(with data: [UInt8]) {
        self.data = Data(bytes: data)
    }

    /// Get a byte on a given index.
    ///
    /// - Parameter index: The index
    public subscript(index: Int) -> UInt8 {
        precondition(index < self.count, "Index out of bounds.")

        return self.data[index]
    }

    /// Accesses the bytes at the specified range of indexes.
    ///
    /// - Parameter range: The range of indexes (the upperBound is not included)
    public subscript(range: Range<Int>) -> Binary {
        precondition(range.lowerBound >= 0 && range.upperBound < self.count, "Index out of bounds.")

        let range = Range(range.lowerBound..<range.upperBound)
        let subData = Data(self.data[range])
        return Binary(with: subData)
    }

    /// Accesses the bytes at the specified range of indexes.
    ///
    /// - Parameter range: A closed range (e.g: lowerBound...upperBound)
    public subscript(range: CountableClosedRange<Int>) -> Binary {
        precondition(range.lowerBound >= 0 && range.upperBound < self.count, "Index out of bounds.")

        return self[range.lowerBound..<range.upperBound + 1]
    }

    /// The number of bytes contained in self.
    public var count: Int {
        return self.data.count
    }

    // MARK: - Integer parsing
    /**
     Scan an Integer from data.
     
     `Integer` is a protocol that all signed and unsigned numbers in swift extend from.
     see [hierarchy](http://swiftdoc.org/v3.0/protocol/Integer/hierarchy/).
     
     - parameter start: index of first byte.
     - parameter length: the length of the given number.
     
     - Throws: `BinaryError.outOfBounds` if `start + length` is bigger than the total length of binary array.
     
     - Returns: The parsed integer number.
     */
    public func scanValue<T: Integer>(start: Int, length: Int) throws -> T {
        let end = start + length
        guard end <= self.count else { throw BinaryError.outOfBounds }

        return self.data.subdata(in: start..<end).withUnsafeBytes { $0.pointee }
    }

    /**
     Scan an Integer from data, auto inferring length from the return type. See note for caveats.
     
     `Integer` is a protocol that all signed and unsigned numbers in swift extend from.
     see [hierarchy](http://swiftdoc.org/v3.0/protocol/Integer/hierarchy/).
     
     - parameter offset: index of `Integer` first byte.
     
     - Throws: `BinaryError.outOfBounds` if `offset + type.size` is bigger than the total length of binary array.
     
     - Returns: The parsed integer number.
     
     - Note: 
        - On a 32-bit platform, Int is the same size as Int32.
        - On a 32-bit platform, UInt is the same size as UInt32.
        - On a 64-bit platform, Int is the same size as Int64.
        - On a 64-bit platform, UInt is the same size as UInt64.
     */
    public func get<T: Integer>(at offset: Int) throws -> T {
        let end = offset + MemoryLayout<T>.size
        guard end <= self.count else { throw BinaryError.outOfBounds }

        return try self.scanValue(start: offset, length: end)
    }

    /**
     Scan a `FloatingPoint` from data.
     
     `FloatingPoint` is a protocol that all decimal numbers extend from.
     see [hierarchy](http://swiftdoc.org/v3.0/protocol/FloatingPoint/hierarchy/).
     
     - parameter start: index of first byte.
     - parameter length: the length of given number.
     
     - Throws: `BinaryError.outOfBounds` if `start + length` is bigger than the total length of binary array.
     
     - Returns: The parsed decimal number.
     */
    public func scanValue<T: FloatingPoint>(start: Int, length: Int) throws -> T {
        let end = start + length
        guard end <= self.count else { throw BinaryError.outOfBounds }

        return self.data.subdata(in: start..<end).withUnsafeBytes { $0.pointee }
    }

    /**
     Scan a `FloatingPoint` from data, auto inferring length from the return type.
     
     `FloatingPoint` is a protocol that all decimal numbers extend from.
     see [hierarchy](http://swiftdoc.org/v3.0/protocol/FloatingPoint/hierarchy/).
     
     - parameter offset: index of `FloatingPoint` first byte.
     
     - Throws: `BinaryError.outOfBounds` if `start + length` is bigger than the total length of binary array.
     
     - Returns: The parsed decimal number.
     */
    public func get<T: FloatingPoint>(at offset: Int) throws -> T {
        let end = offset + MemoryLayout<T>.size
        guard end <= self.count else { throw BinaryError.outOfBounds }

        return try self.scanValue(start: offset, length: end)
    }

    /**
     Parse `String` of known size from underlying data.
     
     - parameter offset: Offset in bytes from where this string should be read.
     - parameter length: Length in bytes of string to read.
     - parameter encoding: Encoding to be used, `ASCII` is the default.
     
     - Throws: 
        - `BinaryError.outOfBounds` if `offset + length` is bigger than the total length of binary array.
        - `BinaryError.failedConversion` if can't create string using the given encoding.
     
     - Returns: String from buffer.
     */
    public func get(offset: Int, length: Int, encoding: String.Encoding = .ascii) throws -> String {
        let end = offset + length
        guard end <= self.count else { throw BinaryError.outOfBounds }

        let strData = self.data.subdata(in: offset..<end)

        guard let response = String(bytes: strData, encoding: encoding) else {
            throw BinaryError.failedConversion
        }

        return response
    }

    /**
     Parse Nul('\0') terminated `String` from underlying data.
     
     - parameter offset: Offset in bytes from where this string should be read.
     - parameter encoding: Encoding to be used, `ASCII` is the default.
     
     - Throws:
     - `BinaryError.outOfBounds` if `offset` is greater or equal to the total length of the binary array.
     - `BinaryError.failedConversion` if can't create string using the given encoding.
     
     - Returns: String from buffer.
     */
    public func get(offset: Int, encoding: String.Encoding = .ascii) throws -> String {
        guard offset <= data.count else { throw BinaryError.outOfBounds }

        // Find the index of the Nul character, or nil if can't find one.
        let nulIndex = data.withUnsafeBytes { (_: UnsafePointer<CChar>) -> Int? in
            for idx in offset..<data.count {
                guard CChar(data[idx]) != CChar(0) else {
                    return idx
                }
            }
            // Case when we reach the end the string before finding '\0'
            return nil
        }

        guard let stringEnd = nulIndex else { throw BinaryError.nonNulTerminatedString }

        let strData = self.data.subdata(in: offset..<stringEnd)

        guard let response = String(data: strData, encoding: encoding) else {
            throw BinaryError.failedConversion
        }

        return response
    }
}
