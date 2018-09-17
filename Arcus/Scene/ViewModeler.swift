//
//  ViewModeler.swift
//  Arcus
//
//  Created by Hadrien Mazelier on 06/09/2018.
//  Copyright © 2018 HadrienMazelier. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol ViewModeler: Reducer {
    
    associatedtype ViewModelType: ViewModel
    var viewModel: ViewModelType { get }
    
    associatedtype PresenterType: Presenter
    
    var presenter: PresenterType { get }
}

private var actionsKey = "actionsKey_"

extension ViewModeler where Self: ViewModeler {
    
    public var actions: PublishRelay<Action> {
        return self.associatedObject(forKey: &actionsKey, default: provideInitialActionsRelay())
    }
    
    func provideInitialActionsRelay() -> PublishRelay<Action> {
        let actionsRelay = PublishRelay<Action>()
        
        let connectableActions = actionsRelay.asObservable().publish()
        
        let transformedConnectableEvents = self.getTransformedEvents(from: connectableActions)
        
        self.extractStepsFromEvents(transformedConnectableEvents)
        self.extractProcessingEventsFromEvents(transformedConnectableEvents)
        
        let connectableTranformedMutatedState = self.getMutatedTransformedState(from: transformedConnectableEvents)
        
        self.presenter.bind(state: connectableTranformedMutatedState.tryMap(to: State.self), toViewModel: self.viewModel)
        
        connectableTranformedMutatedState
            .bind(to: self.state)
            .disposed(by: self.disposeBag)
        
        transformedConnectableEvents.connect().disposed(by: disposeBag)
        connectableTranformedMutatedState.connect().disposed(by: disposeBag)
        connectableActions.connect().disposed(by: disposeBag)
        
        return actionsRelay
    }
}
