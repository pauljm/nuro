//
//  NuroInputLayer.swift
//  Nuro
//
//  Created by Paul McReynolds on 10/6/18.
//  Copyright © 2018 Paul McReynolds. All rights reserved.
//

import Foundation

enum NuroInputLayerError: Error {
    case activationsNotSet
    case wrongActivationsSize
}

class NuroInputLayer: NuroLayer {
    private var a: [Float]?
    
    func setActivations(_ a: [Float]?) throws {
        if (a?.count != size) {
            throw NuroInputLayerError.wrongActivationsSize
        }
        self.a = a
    }
    
    override func evaluate() throws -> [Float] {
        guard let a = a else {
            throw NuroInputLayerError.activationsNotSet
        }
        return a
    }
}
