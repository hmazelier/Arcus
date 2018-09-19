//
//  GithubSearchReducerTests.swift
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

final class FakeGHStore: GithubStoreProtocol {
    var users: [GithubStore.User] = [GithubStore.User(id: 0, login: "hmazelier", url: URL(string: "https://google.com")!)]
    func searchUsers(_ query: String?) -> Observable<[GithubStore.User]> {
        return Observable.just(self.users)
    }
}

class GithubSearchReducerTests: XCTestCase {
    
    private var fakeGHStore: FakeGHStore!
    private var sut: GithubSearchReducer!
    private var disposeBag = DisposeBag()
    
    override func setUp() {
        fakeGHStore = FakeGHStore()
        sut = GithubSearchReducer(resolver: Container())
        sut.githubStore = fakeGHStore
        disposeBag = DisposeBag()
    }
    
    func testStateGetsMutatedWithResults() {
        let exp = self.expectation(description: "Test state gets mutated with results")
        sut.state.skip(1).take(1).subscribe(onNext: { state in
            XCTAssertTrue(state.users.count == 1)
            XCTAssertTrue(state.users[0].id == 0)
            XCTAssertTrue(state.users[0].login == "hmazelier")
            exp.fulfill()
        }).disposed(by: disposeBag)
        
        sut.actions.accept(GithubSearch.Actions.changeQuery("FACK AFF"))
        
        wait(for: [exp], timeout: 1)
    }
}
