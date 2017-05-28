//
//  BinaryError.swift
//  Horus
//
//  Created by Caynan Sousa on 5/28/17.
//  Copyright © 2017 Caynan. All rights reserved.
//

import Foundation

enum BinaryError: Error {
    case outOfBounds
    case nonNulTerminatedString
    case failedConversion
}
