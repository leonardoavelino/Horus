//: Playground - noun: a place where people can play
import Horus

// Working with Integers.
let bin: Binary = [0xFF, 0x00, 0x01, 0x02]
let i: Int16 = try bin.scanValue(start: 0, length: 2)
let i2: Int16 = try bin.get(at: 0)

// Working with Float point numbers.
let floatBin: Binary = [0x71, 0x3d, 0x0a, 0xd7, 0xa3, 0x10, 0x45, 0x40]
let f: Double = try floatBin.get(at: 0)

// Rolling with Strings.
let binStr: Binary = [0x48, 0x6F, 0x72, 0x75, 0x73, 0x00] // => "Horus\0"

try binStr.get(offset: 0, length: 5)
try binStr.get(offset: 1)