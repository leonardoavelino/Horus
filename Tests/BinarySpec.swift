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
        }
        
    }
    
}

