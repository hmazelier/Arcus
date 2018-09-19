//
//  GithubSearchReducer.swift
//  Example
//
//  Created by Hadrien Mazelier on 18/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import Arcus
import RxSwift
import RxCocoa
import Swinject

protocol GithubSearchReducerProtocol {
    var state: BehaviorSubject<GithubSearch.State> { get }
    var actions: PublishRelay<Action> { get }
    var processingEvents: PublishRelay<ProcessingEvent> { get }
}

final class GithubSearchReducer: Reducer, GithubSearchReducerProtocol, ProcessingEventEmitter {
    
    private let resolver: Resolver
    
    lazy var githubStore: GithubStoreProtocol = { resolver.resolve(GithubStoreProtocol.self)! }()
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    func provideInitialState() -> GithubSearch.State {
        return GithubSearch.State()
    }
    
    func produceEvent(from action: GithubSearch.Actions) -> Observable<Arcus.Event> {
        
        switch action {
        case .changeQuery(let query):
            
            let queryMutation = githubStore
                .searchUsers(query)
                .map { GithubSearch.Mutations.loadResults($0) as Arcus.Event }
                
            return Observable.just(GithubSearch.ProcessingEvent.searching(true))
                .concat(queryMutation)
                .concatJust(GithubSearch.ProcessingEvent.searching(false))
                .catchError { _ -> Observable<Arcus.Event> in
                    return Observable
                        .just(GithubSearch.ProcessingEvent.failure)
                        .concatJust(GithubSearch.Mutations.loadResults([]))
                }
                .takeUntil(nextQuery())
                .observeOn(MainScheduler.asyncInstance) // this should be done somewhere else (for instance, in a presenter :)
            
        }
    }
    
    private func nextQuery() -> Observable<Action> {
        return self.actions.filter({ action -> Bool in
            switch action {
            case GithubSearch.Actions.changeQuery: return true
            default: return false
            }
        })
    }
    
    func reduce(state: GithubSearch.State, mutation: GithubSearch.Mutations) -> GithubSearch.State {
        var state = state
        
        switch mutation {
        case .loadResults(let users):
            state.users = users
        }
        
        return state
    }
}
