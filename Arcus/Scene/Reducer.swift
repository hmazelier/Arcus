//
//  Reducer.swift
//  hFlow
//
//  Created by Hadrien Mazelier on 06/09/2018.
//  Copyright © 2018 HadrienMazelier. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import hCore

public protocol Reducer: HasDisposeBag {
    
    associatedtype MutationType: Mutation
    associatedtype ActionType: Action
    associatedtype StateType: State
    
    func provideInitialState() -> StateType
    
    var state: BehaviorSubject<StateType> { get }
    
    var actions: PublishRelay<Action> { get }
    func initiateActions() -> PublishRelay<Action> // No need to implement this except if you don't want to use the provided mechanism
    
    func provideInitialActionsStream() -> Observable<Action>
    func provideInitialEventsStream() -> Observable<Event>
    
    func transform(actions: Observable<Action>) -> Observable<Action>
    func transform(events: Observable<Event>) -> Observable<Event>
    func transform(state: Observable<StateType>) -> Observable<StateType>
    
    
    func produceEvent(from action: ActionType) -> Observable<Event> //Can produce MutationType, ProcessingEvent and Step
    func reduce(state: StateType, mutation: MutationType) -> StateType
}
