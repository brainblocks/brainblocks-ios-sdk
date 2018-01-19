//
//  ConvertXRB.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 1/18/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation
import Alamofire

public enum Currencies: String {
    case AUD = "AUD"
    case BRL = "BRL"
    case CAD = "CAD"
    case CHF = "CHF"
    case LP = "LP"
    case CNY = "CNY"
    case CZK = "CZK"
    case DKK = "DKK"
    case EUR = "EUR"
    case GBP = "GBP"
    case HKD = "HKD"
    case HUF = "HUF"
    case IDR = "IDR"
    case ILS = "ILS"
    case INR = "INR"
    case JPY = "JPY"
    case KRW = "KRW"
    case MXN = "MXN"
    case MYR = "MYR"
    case NOK = "NOK"
    case NZD = "NZD"
    case PHP = "PHP"
    case PKR = "PKR"
    case PLN = "PLN"
    case RUB = "RUB"
    case SEK = "SEK"
    case SGD = "SGD"
    case THB = "THB"
    case TRY = "TRY"
    case TWD = "TWD"
    case ZAR = "ZAR"
    case XRB = "XRB"
}

// converts supplied currency with current
public func convertToRai(currency: Currencies, amount: Double) -> Int {
    var rai: Int = 0
    if currency == .XRB {
        rai = Int((amount * 1000.0))
        return rai
    }
    
    Alamofire.request("https://brainblocks.io/api/exchange/\(currency.rawValue)/\(amount)/rai", method: .get).responseJSON { response in
        if let resultJSON = response.result.value as? [String : AnyObject]! {
            // pull token from result json
            rai = resultJSON["rai"] as! Int
        }
    }
    
    return rai
}
