//
//  ConvertNano.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 1/18/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation
import Alamofire

public extension BrainBlocksPayment {
    
    /**
     Enum of supported Currencies in BrainBlocks
    */
    public enum Currencies: String {
        case aud = "aud"
        case brl = "brl"
        case cad = "cad"
        case chf = "chf"
        case clp = "clp"
        case cny = "cny"
        case czk = "czk"
        case dkk = "dkk"
        case eur = "eur"
        case gbp = "gbp"
        case hkd = "hkd"
        case huf = "hur"
        case idr = "idr"
        case ils = "ils"
        case inr = "inr"
        case jpy = "jpy"
        case krw = "krw"
        case mxn = "mxn"
        case myr = "myr"
        case nok = "nok"
        case nzd = "nzd"
        case php = "php"
        case pkr = "pkr"
        case pln = "pln"
        case rub = "rub"
        case sek = "sek"
        case sgd = "sgd"
        case thb = "thb"
        case TRY = "try"
        case usd = "usd"
        case twd = "twd"
        case zar = "zar"
        case nano = "nano"
    }
    
    /**
     Converts supplied with nano
     
     - Parameters:
     - Currency: Currency you are providing
     - Amount: Amount of currency provided
     
     - Returns: Int nano amount
     */
    func convertToNano(currency: Currencies, amount: Double, completionHandler: @escaping (Int) -> ()) {
        var nano = Int()
        
        // if nano - calc local instead and avoid network request
        if currency == .nano {
            nano = Int((amount * 1000000))
            completionHandler(nano)
            return
        }
        
        let url = "https://brainblocks.io/api/exchange/\(currency.rawValue)/\(amount)/rai"
        
        Alamofire.request(url, method: .get).responseJSON { response in
            if let resultJSON = response.result.value as? [String : AnyObject]? {
                
                // pull token from result json
                guard let resultJSON = resultJSON else {
                    completionHandler(0)
                    return
                }
                
                guard let nano = resultJSON["rai"] as? Int else {
                    completionHandler(0)
                    return
                }
                
                completionHandler(nano)
            } else {
                completionHandler(0)
            }
        }
    }
}

