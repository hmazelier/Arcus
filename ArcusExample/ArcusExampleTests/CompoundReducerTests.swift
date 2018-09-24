//
//  CompoundReducerTests.swift
//  ArcusExampleTests
//
//  Created by Hadrien Mazelier on 19/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import XCTest
import Foundation
import RxSwift
import RxCocoa
import Swinject

@testable import ArcusExample

class CompoundReducerTests: XCTestCase {
    
    private var fakeGHStore: FakeGHStore!
    private var ghSearchReducer: GithubSearchReducer!
    private var sut: CompoundReducer!
    private var disposeBag = DisposeBag()
    
    override func setUp() {
        fakeGHStore = FakeGHStore()
        ghSearchReducer = GithubSearchReducer(resolver: Container())
        ghSearchReducer.githubStore = fakeGHStore
        sut = CompoundReducer(resolver: Container())
        sut.ghSearchReducer = ghSearchReducer
        sut.ikeaTranslatorReducer = IkeaTranslatorReducer()
        disposeBag = DisposeBag()
    }
    
    func testStateGetsMutatedByBothStatesChanges() {
        let exp = self.expectation(description: "Test state gets mutated by both states changes")
        sut.state.subscribe(onNext: { state in
            guard state.githubUsers.count == 1, state.ikeaTranslation == "ijkolp" else { return }
            exp.fulfill()
        }).disposed(by: disposeBag)
        
        sut.start()
        
        sut.actions.accept(Compound.Actions.changeQuery("io"))
        
        wait(for: [exp], timeout: 1)
    }
}
