//
//  BasicCounterReducerTests.swift
//  ArcusExampleTests
//
//  Created by Hadrien Mazelier on 18/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import XCTest
import Foundation
import RxSwift
import RxCocoa
import Swinject

@testable import ArcusExample

class BasicCounterReducerTests: XCTestCase {
    var sut: BasicCounterReducer!
    var disposeBag = DisposeBag()
    override func setUp() {
        sut = BasicCounterReducer()
        disposeBag = DisposeBag()
    }
    
    func testIncrement() {
        let exp = self.expectation(description: "Test counter is incremented")
        sut.state.asObservable().skip(2).take(1).subscribe(onNext: { state in
            XCTAssertTrue(state.count == 2)
        }).disposed(by: disposeBag)
        
        sut.actions.accept(BasicCounter.Actions.increment)
        sut.actions.accept(BasicCounter.Actions.increment)
        wait(for: [exp], timeout: 1)
    }
    
    func testDecrement() {
        
    }
}
