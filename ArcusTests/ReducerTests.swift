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
    case error
}

private enum UnknownAction: Action {
    case yo
}

private enum SomeError: Error {
    case damn
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
    var forcedEvent: Arcus.Event?
    
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
        case .error: return Observable.error(SomeError.damn)
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
    
    func transform(events: Observable<Arcus.Event>) -> Observable<Arcus.Event> {
        if let forcedEvent = self.forcedEvent {
            return events.map { _ in return forcedEvent }
        } else {
            return events
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
    
    func testTransformEvents() {
        sut.forcedEvent = SomeMutation.transformed
        
        let exp = self.expectation(description: "Test events are transformed")
        
        sut.state.skip(3).subscribe(onNext: { (state) in
            guard state.transformedMutation == 3
                && state.transformed == false
                && state.transformedActionCount == 0 else {
                    XCTFail("Events are not transformed properly")
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
    
    func testRetryEvent() {
        
        let exp = self.expectation(description: "Test retry")
        
        sut.state.skip(3).subscribe(onNext: { (state) in
            guard state.transformedActionCount == 3
                && state.transformed == false
                && state.transformedMutation == 0 else {
                    XCTFail("Retry doesnt work properly")
                    return
            }
            exp.fulfill()
            
        }).disposed(by: disposeBag)
        
        sut.start()
        sut.actions.accept(SomeAction.transformed)
        sut.actions.accept(SomeAction.transformed)
        sut.actions.accept(Events.retry)
        
        wait(for: [exp], timeout: 1.5)
    }
    
    func testEventsStreamIsNotBrokenWhenNotRecognizedActionReceived() {
        
        let exp = self.expectation(description: "Test stream not broken when not recognized action")
        
        sut.state.skip(3).subscribe(onNext: { (state) in
            guard state.transformedActionCount == 3 else {
                    XCTFail("Stream might be broken after receiving an unknown action")
                    return
            }
            exp.fulfill()
            
        }).disposed(by: disposeBag)
        
        sut.start()
        sut.actions.accept(SomeAction.transformed)
        sut.actions.accept(UnknownAction.yo)
        sut.actions.accept(SomeAction.transformed)
        sut.actions.accept(SomeAction.transformed)
        
        wait(for: [exp], timeout: 1.5)
    }
    
    func testErrorDoesntCompleteTheStream() {
        
        let exp = self.expectation(description: "Test stream isnt completed when receives error")
        
        sut.state.skip(3).subscribe(onNext: { (state) in
            guard state.initialCount == 3 else {
                    XCTFail("Stream might have completed on error")
                    return
            }
            exp.fulfill()
            
        }).disposed(by: disposeBag)
        
        sut.start()
        sut.actions.accept(SomeAction.initial)
        sut.actions.accept(SomeAction.initial)
        sut.actions.accept(SomeAction.error)
        sut.actions.accept(SomeAction.initial)
        
        wait(for: [exp], timeout: 1.5)
    }
}
