//
//  CompoundReducer.swift
//  ArcusExample
//
//  Created by Hadrien Mazelier on 19/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import Arcus
import RxSwift
import RxCocoa
import Swinject

protocol CompoundReducerProtocol {
    var state: BehaviorSubject<Compound.State> { get }
    var actions: PublishRelay<Action> { get }
    var processingEvents: PublishRelay<ProcessingEvent> { get }
}

final class CompoundReducer: Reducer, ProcessingEventEmitter, CompoundReducerProtocol {
    
    private let resolver: Resolver
    
    lazy var ghSearchReducer: GithubSearchReducerProtocol = { resolver.resolve(GithubSearchReducerProtocol.self)! }()
    lazy var ikeaTranslatorReducer: IkeaTranslatorReducerProtocol = {resolver.resolve(IkeaTranslatorReducerProtocol.self)! }()
    
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    func provideInitialState() -> Compound.State {
        return Compound.State()
    }
    
    func produceEvent(from action: Compound.Actions) -> Observable<Arcus.Event> {
        return .empty() //
    }
    
    func reduce(state: Compound.State, mutation: Compound.Mutations) -> Compound.State {
        var state = state
        
        switch mutation {
        case .loadGithubUsers(let ghUsers):
            state.githubUsers = ghUsers
        case .loadIkeaTranslation(let translation):
            state.ikeaTranslation = translation
        }
        
        return state
    }
    
    func transform(actions: Observable<Arcus.Action>) -> Observable<Arcus.Action> {
        
        let queryString = actions
            .flatMap({ action -> Observable<String?> in
                switch action {
                case Compound.Actions.changeQuery(let query):
                    return Observable.just(query)
                default:
                    return .empty()
                }
            })
            .share(replay: 1)
        
        queryString.map { GithubSearch.Actions.changeQuery($0) as Arcus.Action }
            .bind(to: ghSearchReducer.actions)
            .disposed(by: disposeBag)
        
        queryString.map { IkeaTranslator.Actions.changeQuery($0) as Arcus.Action }
            .bind(to: ikeaTranslatorReducer.actions)
            .disposed(by: disposeBag)
        
        return actions
    }
    
    func transform(events: Observable<Arcus.Event>) -> Observable<Arcus.Event> {
        let ghUsersResults = ghSearchReducer
            .state
            .map { $0.users }
            .distinctUntilChanged()
            .map { Compound.Mutations.loadGithubUsers($0) as Arcus.Event }
        
        // This should be done somewhere else, in a setup method for instance
        ghSearchReducer
            .processingEvents
            .bind(to: self.processingEvents)
            .disposed(by: disposeBag)
        
        let ikeaTranslation = ikeaTranslatorReducer
            .state
            .map { $0.translated }
            .distinctUntilChanged()
            .map { Compound.Mutations.loadIkeaTranslation($0) as Arcus.Event }
        
        return Observable.of(events, ghUsersResults, ikeaTranslation).merge()
        
    }
}
