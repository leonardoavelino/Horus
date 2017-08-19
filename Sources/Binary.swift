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
    // MARK: - Properties

    /// Underlaying data for this struct.
    fileprivate var data: Data

    public typealias Element = UInt8
    public typealias SubSequence = Binary
    public typealias Index = Int
    public typealias IndexDistance = Int

    /// The first index of the container.
    public var startIndex: Binary.Index {
        return self.data.startIndex
    }

    /// The last index of the container.
    public var endIndex: Binary.Index {
        return self.data.endIndex
    }

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
    public init(arrayLiteral elements: Binary.Element...) {
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

    /**
     Initialize with an Integer.
     
     You may initialize `Binary` with an `Integer`.
     
     - parameter number: Integer object to parse.
     
     - Returns: Initialized object.
     
     - Note: Data is copied, so be careful if you're trying to parse a large amount of data.
     */
    public init<T: Integer>(with number: T) {
        var _number = number
        self.init(with: Data(buffer: UnsafeBufferPointer(start: &_number, count: 1)).reversed())
    }

    /// Initialize with a hexadecimal string.
    ///
    /// - Parameter hexString: Hexadecimal string (e.g: "FACA")
    public init?(with hexString: String) {
        guard let byteArray = Binary.hexaToBytes(hexString: hexString) else {
            print("'\(hexString)' is not a valid hexadecimal")
            return nil
        }

        self.init(with: byteArray)
    }

    /// The number of bytes contained in self.
    public var count: Int {
        return self.data.count
    }

    // MARK: - Private Methods
    /// Convert a hexa string to an array of bytes.
    ///
    /// - Parameter hexString: A hexa string.
    /// - Returns: an [UInt8] representation of hexString.
    private static func hexaToBytes(hexString: String) -> [UInt8]? {
        var hexaString = hexString
        // clean hexaString case hexString starts with 0x or 0X.
        if hexaString.hasPrefix("0x") || hexaString.hasPrefix("0X") {
            let indexStartOfHexa = hexaString.index(hexaString.startIndex, offsetBy: 2)
            hexaString = hexaString.substring(with: indexStartOfHexa..<hexaString.endIndex)
        }

        // `isHexadecimal` is a local extension. see `StringHelper`
        guard hexaString.isHexadecimal() else { return nil }

        var hexa = Array(hexaString.characters)
        // pad with zeros on the left, case odd length.
        if hexa.count % 2 != 0 { hexa.insert("0", at: 0) }

        return stride(from: 0, to: hexa.count, by: 2).flatMap {
            UInt8(String(hexa[$0..<$0.advanced(by: 2)]), radix: 16)
        }
    }
}

// MARK: - MutableCollection Protocol
extension Binary: MutableCollection {
    /// Get the index after the given index
    ///
    /// - Parameter i: a `Binary.Index` aka Int.
    /// - Returns: The next `Binary.Index`
    public func index(after i: Binary.Index) -> Binary.Index {
        return self.data.index(after: i)
    }

    /// Get a byte on a given index.
    ///
    /// - Parameter index: The index
    public subscript(position: Binary.Index) -> Binary.Element {
        get {
            precondition(position < self.count, "Index out of bounds.")

            return self.data[position]
        }

        set {
            precondition(position < self.count, "Index out of bounds.")

            self.data[position] = newValue
        }
    }

    /// Accesses the bytes at the specified range of indexes.
    ///
    /// - Parameter range: The range of indexes (the upperBound is not included)
    public subscript(bounds: Range<Binary.Index>) -> Binary.SubSequence {
        get {
            let range = Range(bounds.lowerBound..<bounds.upperBound)
            let subData = Data(self.data[range])
            return Binary(with: subData)
        }

        set {
            self.data.replaceSubrange(bounds, with: newValue)
        }
    }

    /// Accesses the bytes at the specified range of indexes.
    ///
    /// - Parameter range: An open range of consecutive elements (e.g: 0..<5)
    public subscript(bounds: CountableRange<Binary.Index>) -> Binary.SubSequence {
        get {
            return self[Range(bounds)]
        }

        set {
            self[Range(bounds.lowerBound ..< bounds.upperBound)] = newValue
        }
    }

