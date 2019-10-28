//
//  Date+Extension.swift
//  Alamofire
//
//  Created by Ty Schenk on 10/28/19.
//

import Foundation

extension Date {
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}
