//
//  RegularReducerTests.swift
//  hFlowTests
//
//  Created by Hadrien Mazelier on 06/09/2018.
//  Copyright © 2018 HadrienMazelier. All rights reserved.
//

import XCTest
import Foundation
import RxSwift
import RxCocoa
import hCore
@testable import hFlow

///// TESTS
private struct SomeState: State {
    var receivedInitialAction = false
}
private enum SomeAction: Action {
    case initial
}

private enum SomeProcessingEvent: ProcessingEvent {
    
}
private enum SomeMutation: Mutation {
    case initial
}

private class SUT: Reducer {
    var forcedState = SomeState()
    var initialActionsStream: Observable<Action> = .empty()
    var initialEventsStream: Observable<hFlow.Event> = .empty()
    
    func provideInitialState() -> SomeState {
        return forcedState
    }
    
    func provideInitialActionsStream() -> Observable<Action> {
        return self.initialActionsStream
    }
    
    func provideInitialEventsStream() -> Observable<hFlow.Event> {
        return self.initialEventsStream
    }
    
    func produceEvent(from action: SomeAction) -> Observable<hFlow.Event> {
        return .empty()
    }
    
    func reduce(state: SomeState, mutation: SomeMutation) -> SomeState {
        var state = state
        switch mutation {
        case .initial:
            state.receivedInitialAction = true
        }
        return state
    }
    
}

////////

class ReducerTests: XCTestCase {
    
    var disposeBag = DisposeBag()
    private var sut: SUT!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        disposeBag = DisposeBag()
        sut = SUT()
    }
    

    func testInitialActionIsEmitted() {
        sut.initialActionsStream = Observable.just(SomeAction.initial)
        let exp = self.expectation(description: "Test initial action is emitted")

        sut.state.subscribe(onNext: { (state) in
            if state.receivedInitialAction {
                exp.fulfill()
            }
        }).disposed(by: disposeBag)

        _ = sut.actions

        wait(for: [exp], timeout: 3)
    }
//
//    func testInitialMutationIsEmitted() {
//        sut.initialMutation = TestMutation.initialMutation
//        let exp = self.expectation(description: "Test initial mutation is emitted")
//
//        sut.state.subscribe(onNext: { (state) in
//            if state.didReceiveInitialMutation {
//                exp.fulfill()
//            }
//        }).disposed(by: disposeBag)
//
//        sut.bind(actions: actions.asObservable())
//
//        wait(for: [exp], timeout: 3)
//    }
//
//    func testActionMutatesWithoutProcessingEvent() {
//        let stateExp = self.expectation(description: "Test action mutates without processing event - STATE")
//        let viewModelExp = self.expectation(description: "Test action mutates without processing event - VM")
//
//        sut.state.subscribe(onNext: { (state) in
//            if state.query == "TEST" {
//                stateExp.fulfill()
//            }
//        }).disposed(by: disposeBag)
//
//        sut.viewModel.query.asObservable().subscribe(onNext: { (query) in
//            if query == "TEST" {
//                viewModelExp.fulfill()
//            }
//        }).disposed(by: disposeBag)
//
//        sut.bind(actions: actions.asObservable())
//
//        actions.accept(TestAction.changedQuery("TEST"))
//        wait(for: [stateExp, viewModelExp], timeout: 3)
//    }
//
//    func testActionMutatesWithProcessingEvent() {
//        let stateExp = self.expectation(description: "Test action mutates with processing event - STATE")
//        let procExp = self.expectation(description: "Test action mutates with processing event - PROCESSING EVENT")
//
//        sut.state.subscribe(onNext: { (state) in
//            if state.query == "TEST" {
//                stateExp.fulfill()
//            }
//        }).disposed(by: disposeBag)
//
//        sut.processingEvents.subscribe(onNext: { (event) in
//            guard case TestProcessingEvent.loading = event else { return }
//            procExp.fulfill()
//        }).disposed(by: disposeBag)
//
//        sut.bind(actions: actions.asObservable())
//
//        actions.accept(TestAction.changedQueryWithProcessing("TEST"))
//        wait(for: [stateExp, procExp], timeout: 3)
//    }
//
//    func testActionProducesStep() {
//        let exp = self.expectation(description: "Test action produces step")
//
//        sut.steps.subscribe(onNext: { (step) in
//            guard case TestStep.stepFromAction = step else { return }
//            exp.fulfill()
//        }).disposed(by: disposeBag)
//
//        sut.bind(actions: actions.asObservable())
//
//        actions.accept(TestAction.produceStepAction)
//        wait(for: [exp], timeout: 3)
//    }
//
//    func testMutationProducesStep() {
//        let exp = self.expectation(description: "Test mutation produces step")
//
//        sut.steps.subscribe(onNext: { (step) in
//            guard case TestStep.stepFromMutation = step else { return }
//            exp.fulfill()
//        }).disposed(by: disposeBag)
//
//        sut.bind(actions: actions.asObservable())
//
//        actions.accept(TestAction.produceStepMutation)
//        wait(for: [exp], timeout: 3)
//    }
//
//    func testTransformState() {
//        let exp = self.expectation(description: "Test transform state")
//        let forcedState = TestState(didReceiveInitialAction: true,
//                                    didReceiveInitialMutation: true,
//                                    isLoading: true,
//                                    query: "TEST")
//        sut.forcedState = forcedState
//        //skip one because initial state will be the default
//        var count = 0
//        sut.state.skip(1).subscribe(onNext: { (state) in
//            XCTAssertEqual(forcedState.didReceiveInitialAction, state.didReceiveInitialAction)
//            XCTAssertEqual(forcedState.didReceiveInitialMutation, state.didReceiveInitialMutation)
//            XCTAssertEqual(forcedState.isLoading, state.isLoading)
//            XCTAssertEqual(forcedState.query, state.query)
//            if count == 1 {
//                exp.fulfill()
//            }
//            count += 1
//
//        }).disposed(by: disposeBag)
//        sut.bind(actions: actions.asObservable())
//        actions.accept(TestAction.changedQuery("TAK"))
//        actions.accept(TestAction.changedQueryWithProcessing("TOK"))
//        actions.accept(TestAction.changedQueryWithProcessing("TRIM"))
//        wait(for: [exp], timeout: 3)
//    }
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
