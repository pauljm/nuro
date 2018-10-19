//
//  NuroLayer.swift
//  Nuro
//
//  Created by Paul McReynolds on 10/6/18.
//  Copyright © 2018 Paul McReynolds. All rights reserved.
//

import Foundation

enum NuroLayerError: Error {
    case nonPositiveSize
    case wrongActivationsSize
    case notImplemented(_ method: String)
}

class NuroLayer {
    let size: Int
    
    init(size: Int) {
        self.size = size
    }
    
    func evaluate() throws -> [Float] {
        throw NuroLayerError.notImplemented("evaluate")
    }
}
