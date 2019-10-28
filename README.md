# BrainBlocks iOS SDK
iOS SDK for integrating [BrainBlocks](http://BrainBlocks.io) into a mobile app

[SDK Video Demo](https://www.youtube.com/watch?v=LlhImlhOeyQ)

![demo](./img/demo.png)


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```
> CocoaPods 1.4+ is required to build BrainBlocksKit.

To integrate BrainBlocks into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

target '<Your Target Name>' do
  pod 'BrainBlocksKit'
end
```

Then, run the following command:

```bash
$ pod install
```

## Usage

In the ViewController that you would like to use BrainBlocks, import BrainBlockKit and implement code like the following.

```swift
import UIKit
import BrainBlocksKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        showPayment()
    }
    
    // Example Function
    func showPayment() {
    
        // payment nano amount. nano = 1 NANO/1000000
        var amount: Double = 1
        
        // payment view
        let style: UIBlurEffectStyle = .light
        
        // Follow the URL/QR standard here: https://github.com/clemahieu/raiblocks/wiki/URI-and-QR-Code-Standard
        let paymentAccount: String = "<Your Nano Payment Address Here>"
        
        //set time before session timeout. must be between 120-300 seconds
        let sessionTime: Int = 300
        
        // Launch BrainBlocks Popup Payment UI
        BrainBlocksPayment().launchBrainBlocksPaymentView(viewController: self, paymentCurrency: .nano, paymentDestination: paymentAccount, paymentAmount: amount, sessionTime: sessionTime, paymentMode: .Pay, backgroundStyle: style)
    }
 }
 ```

## BrainBlocksKit Delegate

