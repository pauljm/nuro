//
//  Zip.swift
//  Nuro
//
//  Created by Paul McReynolds on 10/14/18.
//  Copyright © 2018 Paul McReynolds. All rights reserved.
//

import Foundation

public func unzip<A,B>(_ p: [(A, B)]) -> ([A], [B]) {
    var a: [A] = []
    var b: [B] = []
    for i in 0..<p.count {
        a.append(p[i].0)
        b.append(p[i].1)
    }
    return (a, b)
}
