//
//  Reducer.swift
//  Arcus
//
//  Created by Hadrien Mazelier on 24/09/2018.
//

import Foundation
import Arcus
import RxSwift
import RxCocoa

import Swinject


public protocol TestReducerProtocol: StepProducer {
    var state: BehaviorSubject<Test.State> { get }
    var actions: PublishRelay<Action> { get }
    
    var processingEvents: PublishRelay<ProcessingEvent> { get }
    
    func start()
}
    
public final class TestReducer: Reducer, TestReducerProtocol {
    
    let resolver: Resolver
    
    public init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    func provideInitialState() -> Test.State {
        return Test.State()
    }
    
    func produceEvent(from action: Test.Actions) -> Observable<Arcus.Event> {
        return .empty() // change this
    }
    
    func reduce(state: Test.State, mutation: Test.Mutations) -> Test.State {
        var state = state
        
        switch mutation {
        default: break // change this
        }
        
        return state
    }
}
