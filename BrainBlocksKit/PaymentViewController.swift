//
//  PaymentViewController.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 1/17/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import UIKit
import QRCode
import WebKit

public class PaymentViewController: UIViewController {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var copyAddress: UIView!
    @IBOutlet weak var paymentUI: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var raiblocksButton: UIButton!
    @IBOutlet weak var QRButton: UIButton!
    
    var style = UIApplication.shared.statusBarStyle
    let brainBlocksManager = BrainBlocksPayment()
    var countdownTimer: Timer!
    var totalTime = BrainBlocksPayment.sessionTime
    var progressValue: Float = 1.0
    var qrSet: Bool = false
    var qrURL = ""
    
    var amount: Double {
        return Double(round(Double(BrainBlocksPayment.paymentAmount)) / 1000000)
    }
    
    public override func viewDidLoad() {
        // listen for BrainBlocksSessionStart notification
        NotificationCenter.default.addObserver(self, selector: #selector(startTimer), name: NSNotification.Name(rawValue: "BrainBlocksSessionStart"), object: nil)
        
        // listen for BrainBlocksPaymentSuccess notification
        NotificationCenter.default.addObserver(self, selector: #selector(paymentSuccess), name: NSNotification.Name(rawValue: "BrainBlocksPaymentSuccess"), object: nil)
        
        // listen for BrainBlocksPaymentFailed notification
        NotificationCenter.default.addObserver(self, selector: #selector(dismissPaymentView), name: NSNotification.Name(rawValue: "BrainBlocksPaymentFailed"), object: nil)
        
        // listen for BrainBlocksSessionStartFailed notification
        NotificationCenter.default.addObserver(self, selector: #selector(dismissPaymentView), name: NSNotification.Name(rawValue: "BrainBlocksSessionStartFailed"), object: nil)
        
        // Pull framework bundle
        let podBundle = Bundle(for: PaymentViewController.self)
        let bundleURL = podBundle.url(forResource: "BrainBlocksKit", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)
        
        // Remove background color
        mainView.backgroundColor = UIColor.clear
        
        // Add blur background
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(paymentUI)
        view.addSubview(copyAddress)
        
        //Pay 0.001 XRB
        amountLabel.text = "Pay \(amount)"
        paymentUI.layer.cornerRadius = 10.0
        paymentUI.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 10.0
        cancelButton.layer.masksToBounds = true
        raiblocksButton.setImage(UIImage(named: "Nano.png", in: bundle, compatibleWith: nil), for: .normal)
        accountLabel.isHidden = true
        progressBar.progress = progressValue
        timerLabel.isHidden = true
        progressBar.isHidden = true
        cancelButton.isHidden = true
        copyAddress.isHidden = true
        copyAddress.alpha = 0.0
        indicator.startAnimating()
        indicator.isHidden = false
        
        mainView.alpha = 0.0
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.mainView.alpha = 1.0
        }, completion: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        style = UIApplication.shared.statusBarStyle
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = style
    }
    
    // MARK: Start Timer
    @objc func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        
        let when = DispatchTime.now() + 0.1 // wait for countdown to start
        DispatchQueue.main.asyncAfter(deadline: when) {
            // set qr code
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            
            // setup qrURL
            self.qrURL = "xrb:\(BrainBlocksPayment.account)"
            let qrCode = QRCode(self.qrURL)
            self.QRButton.setImage(qrCode?.image, for: .normal)
            
            // setup everything else
            self.accountLabel.text = BrainBlocksPayment.account
            self.accountLabel.isHidden = false
            self.qrSet = true
            self.totalTime = BrainBlocksPayment.sessionTime
            self.timerLabel.text = "\(self.totalTime.secondsToMinutes()) remaining"
            self.timerLabel.isHidden = false
            self.progressBar.isHidden = false
            self.cancelButton.isHidden = false
        }
    }
    
    // MARK: Update Timer
    // update timmer label and progress bar
    @objc func updateTime() {
        if totalTime != 0 {
            totalTime -= 1
            progressValue = progressValue - calcTimerIndicatorDecimal()
        } else {
            endTimer()
            brainBlocksManager.cancelBrainBlocksPaymentSession()
            dismissPaymentView()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrainBlocksSessionTimeOut"), object: nil)
        }
        
        timerLabel.text = "\(self.totalTime.secondsToMinutes()) remaining"
        progressBar.progress = progressValue
    }
    
    // MARK: End Timer
    // end timer and reset back to start for next payment
    func endTimer() {
        cancelButton.isHidden = true
        timerLabel.isHidden = true
        progressBar.isHidden = true
        accountLabel.text = ""
        accountLabel.text = ""
        QRButton.setImage(UIImage(), for: .normal)
        indicator.stopAnimating()
        progressValue = 1.0
        qrSet = false
        countdownTimer.invalidate()
    }
    
    // MARK: Copy QR Code
    @IBAction func copyQRCode(_ sender: UIButton) {
        // copy address to clipboard
        UIPasteboard.general.string = BrainBlocksPayment.account
        
        // show copy address with fade in
        copyAddress.isHidden = false
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.copyAddress.alpha = 1.0
        }, completion: nil)
        
        // wait 3.5 seconds then hide again
        let when = DispatchTime.now() + 3.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            // hide copy view
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.copyAddress.alpha = 0.0
            }, completion:  {
                (value: Bool) in
                self.copyAddress.isHidden = true
            })
        }
    }
    
    
    // cancel payment and reset everything for another session
    @IBAction func cancelPayment() {
        cancelButton.isHidden = true
        timerLabel.isHidden = true
        progressBar.isHidden = true
        accountLabel.text = ""
        accountLabel.text = ""
        QRButton.setImage(UIImage(), for: .normal)
        indicator.stopAnimating()
        progressValue = 1.0
        qrSet = false
        countdownTimer.invalidate()
        
        // Cancel payment and dismiss view
        brainBlocksManager.cancelBrainBlocksPaymentSession()
        dismissPaymentView()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrainBlocksSessionCancelled"), object: nil)
    }
    
    @IBAction func actionButton(_ sender: UIButton) {
        let url = URL(string: "https://nano.org")
        
        let alert = UIAlertController(title: "Visit Nano.org", message: "Are you sure you want to leave this app?", preferredStyle: .alert)
        
        let goAction = UIAlertAction(title: "Yes", style: .default) { (alert: UIAlertAction!) -> Void in
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) -> Void in
            return
        }
        
        alert.addAction(goAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion:nil)
    }
    
    @objc func dismissPaymentView() {
        // dismiss main view
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.mainView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.mainView.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished) {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @objc func paymentSuccess() {
        endTimer()
        dismissPaymentView()
    }
    
    static func instantiate() -> PaymentViewController {
        // Pull framework bundle
        let podBundle = Bundle(for: PaymentViewController.self)
        let bundleURL = podBundle.url(forResource: "BrainBlocksKit", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)
        
        let storyboard = UIStoryboard(name: "Payment", bundle: bundle)
        return storyboard.instantiateInitialViewController() as! PaymentViewController
    }
}
