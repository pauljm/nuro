//
//  NuroMathAccelerate.swift
//  Nuro
//
//  Created by Paul McReynolds on 10/21/18.
//  Copyright © 2018 Paul McReynolds. All rights reserved.
//

import Foundation
import Accelerate

class NuroMathAccelerate: NuroMath {
    static let shared = NuroMathAccelerate()
    
    func dotProduct(_ v1: [Float], _ v2: [Float]) -> Float {
        var o: Float = 0.0
        vDSP_dotpr(v1, 1, v2, 1, &o, vDSP_Length(v1.count))
        return o
    }
    
    func sumSquares(_ v: [Float]) -> Float {
        var o: Float = 0.0
        vDSP_svesq(v, 1, &o, vDSP_Length(v.count))
        return o
    }
    
    func vvAdd(_ v1: [Float], _ v2: [Float]) -> [Float] {
        var o = [Float](repeating: 0, count: v1.count)
        vDSP_vadd(v1, 1, v2, 1, &o, 1, vDSP_Length(v1.count))
        return o
    }
    
    func vvMultiply(_ v1: [Float], _ v2: [Float]) -> [Float] {
        var o = [Float](repeating: 0, count: v1.count)
        vDSP_vmul(v1, 1, v2, 1, &o, 1, vDSP_Length(v1.count))
        return o
    }
    
    func vsAdd(_ v: [Float], _ s: Float) -> [Float] {
        var sm: Float = s
        var o = [Float](repeating: 0, count: v.count)
        vDSP_vsadd(v, 1, &sm, &o, 1, vDSP_Length(v.count))
        return o
    }
    
    func vsMultiply(_ v: [Float], _ s: Float) -> [Float] {
        var sm: Float = s
        var o = [Float](repeating: 0, count: v.count)
        vDSP_vsmul(v, 1, &sm, &o, 1, vDSP_Length(v.count))
        return o
    }
    
    func vSigmoid(v: [Float]) -> [Float] {
        var n = Int32(v.count)
        var o1 = [Float](repeating: 0, count: v.count)
        var o2 = [Float](repeating: 0, count: v.count)
        vvexpf(&o1, v, &n) // exp(x) -> o1
        vvrecf(&o2, &o1, &n) // 1 / exp(x) = exp(-x) -> o2
        var one:Float = 1.0
        vDSP_vsadd(o2, 1, &one, &o1, 1, vDSP_Length(v.count)) // 1 + exp(-x) -> o1
        vvrecf(&o2, &o1, &n) // 1 / (1 + exp(-x)) -> o2
        return o2
    }
}
