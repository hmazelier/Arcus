//
//  Reducer+.swift
//  Arcus
//
//  Created by Hadrien Mazelier on 06/09/2018.
//  Copyright © 2018 HadrienMazelier. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

private var stateKey = "state"
private var actionsKey = "action"

extension Reducer {
    
    public var actions: PublishRelay<Action> {
        return self.associatedObject(forKey: &actionsKey, default: provideInitialActionsRelay())
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
    
    public func start() {
        _ = self.actions
    }
}
extension Reducer {
    func extractStepsFromEvents(_ events: Observable<Event>) {
        guard let this = self as? StepProducer else { return }
        events.tryMap(to: Step.self).bind(to: this.step).disposed(by: disposeBag)
    }
    func extractProcessingEventsFromEvents(_ events: Observable<Event>) {
        guard let this = self as? ProcessingEventEmitter else { return }
        events
            .tryMap(to: ProcessingEvent.self)
            .bind(to: this.processingEvents)
            .disposed(by: disposeBag)
    }
    
    func getTransformedEvents(from actions: Observable<Action>) -> ConnectableObservable<Event> {
        
        let initialActionsStream = self.provideInitialActionsStream()
        
        let mergedActions = initialActionsStream.concat(actions).share(replay: 1)
        
        
        let transformedConnectableActions = self.transform(actions: mergedActions)
        
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
        let mergedEvents = initialEventsStream.concat(events).share(replay: 1)
        
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
    
    func provideInitialActionsRelay() -> PublishRelay<Action> {
        let actionsRelay = PublishRelay<Action>()
        let connectableActions = actionsRelay.asObservable().publish()
        let transformedConnectableEvents = self.getTransformedEvents(from: connectableActions)
        
        self.extractStepsFromEvents(transformedConnectableEvents)
        self.extractProcessingEventsFromEvents(transformedConnectableEvents)
        
        let connectableTranformedMutatedState = self.getMutatedTransformedState(from: transformedConnectableEvents)
        
        connectableTranformedMutatedState
            .bind(to: self.state)
            .disposed(by: self.disposeBag)
        
        connectableTranformedMutatedState.connect().disposed(by: disposeBag)
        transformedConnectableEvents.connect().disposed(by: disposeBag)
        connectableActions.connect().disposed(by: disposeBag)
        
        return actionsRelay
    }
}
