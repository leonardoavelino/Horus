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
                it("Should parse Int") {
                    
                }
                
            }
            
            // MARK: FloatingPoint numbers
            context("FloatingPoint Numbers Parsing") {
                it("Should parse Double with length") {
                    let doubleBin: Binary = [0x71, 0x3d, 0x0a, 0xd7, 0xa3, 0x10, 0x45, 0x40] // => 42.13
                    do {
                        let parsedDouble: Double = try doubleBin.scanValue(start: 0, length: 8)
                        expect(parsedDouble).to(equal(42.13))
                    } catch {
                        fail("It should have parsed Double, but it failed.")
                    }
                }
                
                it("Should parse Double") {
                    let doubleBin: Binary = [0x71, 0x3d, 0x0a, 0xd7, 0xa3, 0x10, 0x45, 0x40] // => 42.13
                    do {
                        let parsedDouble: Double = try doubleBin.get(at: 0)
                        expect(parsedDouble).to(equal(42.13))
                    } catch {
                        fail("It should have parsed Double, but it failed.")
                    }
                }
                
                it("Should parse Float with length") {
                    let floatBin: Binary = [0x1F, 0x85, 0x28, 0x42] // => 42.13
                    do {
                        let parsedDouble: Float = try floatBin.scanValue(start: 0, length: 4)
                        expect(parsedDouble).to(equal(42.13))
                    } catch {
                        fail("It should have parsed Float, but it failed.")
                    }
                }
                
                it("Should parse Float") {
                    let floatBin: Binary = [0x1F, 0x85, 0x28, 0x42] // => 42.13
                    do {
                        let parsedDouble: Float = try floatBin.get(at: 0)
                        expect(parsedDouble).to(equal(42.13))
                    } catch {
                        fail("It should have parsed Float, but it failed.")
                    }
                }
            }
            
            // MARK: - Strings
            context("String Parsing") {
                let binString1: Binary = [0x43, 0x61, 0x79, 0x6E, 0x61, 0x6E, 0x00] // => "Caynan"
                let binString2: Binary = [0x48, 0x6F, 0x72, 0x75, 0x73] // => "Horus"
                
                it("Should parse string with given length") {
                    do {
                        let parsedString = try binString2.get(offset: 0, length: 5)
                        expect(parsedString).to(equal("Horus"))
                    } catch {
                        fail("It should have parsed String with offset, but it failed")
                    }
                }
                
                it("Should parse Nul terminated string") {
                    do {
                        let parsedString = try binString1.get(offset: 0)
                        expect(parsedString).to(equal("Caynan"))
                    } catch {
                        fail("It should have parsed nul terminated string, but it failed")
                    }
                }
            }
        }
    }
    
}

