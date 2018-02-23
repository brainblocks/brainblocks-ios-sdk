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
    Check if address is a valid XRB address.

    - Returns: Bool
    */
    public func validAddress() -> Bool {
        if self.range(of: "^xrb_[a-z0-9]{60}$", options: .regularExpression) != nil {
            // Valid Raiblocks Address
            return true
        } else {
            // Not Valid Raiblocks Address
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
 Pulls address out of RaiBlocks url or QR Code
*/
func processAddress(url: String, completionHandler: @escaping (String) -> ()) {
    var address: String = url
    
    // strip after ?
    if let urlRange = address.range(of:"?") {
        address.removeSubrange(urlRange.lowerBound..<address.endIndex)
    }
    
    address = address.replacingOccurrences(of: "xrb:", with: "")
    
    if address.validAddress() {
        completionHandler(address)
    } else {
        completionHandler("")
        print("Address processing error")
    }
}

// MARK: Check Network
class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
