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

private enum SomeProcessingEvent: Int, ProcessingEvent {
    typealias RawValue = Int
    case one = 0
    case two
    case three
}

private enum SomeMutation: Mutation {
    case dummy
}

private class SUT: Reducer, ProcessingEventEmitter {
    
    func provideInitialState() -> SomeState {
        return SomeState(dummy: 0)
    }
    
    func produceEvent(from action: SomeAction) -> Observable<Arcus.Event> {
        switch action {
        case .dummy:
            return Observable
                .just(SomeProcessingEvent.one)
                .concatJust(SomeMutation.dummy)
                .concatJust(SomeProcessingEvent.two)
                .concatJust(SomeMutation.dummy)
                .concatJust(SomeProcessingEvent.three)
            
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

class ReducerProcessingEventTests: XCTestCase {
    
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
    
    
    func testProcessingEventsAreEmitted() {
        let exp = self.expectation(description: "Test state is mutated parallely")
        
        sut.state.skip(2).take(1).subscribe(onNext: { (state) in
            guard state.dummy == 2 else {
                XCTFail("Processing events might have broken the stream")
                return
            }
            exp.fulfill()
        }).disposed(by: disposeBag)
        
        let processingEventsExp = self.expectation(description: "Test Processing Events are emitted parallely with events")
        sut.processingEvents.take(3).toArray().subscribe(onNext: { processingEvents in
            guard processingEvents.count == 3 else {
                XCTFail("Processing events were not emitted properly")
                return
            }
            processingEvents.enumerated().forEach({ (i, proc) in
                guard let e = proc as? SomeProcessingEvent else {
                    XCTFail("Should be SomeProcessingEvent.self")
                    return
                }
                XCTAssertTrue(e.rawValue == i)
            })
            processingEventsExp.fulfill()
        }).disposed(by: disposeBag)
        
        sut.start()
        sut.actions.accept(SomeAction.dummy)
        
        wait(for: [exp, processingEventsExp], timeout: 1.5)
    }
}
