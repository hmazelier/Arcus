//
//  Reducer+StepProducerTests.swift
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
    var dummy = 0
}
private enum SomeAction: Action {
    case dummy
}

private enum SomeMutation: Mutation {
    case dummy
}

private enum SomeStep: Int, Step {
    case go
}

private class SUT: Reducer, StepProducer {
    
    func provideInitialState() -> SomeState {
        return SomeState(dummy: 0)
    }
    
    func produceEvent(from action: SomeAction) -> Observable<Arcus.Event> {
        switch action {
        case .dummy:
            return Observable
                .just(SomeMutation.dummy as Arcus.Event)
                .concatJust(SomeStep.go)
                .concatJust(SomeMutation.dummy)
                .concatJust(SomeStep.go)
        }
    }
    
    func reduce(state: SomeState, mutation: SomeMutation) -> SomeState {
        var state = state
        switch mutation {
        case .dummy:
            state.dummy += 1
        }
        return state
    }
    
}

////////

class ReducerStepProducerTests: XCTestCase {
    
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
    
    
    func testStepsAreEmitted() {
        let exp = self.expectation(description: "Test state is mutated parallely")
        
        sut.state.skip(2).take(1).subscribe(onNext: { (state) in
            guard state.dummy == 2 else {
                XCTFail("Steps might have broken the stream")
                return
            }
            exp.fulfill()
        }).disposed(by: disposeBag)
        
        let processingEventsExp = self.expectation(description: "Test Steps are emitted parallely with events")
        sut.steps.take(2).toArray().subscribe(onNext: { processingEvents in
            guard processingEvents.count == 2 else {
                XCTFail("Steps were not emitted properly")
                return
            }
            processingEventsExp.fulfill()
        }).disposed(by: disposeBag)
        
        sut.start()
        sut.actions.accept(SomeAction.dummy)
        
        wait(for: [exp, processingEventsExp], timeout: 1.5)
    }
}
