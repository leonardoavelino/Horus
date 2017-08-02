//
//  SynchronizedBinary.swift
//  Horus
//
//  Created by Caynan Sousa on 8/2/17.
//  Copyright © 2017 Caynan. All rights reserved.
//

import Foundation

/// A thread-safe Binary.
public final class SynchronizedBinary: ExpressibleByArrayLiteral {
    // MARK: - Properties
    /// Queue for Sync
    fileprivate let queue = DispatchQueue(label: "io.zamzam.ZamzamKit.SynchronizedArray", attributes: .concurrent)

    /// Underlaying data for this struct.
    fileprivate var binary: Binary

    /// The first index of the container.
    public var startIndex: Binary.Index {
        var result: Binary.Index?
        queue.sync { result = self.binary.startIndex }

        return result!
    }

    /// The last index of the container.
    public var endIndex: Binary.Index {
        var result: Binary.Index?
        queue.sync { result = self.binary.endIndex }

        return result!
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
        self.binary = Binary(with: elements)
    }

    /**
     Initialize with a `Data` Object.
     
     You may initialize `Binary` with a `Data` object.
     
     - parameter data: `Data` object to parse.
     
     - Returns: Initialized object.
     
     - Note: Data is copied, so be careful if you're trying to parse a large amount of data.
     */
    public init(with data: Data) {
        self.binary = Binary(with: data)

    }

    /**
     Initialize with an Array.
     
     You may initialize `Binary` with an `Array` of `UInt8`.
     
     - parameter data: `[UInt8]` object to parse.
     
     - Returns: Initialized object.
     
     - Note: Data is copied, so be careful if you're trying to parse a large amount of data.
     */
    public init(with data: [UInt8]) {
        self.binary = Binary(with: data)
    }

    /**
     Initialize with an Integer.
     
     You may initialize `Binary` with an `Integer`.
     
     - parameter number: Integer object to parse.
     
     - Returns: Initialized object.
     
     - Note: Data is copied, so be careful if you're trying to parse a large amount of data.
     */
    public init<T: Integer>(with number: T) {
        self.binary = Binary(with: number)
    }

    /// Initialize with a hexadecimal string.
    ///
    /// - Parameter hexString: Hexadecimal string (e.g: "FACA")
    public init?(with hexString: String) {
        guard let stringBin = Binary(with: hexString) else {
            return nil
        }

        self.binary = stringBin
    }

    /// The number of bytes contained in self.
    public var count: Int {
        var result = 0
        queue.sync { [unowned self] in
            result = self.binary.count
        }

        return result
    }
}

// MARK: - MutableCollection Protocol
extension SynchronizedBinary: MutableCollection {
    /// Get the index after the given index
    ///
    /// - Parameter i: a `Binary.Index` aka Int.
    /// - Returns: The next `Binary.Index`
    public func index(after i: Binary.Index) -> Binary.Index {
        var result: Binary.Index?
        queue.sync { [unowned self] in
            result = self.binary.index(after: i)
        }

        return result!
    }

    /// Get a byte on a given index.
    ///
    /// - Parameter index: The index
    public subscript(position: Binary.Index) -> Binary.Element {
        get {
            var result: Binary.Element?
            queue.sync { [unowned self] in
                precondition(position < self.count, "Index out of bounds.")
                result = self.binary[position]
            }

            return result!
        }

        set {
            queue.async(flags: .barrier) { [unowned self] in
                precondition(position < self.count, "Index out of bounds.")
                self.binary[position] = newValue
            }
        }
    }

    /// Accesses the bytes at the specified range of indexes.
    ///
    /// - Parameter range: The range of indexes (the upperBound is not included)
    public subscript(bounds: Range<Binary.Index>) -> Binary.SubSequence {
        get {
            var result: Binary.SubSequence?
            queue.sync { [unowned self] in
                result = self.binary[bounds]
            }

            return result!
        }

        set {
            queue.async(flags: .barrier) { [unowned self] in
                self.binary[bounds] = newValue
            }
        }
    }

    /// Accesses the bytes at the specified range of indexes.
    ///
    /// - Parameter range: An open range of consecutive elements (e.g: 0..<5)
    public subscript(bounds: CountableRange<Binary.Index>) -> Binary.SubSequence {
        get {
            var result: Binary.SubSequence?
            queue.sync { [unowned self] in
                result = self.binary[Range(bounds)]
            }

            return result!
        }

        set {
            queue.async(flags: .barrier) { [unowned self] in
                self.binary[bounds] = newValue
            }
        }
    }

    /// Accesses the bytes at the specified range of indexes.
    ///
    /// - Parameter range: A closed range (e.g: lowerBound...upperBound)
    public subscript(bounds: CountableClosedRange<Binary.Index>) -> Binary.SubSequence {
        get {
            var result: Binary.SubSequence?
            queue.sync { [unowned self] in
                result = self.binary[bounds]
            }

            return result!
        }

        set {
            queue.async(flags: .barrier) { [unowned self] in
                self.binary[bounds] = newValue
            }
        }
    }
}

