//
//  BrainBlocksAPI.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 1/16/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

final public class BrainBlocksAPI {
	// api endpoint
    fileprivate let sessionURL = "https://api.brainblocks.io/api/session"
    
    // payment session info
    var paymentAmount: Int = 0
    var currentTime: Int = 0
    var account: String = ""
	
    // payment session token
    var token: String = ""
	
	// delegate
	internal var internalDelegate: BBInternalDelegate!
	
	// retain itself without strong ref
	fileprivate var strongSelf: BrainBlocksAPI!
	
	public init() {
		// Retaining itself strongly so can exist without strong refrence
		strongSelf = self
	}

	required public init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    // start payment session
	func startSession(paymentAmount amount: Int, paymentDestination destination: String) {
        // Check for Internet
        if !Connectivity.isConnectedToInternet {
            print("No Internet Connection")
            self.internalDelegate.paymentSessionUpdate(status: .paymentSessionFailed, data: BBSessionObject(acccount: self.account, paymentAmount: self.paymentAmount, paymentToken: self.token, missingAmount: nil))
            return
        }
        
        if destination.validAddress() == false {
            print("Payment Failed. Invalid Destination Address.")
            self.internalDelegate.paymentSessionUpdate(status: .paymentSessionFailed, data: BBSessionObject(acccount: self.account, paymentAmount: self.paymentAmount, paymentToken: self.token, missingAmount: nil))
			return
        }
        
        if amount == 0 {
            print("Payment Failed. Missing Amount")
			self.internalDelegate.paymentSessionUpdate(status: .paymentSessionFailed, data: BBSessionObject(acccount: self.account, paymentAmount: self.paymentAmount, paymentToken: self.token, missingAmount: nil))
            return
        }

        let params: [String : String] = [
            "amount": "\(amount)",
            "destination": "\(destination)",
			"time" : "\(sessionTime)"
        ]
        
        AF.request(self.sessionURL, method: .post, parameters: params).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let reply = json["status"]
                if reply == "success" {
                    self.paymentAmount =  amount
                    self.token = json["token"].stringValue
                    self.account = json["account"].stringValue
                    
                    let statusObject = BBSessionObject(acccount: self.account, paymentAmount: amount, paymentToken: self.token, missingAmount: nil)
                    
                    self.internalDelegate.paymentSessionUpdate(status: .sessionStart, data: statusObject)
                    self.transferPayment(token: self.token)
                }
            default:
                self.internalDelegate.paymentSessionUpdate(status: .paymentSessionFailed, data: BBSessionObject(acccount: self.account, paymentAmount: self.paymentAmount, paymentToken: self.token, missingAmount: nil))
                return
            }
        }
    }

    // start transfer session for payment
	func transferPayment(token: String) {
        // Check for Internet
        if !Connectivity.isConnectedToInternet {
            print("No Internet Connection")
            return
        }
    
        AF.request("\(self.sessionURL)/\(token)/transfer", method: .post).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let reply = json["status"]
                
                if reply != "success" && self.currentTime < sessionTime {
                    self.transferPayment(token: self.token)
                } else {
                    self.verifyPayment(token: self.token)
                }
            default:
                if self.currentTime < sessionTime {
                    self.transferPayment(token: token)
                } else {
                    self.internalDelegate.paymentSessionUpdate(status: .paymentSessionFailed, data: BBSessionObject(acccount: self.account, paymentAmount: self.paymentAmount, paymentToken: self.token, missingAmount: nil))
                    return
                }
            }
        }
    }
	
    // verify if the payment is correct
	func verifyPayment(token: String) {
        // Check for Internet
        if !Connectivity.isConnectedToInternet {
            print("No Internet Connection")
            return
        }
        
        AF.request("\(sessionURL)/\(token)/verify", method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let verificationObject = parseVerificationObject(json)
                
                if verificationObject.token == self.token && verificationObject.fulfilled == true {
                    // announce payment success
                    self.internalDelegate.paymentComplete(object: verificationObject)
                } else {
                    // announce insufficient payment
                    let statusObject = BBSessionObject(acccount: self.account, paymentAmount: self.paymentAmount, paymentToken: self.token, missingAmount: (self.paymentAmount - verificationObject.receivedRai))
                    self.internalDelegate.paymentSessionUpdate(status: .insufficientPayment, data: statusObject)
                    print("Payment Error")
                }
            default:
                self.internalDelegate.paymentSessionUpdate(status: .paymentSessionFailed, data: BBSessionObject(acccount: self.account, paymentAmount: self.paymentAmount, paymentToken: self.token, missingAmount: nil))
                return
            }
        }
    }
    
    
    /**
     Converts supplied with nano
     
     - Parameters:
     - Token: BrainBlocks Token that you need to verify
     
     - Returns: Int nano amount
     */
	public func brainBlocksVerify(token: String, completionHandler: @escaping (BBVerificationObject?) -> ()) {
        // Check for Internet
        if !Connectivity.isConnectedToInternet {
            print("No Internet Connection")
            completionHandler(nil)
			return
        }
	
        AF.request("\(sessionURL)/\(token)/verify", method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let verificationObject = parseVerificationObject(json)
                completionHandler(verificationObject)
            default:
                completionHandler(nil)
                return
            }
        }
    }
	
	/**
	Converts supplied with nano
	
	- Parameters:
	- Currency: Currency you are providing
	- Amount: Amount of currency provided
	
	- Returns: Int nano amount
	*/
	public func convertToNano(currency: Currencies, amount: Double, completionHandler: @escaping (Int?) -> ()) {
		var nano = Int()
		
		// if nano - calc local instead and avoid network request
		if currency == .nano {
			nano = Int((amount * 1000000))
			completionHandler(nano)
			return
		}
		
		let url = "https://brainblocks.io/api/exchange/\(currency.rawValue)/\(amount)/rai"
		
        AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let nano = json["rai"].intValue
                completionHandler(nano)
            default:
                completionHandler(nil)
                return
            }
        }
	}
}
