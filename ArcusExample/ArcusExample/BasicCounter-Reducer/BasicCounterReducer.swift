//
//  BasicCounterReducer.swift
//  Example
//
//  Created by Hadrien Mazelier on 18/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import Arcus
import RxSwift
import RxCocoa

protocol BasicCounterReducerProtocol {
    var state: BehaviorSubject<BasicCounter.State> { get }
    var actions: PublishRelay<Action> { get }
}

final class BasicCounterReducer: Reducer, BasicCounterReducerProtocol {
    
    func provideInitialState() -> BasicCounter.State {
        return BasicCounter.State()
    }
    
    func produceEvent(from action: BasicCounter.Actions) -> Observable<Arcus.Event> {
        switch action {
        case .increment: return Observable.just(BasicCounter.Mutations.increment)
        case .decrement: return Observable.just(BasicCounter.Mutations.decrement)
        }
    }
    
    func reduce(state: BasicCounter.State, mutation: BasicCounter.Mutations) -> BasicCounter.State {
        var state = state
        
        switch mutation {
        case .decrement:
            state.count -= 1
        case .increment:
            state.count += 1
        }
        
        return state
    }
}
