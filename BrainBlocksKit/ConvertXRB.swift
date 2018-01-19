//
//  ConvertXRB.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 1/18/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation

enum Currencies: String {
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
}

//[
//    {
//        "id": "raiblocks",
//        "name": "RaiBlocks",
//        "symbol": "XRB",
//        "rank": "20",
//        "price_usd": "17.5338",
//        "price_btc": "0.00152916",
//        "24h_volume_usd": "20950700.0",
//        "market_cap_usd": "2336348854.0",
//        "available_supply": "133248289.0",
//        "total_supply": "133248289.0",
//        "max_supply": "133248290.0",
//        "percent_change_1h": "-2.5",
//        "percent_change_24h": "-0.8",
//        "percent_change_7d": "-30.13",
//        "last_updated": "1516328052",
//        "price_eur": "14.3239223016",
//        "24h_volume_eur": "17115297.2524",
//        "market_cap_eur": "1908638142.0"
//    }
//]

func currentPrice(currency: Currencies) {
    
    
    //https://api.coinmarketcap.com/v1/ticker/raiblocks/?convert=EUR
}
