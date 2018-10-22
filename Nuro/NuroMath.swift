//
//  NuroMath.swift
//  Nuro
//
//  Created by Paul McReynolds on 10/21/18.
//  Copyright © 2018 Paul McReynolds. All rights reserved.
//

import Foundation

protocol NuroMath {
    func dotProduct(_ v1: [Float], _ v2: [Float]) -> Float
    
    func sumSquares(_ v: [Float]) -> Float
    
    func vvAdd(_ v1: [Float], _ v2: [Float]) -> [Float]
    
    func vvMultiply(_ v1: [Float], _ v2: [Float]) -> [Float]
    
    func vsAdd(_ v: [Float], _ s: Float) -> [Float]
    
    func vsMultiply(_ v: [Float], _ s: Float) -> [Float]
    
    func vSigmoid(v: [Float]) -> [Float]
}
