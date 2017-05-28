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
        guard end <= self.data.count else { throw BinaryError.outOfBounds }
        
        return self.data.subdata(in: start..<end).withUnsafeBytes{ $0.pointee }
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
        guard end <= self.data.count else { throw BinaryError.outOfBounds }
        
        return try self.scanValue(start: offset, length: end)
    }
}
