//
//  Extensions.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 1/17/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation

extension String {
    func validAddress() -> Bool {
        if self.range(of: "^xrb_[a-z0-9]{60}$", options: .regularExpression) != nil {
            // Valid Raiblocks Address
            return true
        } else {
            // Not Valid Raiblocks Address
            return false
        }
    }
}
