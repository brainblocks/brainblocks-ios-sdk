//
//  Values.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 10/27/19.
//

import Foundation

let sessionLengthMinutes = 20
fileprivate let seconds = 60
let sessionTime: Int = (sessionLengthMinutes * seconds)

enum Status: String {
    case success = "success"
    case error = "error"
}
