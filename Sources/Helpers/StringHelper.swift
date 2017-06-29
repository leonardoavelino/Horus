//
//  StringHelper.swift
//  Horus
//
//  Created by Caynan Sousa on 6/29/17.
//  Copyright © 2017 Caynan. All rights reserved.
//

import Foundation

extension String {
    /// Check the if string is a valid hexadecimal.
    ///
    /// - Returns: `true` if string is a valid hexadecimal; false otherwise.
    func isHexadecimal() -> Bool {
        let hexaRegex = "[0-9A-F]+"
        let hexaTest = NSPredicate(format: "SELF MATCHES %@", hexaRegex)

        return hexaTest.evaluate(with: self)
    }
}
