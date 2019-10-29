//
//  BBPaymentController.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 1/17/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import UIKit

final public class BBPaymentController: UIViewController, BBInternalDelegate {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var copyAddress: UIView!
    @IBOutlet weak var paymentUI: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var openWalletButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var QRButton: UIButton!
	@IBOutlet weak var nanoLogo: UIImageView!
    @IBOutlet weak var logoView: UIView!
    
	internal var brainBlocksManager: BrainBlocksAPI = BrainBlocksAPI()
	
	public var delegate: BrainBlocksDelegate!
	public var destinationAddress: String = ""
    public var paymentAmount: Double = 0
    public var currency: Currencies = .nano
    public var blurStyle: UIBlurEffect.Style = .regular
	internal var countdownTimer: Timer!
    internal var progressValue: Float = 1.0
	internal var qrSet: Bool = false
    internal var qrURL = ""
    internal var walletURL = ""
	internal var paymentAccount: String = ""
	internal var token: String = ""
    internal var sessionStart: Date = Date()
    internal var sessionEnd: Date = Date().adding(minutes: sessionLengthMinutes)
    internal var handoff: Bool = false
    
    internal var fancyNanoAmount: Double {
		return Double(round(Double(self.paymentAmount)) / 1000000)
    }
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		self.brainBlocksManager.internalDelegate = self
		
        // Add blur background
        self.setBackgroundBlur()
        
        // Setup Pay View
        self.setPayUI()
        
        // render payment view corners
        self.roundCorners()
		
        // start indicator and hide everything until payment session starts
        self.startLoader()
        
        // animate the payment view
        self.addAnimateView()
        
        // start payment session
        self.startSession()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        if qrSet {
            handoff = true
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        if handoff && qrSet {
            self.brainBlocksManager.transferPayment(token: self.token)
        }
    }
	
	override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func startSession() {
        if self.currency == .nano {
            self.brainBlocksManager.startSession(paymentAmount: Int(self.paymentAmount), paymentDestination: self.destinationAddress)
        } else {
            self.brainBlocksManager.convertToNano(currency: self.currency, amount: self.paymentAmount) { (payValue) in
                if let payValue = payValue {
                    self.brainBlocksManager.startSession(paymentAmount: payValue, paymentDestination: self.destinationAddress)
                }
            }
        }
    }
    
