//
//  ViewModelerTests.swift
//  ArcusTests
//
//  Created by Hadrien Mazelier on 14/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import XCTest
import Foundation
import RxSwift
import RxCocoa
@testable import Arcus

///// TESTS
private struct SomeState: State {
    var count = 0
}
private enum SomeAction: Action {
    case incr
}

private enum SomeMutation: Mutation {
    case incr
}

private class SUT: ViewModeler {
    let viewModel: SomeViewModel = SomeViewModel()
    
    let presenter: SomePresenter = SomePresenter()
    
    typealias ViewModelType = SomeViewModel
    
    typealias PresenterType = SomePresenter
    
    func provideInitialState() -> SomeState {
        return SomeState(count: 0)
    }
    
    func produceEvent(from action: SomeAction) -> Observable<Arcus.Event> {
        switch action {
        case .incr: return Observable.just(SomeMutation.incr)
        }
    }
    
    func reduce(state: SomeState, mutation: SomeMutation) -> SomeState {
        var state = state
        switch mutation {
        case .incr:
            state.count += 1
        }
        return state
    }
    
}

private struct SomeViewModel: Arcus.ViewModel {
    let count = PublishRelay<Int>()
}

private class SomePresenter: Presenter {
    
    typealias StateType = SomeState
    typealias ViewModelType = SomeViewModel
    
    func bind(state: Observable<SomeState>, toViewModel viewModel: SomeViewModel) {
        let convertedState = state.share()
        convertedState
            .map { $0.count }
            .bind(to: viewModel.count)
            .disposed(by: disposeBag)
    }
}

////////

class ViewModelerTests: XCTestCase {
    
    var disposeBag = DisposeBag()
    private var sut: SUT!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        sut = SUT()
    }
    
    override func tearDown() {
        super.tearDown()
        
    }
    
    
    func testViewModelReflectsStateChanges() {
        let exp = self.expectation(description: "Test viewModel reflects state changes")
        
        sut.viewModel.count.filter { $0 < 2 }.subscribe(onNext: { _ in
            exp.fulfill()
        }).disposed(by: disposeBag)
        
        sut.start()
        
        sut.actions.accept(SomeAction.incr)
        sut.actions.accept(SomeAction.incr)

        wait(for: [exp], timeout: 1.5)
    }
}
