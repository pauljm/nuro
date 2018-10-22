//
//  NuroMathBasic.swift
//  Nuro
//
//  Created by Paul McReynolds on 10/21/18.
//  Copyright © 2018 Paul McReynolds. All rights reserved.
//

import Foundation

class NuroMathBasic: NuroMath {
    static let shared = NuroMathBasic()
    
    func dotProduct(_ v1: [Float], _ v2: [Float]) -> Float {
        return zip(v1, v2).map(*).reduce(0.0, +)
    }
    
    func sumSquares(_ v: [Float]) -> Float {
        return v.reduce(0.0, { $0 + pow($1, 2) })
    }
    
    func vvAdd(_ v1: [Float], _ v2: [Float]) -> [Float] {
        return zip(v1, v2).map(+)
    }
    
    func vvMultiply(_ v1: [Float], _ v2: [Float]) -> [Float] {
        return zip(v1, v2).map(*)
    }
    
    func vsAdd(_ v: [Float], _ s: Float) -> [Float] {
        return v.map{ $0 + s }
    }
    
    func vsMultiply(_ v: [Float], _ s: Float) -> [Float] {
        return v.map{ $0 * s }
    }
    
    func vSigmoid(v: [Float]) -> [Float] {
        return v.map{ 1 / (1 + exp(-$0)) }
    }
}
