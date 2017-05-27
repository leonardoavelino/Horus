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
}
