//
//  Int+Extension.swift
//  Alamofire
//
//  Created by Ty Schenk on 10/28/19.
//

import Foundation

/**
 Calculates seconds Int To Minutes and returns as String
*/
public extension Int {
    func secondsToMinutes() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        
        let formattedString = formatter.string(from: TimeInterval(self))!
        return formattedString
    }
}
