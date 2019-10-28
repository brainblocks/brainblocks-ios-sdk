//
//  String+Extension.swift
//  Alamofire
//
//  Created by Ty Schenk on 10/28/19.
//

import Foundation

public extension String {
    /**
     Check if address is a valid nano address.
     
     - Returns: Bool
     */
    func validAddress() -> Bool {
        // support xrb and nano address
        if self.range(of: "((?:xrb_[13][a-km-zA-HJ-NP-Z0-9]{59})|(?:nano_[13][a-km-zA-HJ-NP-Z0-9]{59}))", options: .regularExpression) != nil {
            // valid Nano Address
            return true
        } else {
            // not valid Nano Address
            return false
        }
    }
}