    /// Accesses the bytes at the specified range of indexes.
    ///
    /// - Parameter range: A closed range (e.g: lowerBound...upperBound)
    public subscript(bounds: CountableClosedRange<Binary.Index>) -> Binary.SubSequence {
        get {
            return self[Range(bounds.lowerBound..<bounds.upperBound + 1)]
        }

        set {
            self[Range(bounds.lowerBound..<bounds.upperBound + 1)] = newValue
        }
    }
}

extension Binary: RangeReplaceableCollection {
    public init() {
        self.data = Data()
    }

    /// Replaces a region of bytes in the data with new bytes from a collection.
    ///
    /// - Parameters:
    ///   - subrange: The range in the binary to replace.
    ///   - newElements: The replacement bytes.
    /// - Note: This will resize the data if required, to fit the entire contents of newElements.
    /// - Precondition: The bounds of subrange must be valid indices of the collection.
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, C.Iterator.Element == Binary.Element {
        self.data.replaceSubrange(subrange, with: newElements)
    }
}

// MARK: - Bit manipulation
extension Binary {
    /// Get a bit on a given position.
    ///
    /// - Parameter position: the position of the bit we want.
    /// - Returns: Byte with the selected bit.
    /// - Throws: `BinaryError.outOfBounds` if position is out of bounds.
    public func bit(_ position: Int, isLittleEndian: Bool = true ) throws -> UInt8 {
        let byteSize = 8
        let bytePosition: Int
        let bitPosition: UInt8

        if isLittleEndian {
            bytePosition = self.count - (position / byteSize) - 1
            bitPosition = UInt8(position % byteSize)
        } else {
            bytePosition = position / byteSize
            bitPosition = UInt8(7 - (position % byteSize))
        }
        // Check invariants for byte position.
        guard bytePosition >= 0, bytePosition < self.count else { throw BinaryError.outOfBounds }

        // Get byte and return the requested bit.
        let byte: UInt8 = self[bytePosition]
        return (byte >> bitPosition) & 0x01
    }

    public mutating func set(bitIndex position: Int, value: Bool, isLittleEndian: Bool = true) throws {
        let byteSize = 8
        let bytePosition: Int
        let bitPosition: UInt8

        if isLittleEndian {
            bytePosition = self.count - (position / byteSize) - 1
            bitPosition = UInt8(position % byteSize)
        } else {
            bytePosition = position / byteSize
            bitPosition = UInt8(7 - (position % byteSize))
        }
        // Check invariants for byte position.
        guard bytePosition >= 0, bytePosition < self.count else { throw BinaryError.outOfBounds }

        // bitmask
        let mask: UInt8 = 1 << bitPosition

        // Set value.
        if value {
            self[bytePosition] |= mask
        } else {
            self[bytePosition] &= mask
        }
    }

    /// Get a nibble on a given position.
    ///
    /// - Parameter position: the position of the nibble we want.
    /// - Returns: Byte with the selected bit.
    /// - Throws: `BinaryError.outOfBounds` if position is out of bounds.
    public func nibble(_ position: Int) throws -> UInt8 {
        let bytePosition = position / 2
        let nibblePosition = position % 2

        guard bytePosition < self.count else { throw BinaryError.outOfBounds }
        var value: UInt8
        switch nibblePosition {
        case 0:
            let byte = self[bytePosition]
            value = byte >> 4
        case 1:
            let byte = self[bytePosition]
            value = byte
        default:
            fatalError("This should never happen")
        }

        return value & 0x0F
    }
}

// MARK: - Integer Parsers
extension Binary {
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
}

// MARK: - FloatingPoint Parsers
extension Binary {
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

// MARK: - Conversions
extension Binary {
    /// Get an array with the contents of `Binary`
    ///
    /// - Returns: [UInt8] with bytes from `Binary`
    public func toByteArray() -> [UInt8] {
        return Array(self.data)
    }
}

// MARK: - String Convertible
extension Binary: CustomStringConvertible {
    public var description: String {
        return self.data.hexEncodedString()
    }
}

// MARK: - Equatable Protocol
extension Binary: Equatable {
    public static func ==(lhs: Binary, rhs: Binary) -> Bool {
        return lhs.data == rhs.data
    }
}
