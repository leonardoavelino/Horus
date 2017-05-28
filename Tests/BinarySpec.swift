//
//  BinarySpec.swift
//  Horus
//
//  Created by Caynan Sousa on 5/27/17.
//  Copyright © 2017 Caynan. All rights reserved.
//

import Quick
import Nimble
@testable import Horus

class BinarySpec: QuickSpec {
    
    override func spec() {
        describe("BinarySpec") {
            // MARK: - Initialization
            context("Initializations") {
                it("initializes with array literal.") {
                    let binary: Binary? = [0x63, 0x61, 0x79, 0x6E, 0x61, 0x6E, 0x00]
                    expect(binary).toNot(beNil())
                }
                
                it("initializes with Data object.") {
                    let data: Data = Data()
                    let binary: Binary? = Binary(with: data)
                    
                    expect(binary).toNot(beNil())
                }
                
                it("initializes with array of bytes (aka UInt8).") {
                    let dataArray: [UInt8] = [0x63, 0x61, 0x79, 0x6E, 0x61, 0x6E, 0x00]
                    let binary: Binary? = Binary(with: dataArray)
                    
                    expect(binary).toNot(beNil())
                }
            }
            
            // MARK: - Integer parsing
            context("Integer Parsing") {
                
                // MARK: Unsigned Integers
                it("Should parse UInt8 with length") {
                    do {
                        let binary: Binary = [0xFF]
                        let parsedInt: UInt8 = try binary.scanValue(start: 0, length: 1)
                        expect(parsedInt).to(equal(UInt8.max)) // UInt8.max => 255
                    } catch {
                        fail("It should have parsed UInt8, but it failed.")
                    }
                }
                
                it("Should parse UInt8") {
                    let binary: Binary = [0xFF]
                    do {
                        let parsedInt: UInt8 = try binary.get(at: 0)
                        expect(parsedInt).to(equal(UInt8.max)) // UInt8.max => 255
                    } catch {
                        fail("It should have parsed UInt8, but it failed.")
                    }
                }
                
                it("Should parse UInt16 with length") {
                    let binary: Binary = [0xFF, 0xFF]
                    do {
                        let parsedInt: UInt16 = try binary.scanValue(start: 0, length: 2)
                        expect(parsedInt).to(equal(UInt16.max)) // UInt16.max => 65535
                    } catch {
                        fail("It should have parsed UInt16, but it failed.")
                    }
                }
                
                it("Should parse UInt16") {
                    let binary: Binary = [0xFF, 0xFF]
                    do {
                        let parsedInt: UInt16 = try binary.get(at: 0)
                        expect(parsedInt).to(equal(UInt16.max)) // UInt16.max => 65535
                    } catch {
                        fail("It should have parsed UInt16, but it failed.")
                    }
                }
                
                it("Should parse UInt32 with length") {
                    let binary: Binary = [0xFF, 0xFF, 0xFF, 0xFF]
                    do {
                        let parsedInt: UInt32 = try binary.scanValue(start: 0, length: 4)
                        expect(parsedInt).to(equal(UInt32.max)) // UInt32.max => 4294967295
                    } catch {
                        fail("It should have parsed UInt32, but it failed.")
                    }
                }
                
                it("Should parse UInt32") {
                    let binary: Binary = [0xFF, 0xFF, 0xFF, 0xFF]
                    do {
                        let parsedInt: UInt32 = try binary.get(at: 0)
                        expect(parsedInt).to(equal(UInt32.max)) // UInt32.max => 4294967295
                    } catch {
                        fail("It should have parsed UInt32, but it failed.")
                    }
                }
                
                it("Should parse UInt64 with length") {
                    let binary: Binary = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
                    do {
                        let parsedInt: UInt32 = try binary.scanValue(start: 0, length: 8)
                        expect(parsedInt).to(equal(UInt32.max)) // UInt64.max => 18446744073709551615
                    } catch {
                        fail("It should have parsed UInt64, but it failed.")
                    }
                }
                
                it("Should parse UInt64") {
                    let binary: Binary = [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
                    do {
                        let parsedInt: UInt64 = try binary.get(at: 0)
                        expect(parsedInt).to(equal(UInt64.max)) // UInt64.max => 18446744073709551615
                    } catch {
                        fail("It should have parsed UInt64, but it failed.")
                    }
                }
                
                // MARK: Signed Integers
                // TODO: Add test for remaining Integer types.
            }
        }
    }
    
}

