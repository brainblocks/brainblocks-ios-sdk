//
//  BrainBlocksDelegate.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 4/19/19.
//  Copyright © 2019 BrainBlocks. All rights reserved.
//

import Foundation

public struct BBSessionObject {
	let acccount: String?
	let paymentAmount: Int?
	let paymentToken: String?
	let missingAmount: Int?
}

public enum BBResponses: String {
	case noConnection = "No Internet Connection"
	case sessionStart = "Session Started"
	case paymentSessionFailed = "Payment Session Failed"
	case insufficientPayment = "Insufficient Payment"
}

public protocol BrainBlocksDelegate: class {
    func paymentSessionUpdate(status: BBResponses, data: BBSessionObject?)
    func paymentComplete(object: BBVerificationObject)
}

internal protocol BBInternalDelegate: class {
	func paymentSessionUpdate(status: BBResponses, data: BBSessionObject?)
    func paymentComplete(object: BBVerificationObject)
}
