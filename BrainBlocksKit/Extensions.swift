//
//  Extensions.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 1/17/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation
import Alamofire

public extension String {
    /**
     Check if address is a valid nano address.
     
     - Returns: Bool
     */
    public func validAddress() -> Bool {
        if self.range(of: "/((?:xrb_[13][a-km-zA-HJ-NP-Z0-9]{59})|(?:nano_[13][a-km-zA-HJ-NP-Z0-9]{59}))/", options: .regularExpression) != nil {
            // Valid Nano Address
            return true
        } else {
            // Not Valid Nano Address
            return false
        }
    }
}

/**
 Calculates subtract amount for timer indicator
 */
func calcTimerIndicatorDecimal() -> Float {
    var decimalString = String(format: "%g", 100.0/Double(BrainBlocksPayment.sessionTime))
    decimalString = decimalString.replacingOccurrences(of: "0.", with: "")
    let floatNumber = Float("0.00\(decimalString)")!
    decimalString = String(format: "%g", floatNumber)
    let time = Float(decimalString)!
    
    return time
}

/**
 Calculates seconds Int To Minutes and returns as String
 */
public extension Int {
    func secondsToMinutes() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        
        let formattedString = formatter.string(from: TimeInterval(self))!
        return formattedString
    }
}

/**
 Pulls address out of Nano url or QR Code
*/
func processAddress(url: String, completionHandler: @escaping (String, String) -> ()) {
    var address: String = url
    var amount: String = ""
    
    // strip after &
    if let urlRange = address.range(of:"&") {
        address.removeSubrange(urlRange.lowerBound..<address.endIndex)
    }
    
    // check to see if amount is in address url
    if url.lowercased().range(of:"?amount=") == nil {
        // strip after ?
        if let urlRange = address.range(of:"?") {
            address.removeSubrange(urlRange.lowerBound..<address.endIndex)
        }
    }
    
    // pull amount value after ?amount=
    if let range = address.range(of: "?amount=") {
        let rangeAmount = address[range.upperBound...].trimmingCharacters(in: .whitespaces)
        amount = rangeAmount
        print(amount)
    }
    
    // strip leftover after?
    if let urlRange = address.range(of:"?") {
        address.removeSubrange(urlRange.lowerBound..<address.endIndex)
    }
    
    // remove prefix xrb:
    address = address.replacingOccurrences(of: "xrb:", with: "")
    
    // check if processed address is valid
    if address.validAddress() {
        completionHandler(address, amount)
    } else {
        completionHandler("", "0")
        print("Address processing error")
    }
}

// MARK: Check Network
class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