extension SynchronizedBinary: RangeReplaceableCollection {
    public convenience init() {
        self.binary = Binary()
    }

    /// Replaces a region of bytes in the data with new bytes from a collection.
    ///
    /// - Parameters:
    ///   - subrange: The range in the binary to replace.
    ///   - newElements: The replacement bytes.
    /// - Note: This will resize the data if required, to fit the entire contents of newElements.
    /// - Precondition: The bounds of subrange must be valid indices of the collection.
    public func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection,
        C.Iterator.Element == Binary.Element {
            queue.async(flags: .barrier) { [unowned self] in
                self.binary.replaceSubrange(subrange, with: newElements)
            }
    }
}

// MARK: - Bit manipulation
extension SynchronizedBinary {
    /// Get a bit on a given position.
    ///
    /// - Parameter position: the position of the bit we want.
    /// - Returns: Byte with the selected bit.
    /// - Throws: `BinaryError.outOfBounds` if position is out of bounds.
    public func bit(_ position: Int, isLittleEndian: Bool = true ) throws -> UInt8 {
        var error: BinaryError?
        var result: UInt8?
        
        queue.sync { [unowned self] in
            do {
                try result = self.binary.bit(position, isLittleEndian: isLittleEndian)
            } catch let e {
                result = nil
                error = e as? BinaryError
            }
        }

        guard error == nil else {
            throw error!
        }
        
        return result!
    }
    
    public func set(bitIndex position: Int, value: Bool, isLittleEndian: Bool = true) throws {
        var error: BinaryError?
        
        queue.sync { [unowned self] in
            do {
                try self.binary.set(bitIndex: <#T##Int#>, value: <#T##Bool#>, isLittleEndian: <#T##Bool#>)
            } catch let e {
                error = e as? BinaryError
            }
        }
        
        // Rethrow error.
        guard error == nil else {
            throw error!
        }
    }

    /// Get a nibble on a given position.
    ///
    /// - Parameter position: the position of the nibble we want.
    /// - Returns: Byte with the selected bit.
    /// - Throws: `BinaryError.outOfBounds` if position is out of bounds.
    public func nibble(_ position: Int) throws -> UInt8 {
        var error: BinaryError?
        var result: UInt8?
        
        queue.sync { [unowned self] in
            do {
                result = try self.binary.nibble(position)
            } catch let e {
                error = e as? BinaryError
            }
        }
        
        guard error == nil else {
            throw error!
        }
        
        return result!
    }
}

// MARK: - Integer Parsers
extension SynchronizedBinary {
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
        var result: T?
        var error: BinaryError?
        
        queue.sync { [unowned self] in
            do {
                try result = self.binary.scanValue(start: start, length: length)
            } catch let e {
                error = e as? BinaryError
            }
        }
        
        guard error == nil else {
            throw error!
        }
        
        return result!
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
        var result: T?
        var error: BinaryError?
        
        queue.sync { [unowned self] in
            do {
                try result = self.binary.get(at: offset)
            } catch let e {
                error = e as? BinaryError
            }
        }
        
        guard error == nil else {
            throw error!
        }
        
        return result!
    }
}

// MARK: - FloatingPoint Parsers
extension SynchronizedBinary {
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
        var result: T?
        var error: BinaryError?
        
        queue.sync { [unowned self] in
            do {
                try result = self.binary.scanValue(start: start, length: length)
            } catch let e {
                error = e as? BinaryError
            }
        }
        
        guard error == nil else {
            throw error!
        }
        
        return result!
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
        var result: T?
        var error: BinaryError?
        
        queue.sync { [unowned self] in
            do {
                try result = self.binary.get(at: offset)
            } catch let e {
                error = e as? BinaryError
            }
        }
        
        guard error == nil else {
            throw error!
        }
        
        return result!
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
        var result: String?
        var error: BinaryError?
        
        queue.sync { [unowned self] in
            do {
                try result = self.binary.get(offset: offset, length: length, encoding: encoding)
            } catch let e {
                error = e as? BinaryError
            }
        }
        
        guard error == nil else {
            throw error!
        }
        
        return result!
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
        var result: String?
        var error: BinaryError?
        
        queue.sync { [unowned self] in
            do {
                try result = self.binary.get(offset: offset, encoding: encoding)
            } catch let e {
                error = e as? BinaryError
            }
        }
        
        guard error == nil else {
            throw error!
        }
        
        return result!
    }
}

// MARK: - Conversions
extension SynchronizedBinary {
    /// Get an array with the contents of `Binary`
    ///
    /// - Returns: [UInt8] with bytes from `Binary`
    public func toByteArray() -> [UInt8] {
        var result: [UInt8]?
        queue.sync { [unowned self] in
            result =  self.binary.toByteArray()
        }
        
        return result!
    }
}

// MARK: - Equatable Protocol
extension SynchronizedBinary: Equatable {
    public static func ==(lhs: SynchronizedBinary, rhs: SynchronizedBinary) -> Bool {
        return lhs.binary == rhs.binary
    }
}