    func addAnimateView() {
        mainView.alpha = 0.0
        UIView.animate(withDuration: 0.8, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.mainView.alpha = 1.0
        }, completion: nil)
    }
    
    func setPayUI() {
        // Pull framework bundle
        let kitBundle = Bundle(for: BBPaymentController.self)
        let bundleURL = kitBundle.url(forResource: "BrainBlocksKit", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)
        // set payment view nano logo
        nanoLogo.image = UIImage(named: "Nano.png", in: bundle, compatibleWith: nil)
        accountLabel.textColor = .black
        timerLabel.textColor = .black
    }
    
    func setBackgroundBlur() {
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        let blurEffect = UIBlurEffect(style: self.blurStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(paymentUI)
        view.addSubview(copyAddress)
    }
    
    func startLoader() {
        indicator.startAnimating()
        indicator.isHidden = false
        accountLabel.isHidden = true
        progressBar.progress = progressValue
        timerLabel.isHidden = true
        progressBar.isHidden = true
        cancelButton.isHidden = true
        copyAddress.isHidden = true
        copyAddress.alpha = 0.0
    }
    
    func roundCorners() {
        copyAddress.layer.cornerRadius = 10
        copyAddress.layer.masksToBounds = true
        paymentUI.layer.cornerRadius = 10.0
        paymentUI.layer.masksToBounds = true
        openWalletButton.layer.cornerRadius = 10.0
        openWalletButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 10.0
        cancelButton.layer.masksToBounds = true
    }
    
    func updatePayText() {
        // set pay text
        self.amountLabel.text = "Pay \(fancyNanoAmount) NANO"
    }

    // update timmer label and progress bar
	@objc func updateTime() {
        let elapsedTime = Int(Date().timeIntervalSince(sessionStart))
        let timeRemaining = (sessionTime - elapsedTime)
        
        if elapsedTime < sessionTime {
            self.brainBlocksManager.currentTime = elapsedTime
            progressValue = progressValue - calcTimerIndicatorDecimal(elapsedTime: timeRemaining)
        } else {
            self.endTimer()
            self.dismissPaymentView()
        }
        
        timerLabel.text = "\(timeRemaining.secondsToMinutes()) remaining"
        progressBar.progress = progressValue
    }
	
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
        handoff = false
        countdownTimer.invalidate()
    }
    
    // Copy QR Code
    @IBAction func copyQRCode(_ sender: UIButton) {
        // copy address to clipboard
        UIPasteboard.general.string = paymentAccount
        
        // show copy address with fade in
        copyAddress.isHidden = false
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.copyAddress.alpha = 1.0
        }, completion: nil)
        
        // wait 3.5 seconds then hide again
        let when = DispatchTime.now() + 3.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            // hide copy view
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.copyAddress.alpha = 0.0
            }, completion:  {
                (value: Bool) in
                self.copyAddress.isHidden = true
            })
        }
    }
    
    @IBAction func openWallet(_ sender: UIButton) {
        if let url = URL(string: walletURL) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    // cancel payment and reset everything for another session
    @IBAction func cancelPayment() {
        self.endTimer()
        self.dismissPaymentView()
    }
    
	func dismissPaymentView() {
        // cancel timer
        self.endTimer()
        // dismiss main view
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.mainView.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished) {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
	
	func paymentSessionUpdate(status: BBResponses, data: BBSessionObject?) {
		// pass delegate onto client
        self.delegate.paymentSessionUpdate(status: status, data: data)
		
        // handle delegate internally
		switch status {
		case .sessionStart:
            guard let data = data else { return }
			guard let paymentAmount = data.paymentAmount else { return }
			guard let acccount = data.acccount else { return }
			guard let token = data.paymentToken else { return }
        
			countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
	
			// set qr code
			self.indicator.stopAnimating()
			self.indicator.isHidden = true
	
			// build qrURL and walletUrl
			let rawAmount: String = ("\(paymentAmount)000000000000000000000000")
			self.qrURL = "nano:\(acccount)?amount=\(rawAmount)"
            self.walletURL = "nano://\(acccount)?amount=\(rawAmount)"
            
            // generate qr code image
            guard var qrCode = QRCode(self.qrURL) else {
                self.delegate.paymentSessionUpdate(status: .paymentSessionFailed, data: nil)
                self.dismissPaymentView()
                return
            }
            qrCode.backgroundColor = CIColor(red: 236, green: 236, blue: 236)
            self.QRButton.backgroundColor = UIColor.clear
            self.QRButton.setImage(qrCode.image!, for: .normal)
	
			// setup everything else
			self.token = token
			self.accountLabel.text = data.acccount
			self.accountLabel.isHidden = false
			self.qrSet = true
			self.timerLabel.text = "\(sessionTime.secondsToMinutes()) remaining"
			self.timerLabel.isHidden = false
			self.progressBar.isHidden = false
			self.cancelButton.isHidden = false
            self.paymentAmount = Double(paymentAmount)
            self.updatePayText()
        default:
            self.dismissPaymentView()
		}
	}
    
    func paymentComplete(object: BBVerificationObject) {
        self.delegate.paymentComplete(object: object)
        self.dismissPaymentView()
    }
	
	public static func create() -> BBPaymentController {
		// Pull framework bundle
		let kitBundle = Bundle(for: BBPaymentController.self)
		let bundleURL = kitBundle.url(forResource: "BrainBlocksKit", withExtension: "bundle")
		let bundle = Bundle(url: bundleURL!)

		let storyboard = UIStoryboard(name: "Payment", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! BBPaymentController
		
		return controller
	}
}
