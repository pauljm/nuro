//
//  ViewController.swift
//  Nuro
//
//  Created by Paul McReynolds on 10/4/18.
//  Copyright © 2018 Paul McReynolds. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CALayerDelegate {
//    @IBOutlet weak var faceView: UIView!
    //    var image: CGImage!

    override func viewDidLoad() {
        super.viewDidLoad()
//        faceView.layer.delegate = self
    }
    
//    func draw(_ layer: CALayer, in ctx: CGContext) {
//        let activations = UnsafeMutablePointer<Float>.allocate(capacity: 10000)
//        for y in 0..<100 {
//            for x in 0..<100 {
//                activations[100 * y + x] = (100.0 * Float(y) + Float(x)) / 10000.0
//            }
//        }
//
//        let w = Double(ctx.width) / 100.0
//        let h = Double(ctx.height) / 100.0
//
//        for y in 0..<100 {
//            for x in 0..<100 {
//                let a = CGFloat.init(activations[100 * y + x])
//                ctx.setFillColor(red: a, green: a, blue: a, alpha: 1.0)
//                ctx.fill(CGRect.init(x: Double(x) * w, y: Double(y) * h, width: w, height: h))
//            }
//        }
    
//        let bytes = UnsafeRawPointer.init(pixels).bindMemory(to: UInt8.self, capacity: 40000)
//        let prov = CGDataProvider.init(data: CFDataCreate(nil, bytes, 40000))!
//
//        let img = CGImage.init(
//            width: 100,
//            height: 100,
//            bitsPerComponent: 8,
//            bitsPerPixel: 32,
//            bytesPerRow: 400,
//            space: CGColorSpaceCreateDeviceRGB(),
//            bitmapInfo: CGBitmapInfo.byteOrder32Little,
//            provider: prov,
//            decode: nil,
//            shouldInterpolate: true,
//            intent: CGColorRenderingIntent.perceptual)
//
//        faceView.layer.contents = img
//    }
}

