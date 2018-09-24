//
//  DatePresentationReducer.swift
//  ArcusExample
//
//  Created by Hadrien Mazelier on 21/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//
import Foundation
import Arcus
import RxSwift
import RxCocoa
import Swinject

protocol DatePresentationReducerProtocol {
    var viewModel: DatePresentation.ViewModel { get }
    var actions: PublishRelay<Action> { get }
    func start()
}

final class DatePresentationReducer: Reducer, DatePresentationReducerProtocol {
    
    private let resolver: Resolver
    
    let viewModel = DatePresentation.ViewModel()
    lazy var presenter: DatePresentationPresenterProtocol = { resolver.resolve(DatePresentationPresenterProtocol.self)! }()
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    func provideInitialState() -> DatePresentation.State {
        return DatePresentation.State()
    }
    
    func onReady() {
        presenter.bind(state: self.state, toViewModel: self.viewModel)
    }
    
    func produceEvent(from action: DatePresentation.Actions) -> Observable<Arcus.Event> {
        switch action {
        case .changeDate(let date): return Observable.just(DatePresentation.Mutations.changeDate(date))
        }
    }
    
    func reduce(state: DatePresentation.State, mutation: DatePresentation.Mutations) -> DatePresentation.State {
        var state = state
        
        switch mutation {
        case .changeDate(let date):
            state.date = date
        }
        
        return state
    }
}
