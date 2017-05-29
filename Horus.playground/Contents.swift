//: Playground - noun: a place where people can play
import Horus

// Working with Integers.
let bin: Binary = [0xFF, 0x00, 0x01, 0x02]
let i: Int16 = try bin.scanValue(start: 0, length: 2)
let i2: Int16 = try bin.get(at: 0)

// Working with Float point numbers.
let doubleBin: Binary = [0xc9, 0xe5, 0x3f, 0xa4, 0xdf, 0xbe, 0x05, 0x40]
let e: Double = try doubleBin.get(at: 0)

let floatBin: Binary = [0xd0, 0x0f, 0x49, 0x40]
let pi: Float = try floatBin.scanValue(start: 0, length: 4)

// Rolling with Strings.
let binStr: Binary = [0x48, 0x6F, 0x72, 0x75, 0x73, 0x00] // => "Horus\0"

try binStr.get(offset: 0, length: 5)
try binStr.get(offset: 1)