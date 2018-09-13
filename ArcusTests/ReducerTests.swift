//
//  RegularReducerTests.swift
//  ArcusTests
//
//  Created by Hadrien Mazelier on 06/09/2018.
//  Copyright © 2018 HadrienMazelier. All rights reserved.
//

import XCTest
import Foundation
import RxSwift
import RxCocoa
@testable import Arcus

///// TESTS
private struct SomeState: State {
    var initialCount = 0
    var transformed = false
    var transformedActionCount = 0
    var transformedMutation = 0
}
private enum SomeAction: Action {
    case initial
    case transformed
}

private enum SomeProcessingEvent: ProcessingEvent {
    
}
private enum SomeMutation: Mutation {
    case initial
    case transformedAction
    case transformed
}

private class SUT: Reducer {
    var forcedState = SomeState()
    var initialActionsStream: Observable<Action> = .empty()
    var initialEventsStream: Observable<Arcus.Event> = .empty()
    var transformedState: StateType?
    var forcedAction: ActionType?
    
    func provideInitialState() -> SomeState {
        return forcedState
    }
    
    func provideInitialActionsStream() -> Observable<Action> {
        return self.initialActionsStream
    }
    
    func provideInitialEventsStream() -> Observable<Arcus.Event> {
        return self.initialEventsStream
    }
    
    func produceEvent(from action: SomeAction) -> Observable<Arcus.Event> {
        switch action {
        case .initial: return Observable.just(SomeMutation.initial)
        case .transformed: return Observable.just(SomeMutation.transformedAction)
        }
    }
    
    func reduce(state: SomeState, mutation: SomeMutation) -> SomeState {
        var state = state
        switch mutation {
        case .initial:
            state.initialCount += 1
        case .transformedAction:
            state.transformedActionCount += 1
        case .transformed:
            state.transformedMutation += 1
        }
        return state
    }
    
    func transform(state: Observable<SomeState>) -> Observable<SomeState> {
        if let transformedState = self.transformedState {
            return state.map { _ in return transformedState }
        } else {
            return state
        }
    }
    
    func transform(actions: Observable<Action>) -> Observable<Action> {
        if let transformedAction = self.forcedAction {
            return actions.map { _ in return transformedAction }
        } else {
            return actions
        }
    }
    
}

////////

class ReducerTests: XCTestCase {
    
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
    

    func testInitialActionIsEmitted() {
        sut.initialActionsStream = Observable.just(SomeAction.initial)
        let exp = self.expectation(description: "Test initial action is emitted")

        sut.state.skip(1).subscribe(onNext: { (state) in
            if state.initialCount == 1 {
                exp.fulfill()
            }
        }).disposed(by: disposeBag)
        
        sut.start()
        
        wait(for: [exp], timeout: 1.5)
    }
    
    func testInitialActionsAreEmitted() {
        sut.initialActionsStream = Observable.of(SomeAction.initial, SomeAction.initial, SomeAction.initial)
        let exp = self.expectation(description: "Test initial action is emitted")
        
        sut.state.skip(3).subscribe(onNext: { (state) in
            if state.initialCount != 3 {
                XCTFail("There shouldn't be more than 3 actions emitted")
            } else {
                exp.fulfill()
            }
        }).disposed(by: disposeBag)
        
        sut.start()
        
        wait(for: [exp], timeout: 1.5)
    }
    
    func testInitialMutationsAreEmitted() {
        sut.initialEventsStream = Observable.of(SomeMutation.initial, SomeMutation.initial, SomeMutation.initial)
        let exp = self.expectation(description: "Test initial mutation is emitted")
        
        sut.state.skip(3).subscribe(onNext: { (state) in
            if state.initialCount == 3 {
                exp.fulfill()
            } else {
                XCTFail("There shouldn't be more than 3 mutations emitted")
            }
        }).disposed(by: disposeBag)
        
        sut.start()
        
        wait(for: [exp], timeout: 1.5)
    }

    func testTransformState() {
        sut.initialEventsStream = Observable.of(SomeMutation.initial, SomeMutation.initial, SomeMutation.initial)
        sut.transformedState = SomeState(initialCount: 0,
                                         transformed: true,
                                         transformedActionCount: 0,
                                         transformedMutation: 0)
        
        let exp = self.expectation(description: "Test initial state is transformed")
        
        // skip because the first will always be the initial state
        sut.state.skip(3).subscribe(onNext: { (state) in
            guard state.initialCount == 0 && state.transformed == true else {
                XCTFail("State was not transformed properly")
                return
            }
            exp.fulfill()

        }).disposed(by: disposeBag)
        
        sut.start()
        
        wait(for: [exp], timeout: 1.5)
    }
    
    func testTransformActions() {
        sut.forcedAction = SomeAction.transformed
        
        let exp = self.expectation(description: "Test actions are transformed")
        
        sut.state.skip(3).subscribe(onNext: { (state) in
            guard state.transformedActionCount == 3
                && state.transformed == false
                && state.transformedMutation == 0 else {
                    XCTFail("Actions was not transformed properly")
                    return
            }
            exp.fulfill()
            
        }).disposed(by: disposeBag)
        
        sut.start()
        sut.actions.accept(SomeAction.initial)
        sut.actions.accept(SomeAction.initial)
        sut.actions.accept(SomeAction.initial)

        wait(for: [exp], timeout: 1.5)
    }
    
//
//    func testTransformAction() {
//        let exp = self.expectation(description: "Test transform action")
//        sut.forcedAction = TestAction.changedQuery("FORCED")
//        //skip one because initial state will be the default
//        var count = 0
//        sut.state.skip(1).subscribe(onNext: { (state) in
//            XCTAssertEqual(state.query, "FORCED")
//            if count == 1 {
//                exp.fulfill()
//            }
//            count += 1
//
//        }).disposed(by: disposeBag)
//        sut.bind(actions: actions.asObservable())
//        actions.accept(TestAction.changedQuery("NOT_FORCED"))
//        actions.accept(TestAction.changedQuery("NOT_FORCED_AT_ALL"))
//        actions.accept(TestAction.changedQuery("FUCK_OFF"))
//        wait(for: [exp], timeout: 3)
//    }
//
//    func testTransformMutation() {
//        let exp = self.expectation(description: "Test transform mutation")
//        sut.forcedMutation = TestMutation.changeQuery("FORCED")
//        //skip one because initial state will be the default
//        var count = 0
//        sut.state.skip(1).subscribe(onNext: { (state) in
//            XCTAssertEqual(state.query, "FORCED")
//            if count == 1 {
//                exp.fulfill()
//            }
//            count += 1
//
//        }).disposed(by: disposeBag)
//        sut.bind(actions: actions.asObservable())
//        actions.accept(TestAction.changedQuery("NOT_FORCED"))
//        actions.accept(TestAction.changedQuery("NOT_FORCED_AT_ALL"))
//        actions.accept(TestAction.changedQuery("FUCK_OFF"))
//        wait(for: [exp], timeout: 3)
//    }
    
}
