//
//  VerifyObject.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 5/2/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation

//{
//    "token": "ZXlKaGJHY...",
//    "destination": "xrb_164xa...",
//    "currency": "rai",
//    "amount": "1000",
//    "amount_rai": 1000,
//    "received_rai": 1000,
//    "fulfilled": true,
//    "send_block": "0B36663...",
//    "sender": "xrb_1jnat..."
//}

public struct VerifyObject {
    let token: String
    let destination: String
    let currency: String
    let amount: String
    let fulfilled: Bool
    let sender: String
    let amountRai: String
    let receivedRai: String
    let sendBlock: String
}

extension VerifyObject {
    struct Key {
        static let token: String = "token"
        static let destination: String = "destination"
        static let currency: String = "currency"
        static let amount: String = "amount"
        static let fulfilled: String = "fulfilled"
        static let sender: String = "sender"
        static let amountRai: String = "amount_rai"
        static let receivedRai: String = "received_rai"
        static let sendBlock: String = "send_block"
    }
    
    init?(json: [String : AnyObject]) {
        
        if let token = json[Key.token] as? String,
            let destination = json[Key.destination] as? String,
            let currency = json[Key.currency] as? String,
            let amount = json[Key.amount] as? String,
            let fulfilled = json[Key.fulfilled] as? Bool,
            let sender = json[Key.sender] as? String,
            let amountRai = json[Key.amountRai] as? String,
            let receivedRai = json[Key.receivedRai] as? String,
            let sendBlock = json[Key.sendBlock] as? String {
            
            self.token = token
            self.destination = destination
            self.currency = currency
            self.amount = amount
            self.fulfilled = fulfilled
            self.sender = sender
            self.amountRai = amountRai
            self.receivedRai = receivedRai
            self.sendBlock = sendBlock
        } else {
            self.token = "unknown"
            self.destination = "unknown"
            self.currency = "unknown"
            self.amount = "unknown"
            self.fulfilled = false
            self.sender = "unknown"
            self.amountRai = "unknown"
            self.receivedRai = "unknown"
            self.sendBlock = "unknown"
        }
    }
}
