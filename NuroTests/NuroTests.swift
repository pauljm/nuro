//
//  NuroTests.swift
//  NuroTests
//
//  Created by Paul McReynolds on 10/4/18.
//  Copyright © 2018 Paul McReynolds. All rights reserved.
//

import XCTest
@testable import Nuro

class NuroTests: XCTestCase {
    var middleAgitator: FixedAgitator?
    var lastAgitator: FixedAgitator?

    var first: NuroInputLayer?
    var middle: NuroFullyConnectedLayer?
    var last: NuroFullyConnectedLayer?

    let middleWeights: [[Float]] = [
        [-0.5,  0.25],
        [0.75,  0.0 ],
        [0.1 , -0.9 ]
    ]
    let middleBiases: [Float] = [
        -1.0,
         3.5,
         0.0
    ]
    let lastWeights: [[Float]] = [
        [0.25, -0.75, 0.1 ],
        [0.1 ,  0.75, 0.25]
    ]
    let lastBiases: [Float] = [
        -2.0,
         0.5
    ]
    
    let inputs: [Float] = [0.75, 0.25]
    let expectedMiddleActivationsRounded: [Float] = [
        0.21 /* 0.212068804357105; z = -1.3125 */,
        0.98 /* 0.983085086733273; z =  4.0625 */,
        0.46 /* 0.46257015465625 ; z = -0.15   */
    ]
    let expectedLastActivationsRounded: [Float] = [
        0.07, // 0.066730020093049; z = -2.638039598495054
        0.80  // 0.798051953976846; z =  1.374163234149728
    ]

    let biasTrainingFactor: Float = 0.1
    let agitation: Float = 1.0
    let agitationPeriod: Int = 1 // So agitations can be changed without interpolating
    let rewardStrength: Float = 0.5
    // ∑(a^2) = 0.75^2 + 0.25^2 = 0.625
    // a / ∑(a^2) = [0.75 / 0.625, 0.25 / 0.625] = [1.2, 0.4]
    // ∆w = 0.9 weight factor * 0.5 reward strength * 1.0 agitation * a / ∑(a^2) = [0.45 * 1.2, 0.45 * 0.4] = [0.54, 0.18]
    let expectedLearnedMiddleWeightsRounded: [[Float]] = [
        [0.04,  0.43],
        [1.29,  0.18],
        [0.64, -0.72]
    ]
    // ∆b = 0.1 bias factor * 0.5 reward strength * 1.0 agitation = 0.05
    let expectedLearnedMiddleBiasesRounded: [Float] = [
        -0.95,
         3.55,
         0.05
    ]
    
    override func setUp() {
        middleAgitator = FixedAgitator.init(activation: 0.0)
        lastAgitator = FixedAgitator.init(activation: 0.0)

        first = NuroInputLayer.init(size: 2)
        middle = NuroFullyConnectedLayer.init(
            size: middleWeights.count,
            activationFn: NuroTests.sigmoid,
            prev: first!,
            agitator: middleAgitator!,
            agitationPeriod: agitationPeriod,
            biasTrainingFactor: biasTrainingFactor
        )
        last = NuroFullyConnectedLayer.init(
            size: lastWeights.count,
            activationFn: NuroTests.sigmoid,
            prev: middle!,
            agitator: lastAgitator!,
            agitationPeriod: agitationPeriod,
            biasTrainingFactor: biasTrainingFactor
        )
        
        do {
            try first!.setActivations(inputs)
            try middle!.setWeights(middleWeights)
            try middle!.setBiases(middleBiases)
            try last!.setWeights(lastWeights)
            try last!.setBiases(lastBiases)
        } catch {
            print("Error setting up network: \(error)")
        }
    }

    func testEvaluate() {
        do {
            let middleActivationsRounded = try middle!.evaluate().map(NuroTests.round2)
            XCTAssertEqual(middleActivationsRounded, expectedMiddleActivationsRounded)
            let lastActivationsRounded = try last!.evaluate().map(NuroTests.round2)
            XCTAssertEqual(lastActivationsRounded, expectedLastActivationsRounded)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testReward() {
        middleAgitator!.activation = agitation
        do {
            _ = try middle!.evaluate().map(NuroTests.round2)
            try middle!.reward(strength: rewardStrength)
            let middleWeightsRounded = middle!.w!.map { $0.map(NuroTests.round2) }
            XCTAssertEqual(middleWeightsRounded, expectedLearnedMiddleWeightsRounded)
            let middleBiasesRounded = middle!.b!.map(NuroTests.round2)
            XCTAssertEqual(middleBiasesRounded, expectedLearnedMiddleBiasesRounded)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testLearning() {
        middleAgitator!.activation = -0.5 // Arbitrary
        lastAgitator!.activation = 1.5 // Arbitrary
        do {
            let resultRounded = try last!.evaluate().map(NuroTests.round2)
            try middle!.reward(strength: 1.0)
            try last!.reward(strength: 1.0)
            middleAgitator!.activation = 0.0
            lastAgitator!.activation = 0.0
            let secondResultRounded = try last!.evaluate().map(NuroTests.round2)
            XCTAssertEqual(secondResultRounded, resultRounded)
        } catch {
            print("Error setting up network: \(error)")
        }
    }

    func testPerformanceExample() {
        self.measure {
            do {
                _ = try last!.evaluate()
            } catch {
                XCTFail("\(error)")
            }
        }
    }
    
    static func sigmoid(x: Float) -> Float {
        return 1 / (1 + exp(-x))
    }
    
    static func round2(x: Float) -> Float {
        return (100.0 * x).rounded() / 100.0
    }
}
