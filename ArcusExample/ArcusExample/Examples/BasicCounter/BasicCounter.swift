//
//  BasicCounter.swift
//  Example
//
//  Created by Hadrien Mazelier on 18/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import Arcus

enum BasicCounter {
    
    enum Actions {
        case increment
        case decrement
    }
    
    enum Mutations {
        case increment
        case decrement
    }
    
    struct State {
        var count = 0
    }
    
}

extension BasicCounter.Actions: Arcus.Action {}
extension BasicCounter.Mutations: Arcus.Mutation {}
extension BasicCounter.State: Arcus.State {}
