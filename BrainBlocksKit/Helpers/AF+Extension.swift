//
//  AF+Extension.swift
//  BrainBlocksKit
//
//  Created by Ty Schenk on 1/17/18.
//  Copyright © 2018 BrainBlocks. All rights reserved.
//

import Foundation
import Alamofire

// MARK: Check Network
public class Connectivity {
    public class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
