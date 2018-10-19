//
//  FaceView.swift
//  Nuro
//
//  Created by Paul McReynolds on 10/4/18.
//  Copyright © 2018 Paul McReynolds. All rights reserved.
//

import UIKit

@IBDesignable
open class FaceView: UIView {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override open func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!

        let activations = UnsafeMutablePointer<Float>.allocate(capacity: 10000)
        for y in 0..<100 {
            for x in 0..<100 {
                activations[100 * y + x] = (100.0 * Float(y) + Float(x)) / 10000.0
            }
        }
        
        let w = Double(rect.width) / 100.0
        let h = Double(rect.height) / 100.0
        
        for y in 0..<100 {
            for x in 0..<100 {
                let a = CGFloat.init(activations[100 * y + x])
                ctx.setFillColor(red: a, green: a, blue: a, alpha: 1.0)
                ctx.fill(CGRect.init(x: Double(x) * w, y: Double(y) * h, width: w, height: h))
            }
        }
    }
}
