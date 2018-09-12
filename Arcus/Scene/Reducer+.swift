//
//  Reducer+.swift
//  hFlow
//
//  Created by Hadrien Mazelier on 06/09/2018.
//  Copyright © 2018 HadrienMazelier. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import hCore

private var stateKey = "state"
private var actionsKey = "action"

extension Reducer {
    
    public var actions: PublishRelay<Action> {
        return self.associatedObject(forKey: &actionsKey, default: self.initiateActions())
    }
    
    public var state: BehaviorSubject<StateType> {
        return self.associatedObject(forKey: &stateKey, default: BehaviorSubject(value: self.provideInitialState()))
    }
    
    func provideInitialActionsStream() -> Observable<Action> {
        return .empty()
    }
    
    public func provideInitialEventsStream() -> Observable<Event> {
        return .empty()
    }
    
    public func transform(actions: Observable<Action>) -> Observable<Action> {
        return actions
    }
    
    public func transform(events: Observable<Event>) -> Observable<Event> {
        return events
    }
    
    public func transform(state: Observable<StateType>) -> Observable<StateType> {
        return state
    }
    
    
}
extension Reducer {
    func extractStepsFromEvents(_ events: Observable<Event>) { }
    func extractProcessingEventsFromEvents(_ events: Observable<Event>) { }
    
    func getTransformedEvents(from actionsRelay: PublishRelay<Action>) -> ConnectableObservable<Event> {
        let initialActionsStream = self.provideInitialActionsStream()
        
        let mergedActions = initialActionsStream.concat(actionsRelay.asObservable())
        let transformedConnectableActions = self.transform(actions: mergedActions).publish()
        
        let sanitizedActions = transformedConnectableActions.scan(Events.none) { (previous, last) -> Action in
            if last is Events.RetryRequest {
                return previous
            } else {
                return last
            }
        }
        
        let localActions = sanitizedActions.tryMap(to: ActionType.self)
        
        let events = localActions.flatMap { [weak self] action -> Observable<Event> in
            guard let this = self else { return .empty() }
            return this.produceEvent(from: action)
                .catchError { _ in return .empty() }
        }
        let initialEventsStream = self.provideInitialEventsStream()
        let mergedEvents = initialEventsStream.concat(events)
        
        let transformedConnectableEvents = self.transform(events: mergedEvents).publish()
        return transformedConnectableEvents
    }
    
    func getMutatedTransformedState(from events: Observable<Event>) -> ConnectableObservable<StateType> {
        let mutations = events.tryMap(to: MutationType.self)
        
        let mutatedState = mutations.flatMap { [weak self] mutation -> Observable<StateType> in
            guard let this = self else { return .empty() }
            let currentState = try this.state.value()
            return .just(this.reduce(state: currentState, mutation: mutation))
            }
            .catchError { _ in return .empty() }
        
        let connectableTranformedMutatedState = self.transform(state: mutatedState).publish()
        
        return connectableTranformedMutatedState
    }
    
    func initiateActions() -> PublishRelay<Action> {
        let actionsRelay = PublishRelay<Action>()
        
        let transformedConnectableEvents = self.getTransformedEvents(from: actionsRelay)
        
        self.extractStepsFromEvents(transformedConnectableEvents)
        self.extractProcessingEventsFromEvents(transformedConnectableEvents)
        
        let connectableTranformedMutatedState = self.getMutatedTransformedState(from: transformedConnectableEvents)
        
        connectableTranformedMutatedState
            .bind(to: self.state)
            .disposed(by: self.disposeBag)
        
        return actionsRelay
    }
}

extension Reducer where Self: StepProducer {
    func extractStepsFromEvents(_ events: Observable<Event>) {
        let steps = events.tryMap(to: Step.self)
        steps
            .bind(to: self.step)
            .disposed(by: disposeBag)
    }
}

extension Reducer where Self: ProcessingEventEmitter {
    func extractProcessingEventsFromEvents(_ events: Observable<Event>) {
        events
            .tryMap(to: ProcessingEventType.self)
            .bind(to: self.processingEvents)
            .disposed(by: disposeBag)
    }
}

extension Reducer where Self: ViewModeler {
    
    func initiateActions() -> PublishRelay<Action> {
        let actionsRelay = PublishRelay<Action>()
        
        let transformedConnectableEvents = self.getTransformedEvents(from: actionsRelay)
        
        self.extractStepsFromEvents(transformedConnectableEvents)
        self.extractProcessingEventsFromEvents(transformedConnectableEvents)
        
        let connectableTranformedMutatedState = self.getMutatedTransformedState(from: transformedConnectableEvents)
        
        self.presenter.bind(state: connectableTranformedMutatedState as! Observable<State>, toViewModel: self.viewModel)
        
        connectableTranformedMutatedState
            .bind(to: self.state)
            .disposed(by: self.disposeBag)
        
        return actionsRelay
    }
}
