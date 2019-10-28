//
//  VerifyObject.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 5/2/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import SwiftyJSON

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

public struct BBVerificationObject {
	let token: String
	let destination: String
	let currency: String
    let amount: Int
    let amountRai: Int
    let receivedRai: Int
	let fulfilled: Bool
    let sendBlock: String
	let sender: String
}

public func parseVerificationObject(_ json: JSON) -> BBVerificationObject {
    let token = json["token"].stringValue
    let destination = json["destination"].stringValue
    let currency = json["currency"].stringValue
    let amount = json["amount"].intValue
    let amountRai = json["amount_rai"].intValue
    let receivedRai = json["received_rai"].intValue
    let fulfilled = json["fulfilled"].boolValue
    let sendBlock = json["send_block"].stringValue
    let sender = json["sender"].stringValue
    
    return BBVerificationObject(token: token, destination: destination, currency: currency, amount: amount, amountRai: amountRai, receivedRai: receivedRai, fulfilled: fulfilled, sendBlock: sendBlock, sender: sender)
}
