//
//  BrainBlocksPayment.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 1/16/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import QRCode
import NotificationCenter

public class BrainBlocksPayment: UIViewController {
    
    static let sessionURL = "https://brainblocks.io/api/session"
    static var afManager : SessionManager!
    
    // payment session amount
    static var paymentAmount = 0
    static var sessionTime = 300
    
    // where payment will be sent after verify
    static var paymentdestination = ""
    
    // temp payment session tokens
    static var token: String = ""
    
    // temp account for payment
    static var account: String = ""
    var strongSelf: BrainBlocksPayment?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        //Retaining itself strongly so can exist without strong refrence
        strongSelf = self
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // launch payment UI
    open func launchBrainBlocksPaymentView(viewController contentview: UIViewController!, paymentCurrency currency: Currencies, paymentDestination destination: String, paymentAmount amount: Double, sessionTime time: Int, paymentMode mode: PaymentViewController.PaymentMode, backgroundStyle blur: UIBlurEffectStyle) {
        
        // Check for Internet
        if !Connectivity.isConnectedToInternet {
            print("No Connection")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrainBlocksSessionStartFailed"), object: nil)
            return
        }
        
        // apply style
        PaymentViewController.blurStyle = blur
        PaymentViewController.mode = mode
        
        // set vars
        var processedAddress: String = ""
        var convertAmount: Int = 0
        
        // process address
        processAddress(url: destination, completionHandler: { (address, amount) in
            processedAddress = address
        })

        // convert currency to rai
        convertToNano(currency: currency, amount: amount, completionHandler: { (value) in
            convertAmount = value
            
            // after convertAmount is pulled. finish function
            if processedAddress.validAddress() == false {
                print("Can not launch BrainBlocks Payment. Invalid Destination Address.")
                return
            }
            
            if amount == 0 {
                print("Can not launch BrainBlocks Payment. Missing Amount")
                return
            }
            
            BrainBlocksPayment.paymentdestination = destination
            BrainBlocksPayment.paymentAmount = convertAmount
            BrainBlocksPayment.sessionTime = time
            self.brainBlocksStartSession(paymentAmount: convertAmount, paymentDestination: processedAddress)
            
            let paymentViewController = PaymentViewController.instantiate()
            paymentViewController.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
            paymentViewController.modalPresentationStyle = .overCurrentContext
            
            contentview.present(paymentViewController, animated: true, completion: nil)
        })
    }
    
    // start brainblocks payment session
    func brainBlocksStartSession(paymentAmount amount: Int, paymentDestination destination: String) {

        // Check for Internet
        if !Connectivity.isConnectedToInternet {
            print("No Connection")
            return
        }
        
        if destination.validAddress() == false {
            print("Can not launch BrainBlocks Payment Session. Invalid Destination Address.")
            return
        }
        
        if amount == 0 {
            print("Can not launch BrainBlocks Payment. Missing Amount")
            return
        }
        
        // To check if a sessionTime is between 120-300 seconds
        if BrainBlocksPayment.sessionTime < 120 || BrainBlocksPayment.sessionTime > 300 {
            BrainBlocksPayment.sessionTime = 300
        }
        
        BrainBlocksPayment.paymentAmount = amount
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let params: [String : String] = [
            "amount": "\(amount)",
            "destination": "\(destination)",
            "time" : "\(BrainBlocksPayment.sessionTime)"
        ]
        
        Alamofire.request(BrainBlocksPayment.sessionURL, method: .post, parameters: params, headers: headers).responseJSON { response in
            if let tokenJSON = response.result.value as? [String : AnyObject]! {
                
                // make sure tokenJSON is there
                guard let tokenJSON = tokenJSON else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrainBlocksSessionStartFailed"), object: nil)
                    return
                }
                
                // make sure we can pull the status
                guard let status = tokenJSON["status"] as? String else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrainBlocksSessionStartFailed"), object: nil)
                    return
                }
                
                switch status {
                case "success":
                    BrainBlocksPayment.account = tokenJSON["account"] as! String
                    BrainBlocksPayment.token = tokenJSON["token"] as! String
                    // set current token for future usage
                    print("BrainBlocks Session Started")
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrainBlocksSessionStart"), object: nil)
                    self.brainBlocksTransferPayment(token: BrainBlocksPayment.token)
                default:
                    print("BrainBlocks Session Error")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrainBlocksSessionStartFailed"), object: nil)
                    return
                }
            }
        }
    }
    
    // start brainblocks transfer session for payment
    func brainBlocksTransferPayment(token: String) {
    
        // Check for Internet
        if !Connectivity.isConnectedToInternet {
            print("No Connection")
            return
        }
        
        // setup config time for transfer
        let configTime = (BrainBlocksPayment.sessionTime + 15)
        
        // config alamofire session to prevent transfer timeouts
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(configTime)
        configuration.timeoutIntervalForResource = TimeInterval(configTime)
        BrainBlocksPayment.afManager = Alamofire.SessionManager(configuration: configuration)
        
        BrainBlocksPayment.afManager.request("\(BrainBlocksPayment.sessionURL)/\(token)/transfer", method: .post).responseJSON { response in
            if let resultJSON = response.result.value as? [String : AnyObject]! {
                
                // make sure resultJSON is there
                guard let resultJSON = resultJSON else {
                    return
                }
                
                // make sure we can pull the status
                guard let status = resultJSON["status"] as? String else {
                    return
                }
                
                switch status {
                case "success":
                    print("BrainBlocks Transfer Success")
                    // call brainblocks verify payment
                    self.brainBlocksVerifyPayment(token: token)
                default:
                    print("BrainBlocks Transfer Error")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrainBlocksPaymentFailed"), object: nil)
                }
            }
        }
    }
    
    func brainBlocksVerifyPayment(token: String) {
        // Check for Internet
        if !Connectivity.isConnectedToInternet {
            print("No Connection")
            return
        }
        
        Alamofire.request("\(BrainBlocksPayment.sessionURL)/\(token)/verify", method: .get).responseJSON { response in
            if let resultJSON = response.result.value as? [String : AnyObject]! {
                
                // make sure resultJSON is there
                guard let resultJSON = resultJSON else {
                    // post payment failed and break out of function
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrainBlocksPaymentFailed"), object: nil)
                    return
                }
                
                // pull token from resultJSON if we can
                guard let token = resultJSON["token"] as? String else {
                    // post payment failed and break out of function
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrainBlocksPaymentFailed"), object: nil)
                    return
                }
                
                // pull fulfilled value if we can
                guard let fulfilled = resultJSON["fulfilled"] as? Bool else {
                    // post payment failed and break out of function
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrainBlocksPaymentFailed"), object: nil)
                    return
                }
                
                // make sure token and received amounts are correct
                if token == token && fulfilled {
                    // announce payment success
                    print("BrainBlocks Payment Success")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrainBlocksPaymentSuccess"), object: nil)
                } else {
                    // announce insufficient payment
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrainBlocksInsufficientPayment"), object: nil)
                    print("BrainBlocks Payment Error")
                }
            }
        }
    }
    
    func cancelBrainBlocksPaymentSession() {
        // if token is not empty, cancel all networking tasks in afManager
        if BrainBlocksPayment.token != "" {
            BrainBlocksPayment.afManager.session.getAllTasks { task in
                task.forEach { $0.cancel() }
            }
        }
    }
}
