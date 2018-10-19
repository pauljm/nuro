//
//  NuroFullyConnectedLayer.swift
//  Nuro
//
//  Created by Paul McReynolds on 10/6/18.
//  Copyright © 2018 Paul McReynolds. All rights reserved.
//

import Foundation

enum NuroFullyConnectedLayerError: Error {
    case wrongWeightsSize
    case wrongBiasesSize
    case weightsNotSet
    case biasesNotSet
    case nonPositiveagitationPeriod
    case invalidActivityFactor
    case rewardedBeforeEvalution
    case invalidRewardStrength
}

protocol Agitator {
    func getAgitations(layerSize: Int) -> [Float]
}

class FixedAgitator: Agitator {
    var activation: Float
    
    init(activation: Float) {
        self.activation = activation
    }
    
    func getAgitations(layerSize: Int) -> [Float] {
        return Array.init(repeating: activation, count: layerSize)
    }
}

class RandomAgitator: Agitator {
    var min: Float
    var max: Float
    
    init(min: Float, max: Float) {
        self.min = min
        self.max = max
    }

    func getAgitations(layerSize: Int) -> [Float] {
        let diff = max - min
        return (0..<layerSize).map{ _ in min + diff * Float(arc4random()) / 0xFFFFFFFF }
    }
}

class NuroFullyConnectedLayer: NuroLayer {
    let prev: NuroLayer
    let activationFn: (Float) -> Float
    let agitator: Agitator
    let agitationPeriod: Int // Number of evaluations over which input adjustments are tweened
    let biasTrainingFactor: Float // The fraction of training adjustments apportioned to biases
    private var aInput: [Float]? // Activation levels of all neurons in the previous layer
    private(set) var w: [[Float]]? // 2D array of weights for all inputs to all neurons
    private(set) var b: [Float]? // Biases for all neurons
    private var hFrom: [Float]? // The current vector of "hypothesis" agitations of z for all neurons
    private var hTo: [Float]? // The next vector of "hypothesis" agitations of z for all neurons
    private var hTween: Int = 0 // The number of tweening steps (< agitationPeriod) taken from hFrom to hTo
    private var h: [Float]? // The "hypothesis" agitations, tweened between hFrom and hTo
    private var z: [Float]? // The input to the activation function for each neuron
    private var a: [Float]? // The last activation levels of all neurons
    
    init(
        size: Int,
        activationFn: @escaping (Float) -> Float,
        prev: NuroLayer,
        agitator: Agitator,
        agitationPeriod: Int = 50,
        biasTrainingFactor: Float = 0.1
    ) {
        self.activationFn = activationFn
        self.prev = prev
        self.agitator = agitator
        self.agitationPeriod = agitationPeriod
        self.biasTrainingFactor = biasTrainingFactor
        super.init(size: size)
    }
    
    func setWeights(_ w: [[Float]]?) throws {
        if let w = w {
            if (w.count != size) {
                throw NuroFullyConnectedLayerError.wrongWeightsSize
            }
            for nw in w {
                if (nw.count != prev.size) {
                    throw NuroFullyConnectedLayerError.wrongWeightsSize
                }
            }
        }
        self.w = w
    }
    
    func setBiases(_ b: [Float]?) throws {
        if (b?.count != size) {
            throw NuroFullyConnectedLayerError.wrongBiasesSize
        }
        self.b = b
    }
    
    override func evaluate() throws -> [Float] {
        guard let w = w else {
            throw NuroFullyConnectedLayerError.weightsNotSet
        }
        
        guard let b = b else {
            throw NuroFullyConnectedLayerError.weightsNotSet
        }
        
        aInput = try prev.evaluate() // Recurse

        h = try getAgitations()
        z = zip(zip(w, b), h!).map { (tuple) -> Float in
            let ((wn, bn), hn) = tuple
            return zip(aInput!, wn).map(*).reduce(0.0, +) + bn + hn
        }
        a = z!.map(activationFn)
        
        return a!
    }
    
    func reward(strength: Float) throws {
        guard
            let aInput = aInput,
            let w = w,
            let b = b,
            let h = h
        else {
            throw NuroFullyConnectedLayerError.rewardedBeforeEvalution
        }
        
        if (strength < -1.0 || strength > 1.0) {
            throw NuroFullyConnectedLayerError.invalidRewardStrength
        }

        // Update biases. The rewarded hypothesis is apportioned between bias and input weights
        // according to the biasTrainingFactor.
        self.b = zip(b, h).map { (tuple: (Float, Float)) -> (Float) in
            let (bn, hn) = tuple
            return bn + strength * biasTrainingFactor * hn
        }
        
        // Update weights. The portion of the rewarded hypothesis not apportioned to the bias is
        // apportioned among input weights proportionally to their activation levels such that,
        // between adjustments to bias and weights, z is increased by h. Specifically:
        //
        //   ∆w = c * h * a / ∑(a^2)
        //
        // Such that:
        //
        //   ∑(a∆w) = c * h
        //
        // For a constant c related to reward strength and the bias training factor.
        let inputSumSq = aInput.reduce(0.0, { $0 + pow($1, 2) })
        let coeff = strength * (1.0 - biasTrainingFactor) / inputSumSq
        self.w = zip(w, h).map { (tuple: ([Float], Float)) -> [Float] in
            let (wn, hn) = tuple
            return zip(wn, aInput).map { $0.0 + coeff * $0.1 * hn }
        }
    }
    
    /**
     Gets "hypothesis" agitations for all neurons in the layer. The agitations are small
     additive (or subtractive) adjustments to z, the input to the activation function.
     (For a given neuron, the output activation is a = A(z), z = Σwi + b + h, where w
     are the input weights, i are the input activations, b is the bias, and h is the
     hypothesis.)
     
     The agitations are hypotheses because they "hypothesize" that the network would
     perform better if each neuron had a slightly different activation. If a reward is
     received, the hypotheses are "confirmed" and weights and biases are adjusted so that
     a future identical input will result in activations closer to those reached due to
     the agitations.
     
     In this way the learning mechanism of the network is evolutionary. Small variations
     are tested on each evaluation, kept if they lead to reward, and discarded if not.
     
     Rewards may not be immediate. For example, when a rat presses a pedal to receive
     food, there is some latency between stepping on the pedal and eating the food. For
     the approach here to work, (1) input must be slow-changing relative to reward latency
     and (2) agitations must be varied slowly such that the hypothesis treated as being
     confirmed by a reward will be similar to the hypothesis that was in effect when the
     rewarded behavior was triggered. (1) must be enforced by the client; (2) is accomplished
     by slowly varying agitations between a starting (hFrom) and a target (hTo) vector.
     */
    private func getAgitations() throws -> [Float] {
        if (agitationPeriod <= 0) {
            throw NuroFullyConnectedLayerError.nonPositiveagitationPeriod
        }
        
        if hTween == 0 {
            hFrom = hTo ?? agitator.getAgitations(layerSize: size)
            hTo = agitator.getAgitations(layerSize: size)
        }
        
        // Tween agitations between hFrom and hTo
        let fromWeight = Float(hTween) / Float(agitationPeriod)
        let toWeight = 1.0 - fromWeight
        let adjs = zip(hFrom!, hTo!).map({ (pair: (Float, Float)) -> Float in
            let (fromAdj, toAdj) = pair
            return fromWeight * fromAdj + toWeight * toAdj
        })
        
        hTween = (hTween + 1) % agitationPeriod
        
        return adjs
    }
}
