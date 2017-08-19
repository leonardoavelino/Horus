//
//  Data.swift
//  Horus
//
//  Created by Caynan Sousa on 8/18/17.
//  Copyright © 2017 Caynan. All rights reserved.
//

import Foundation

extension Data {
    public func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
