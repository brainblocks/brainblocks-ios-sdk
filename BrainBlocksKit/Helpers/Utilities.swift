//
//  Utilities.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 4/19/19.
//  Copyright © 2019 BrainBlocks. All rights reserved.
//

import Foundation

/**
Pulls address out of Nano url or QR Code
*/
func processAddress(url: String, completionHandler: @escaping (String, String) -> ()) {
	var address: String = url
	var amount: String = ""
	
	// strip after &
	if let urlRange = address.range(of:"&") {
		address.removeSubrange(urlRange.lowerBound..<address.endIndex)
	}
	
	// check to see if amount is in address url
	if url.lowercased().range(of:"?amount=") == nil {
		// strip after ?
		if let urlRange = address.range(of:"?") {
			address.removeSubrange(urlRange.lowerBound..<address.endIndex)
		}
	}
	
	// pull amount value after ?amount=
	if let range = address.range(of: "?amount=") {
		let rangeAmount = address[range.upperBound...].trimmingCharacters(in: .whitespaces)
		amount = rangeAmount
	}
	
	// strip leftover after?
	if let urlRange = address.range(of:"?") {
		address.removeSubrange(urlRange.lowerBound..<address.endIndex)
	}
	
	// remove prefix xrb: or nano:
	address = address.replacingOccurrences(of: "xrb:", with: "")
	address = address.replacingOccurrences(of: "nano:", with: "")
	
	// check if processed address is valid
	if address.validAddress() {
		completionHandler(address, amount)
	} else {
		completionHandler("", "0")
		print("Address processing error")
	}
}

/**
Calculates amount of time to subtract for time indicator
*/
func calcTimerIndicatorDecimal(elapsedTime: Int) -> Float {
	var decimalString = String(format: "%g", 100.0/Double(elapsedTime))
	decimalString = decimalString.replacingOccurrences(of: "0.", with: "")
	let floatNumber = Float("0.00\(decimalString)")!
	decimalString = String(format: "%g", floatNumber)
	let time = Float(decimalString)!
	
	return time
}
