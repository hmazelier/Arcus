////
////  Interactor.swift
////  FlowTests
////
////  Created by Hadrien Mazelier on 21/06/2018.
////  Copyright © 2018 nanoMe. All rights reserved.
////
//
//import XCTest
//import RxSwift
//import RxCocoa
//@testable import hFlow
//
//struct TestState {
//    var didReceiveInitialAction = false
//    var didReceiveInitialMutation = false
//    var isLoading = false
//    var query: String?
//}
//struct TestViewModel {
//    let query = Variable<String?>(nil)
//    let isLoading = Variable<Bool>(false)
//}
//
//enum TestProcessingEvent: ProcessingEvent {
//    case loading
//    case errorWhileLoading
//    case mutate
//}
//
//enum TestAction: Action {
//    case initialAction
//    case changedQuery(String?)
//    case changedQueryWithProcessing(String?)
//    case produceStepAction
//    case produceStepMutation
//    case mutatingProcessingEvent
//}
//
//enum TestMutation: Mutation {
//    case initialAction
//    case initialMutation
//    case changeQuery(String?)
//    case produceStepMutation
//}
//
//enum TestStep: Step {
//    case stepFromAction
//    case stepFromMutation
//}
//
//class PresenterSpy: Presenter {
//    typealias StateType = TestState
//    typealias ViewModelType = TestViewModel
//    
//    var bindWasCalled = false
//    
//    func bind(state: Observable<TestState>, toViewModel viewModel: TestViewModel) {
//        bindWasCalled = true
//        state
//            .map { $0.query }
//            .bind(to: viewModel.query)
//            .disposed(by: disposeBag)
//        state.map { $0.isLoading }
//            .bind(to: viewModel.isLoading)
//            .disposed(by: disposeBag)
//    }
//}
//
//class InteractorSut: Interactor {
//    func produceEvent(from action: TestAction) -> Observable<Event> {
//        guard let _ = try? self.state.value() else { return Observable.empty() }
//        switch action {
//        case .initialAction:
//            return Observable.just(TestMutation.initialAction)
//        case .changedQuery(let query):
//            return Observable.just(TestMutation.changeQuery(query))
//        case .changedQueryWithProcessing(let query):
//            return Observable.just(TestProcessingEvent.loading as Event)
//                .concat(Observable.just(TestMutation.changeQuery(query)))
//        case .produceStepAction:
//            return Observable.just(TestStep.stepFromAction)
//        case .produceStepMutation:
//            return Observable.just(TestMutation.produceStepMutation)
//        case .mutatingProcessingEvent:
//            return Observable.just(TestProcessingEvent.mutate)
//        }
//    }
//    
//    func produceStep(from mutation: TestMutation) -> Observable<Step> {
//        switch mutation {
//        case .produceStepMutation: return Observable.just(TestStep.stepFromMutation)
//        default: return .empty()
//        }
//    }
//    
//    //for tests
//    var initialAction: TestAction?
//    var initialMutation: TestMutation?
//    var forcedAction: TestAction?
//    var forcedMutation: TestMutation?
//    var forcedProcessingState: ProcessingEventType?
//    var forcedState: TestState?
//    //
//    
//    var presenter: PresenterSpy
//    
//    let viewModel = TestViewModel()
//    
//    init(presenter: PresenterSpy) {
//        self.presenter = presenter
//    }
//    
//    typealias PresenterType = PresenterSpy
//    
//    typealias ProcessingEventType = TestProcessingEvent
//    
//    typealias ActionType = TestAction
//    
//    typealias MutationType = TestMutation
//    
//    typealias StateType = PresenterType.StateType
//    
//    typealias ViewModelType = PresenterType.ViewModelType
//    
//    func provideInitialState() -> TestState {
//        return TestState()
//    }
//    
//    func provideInitialAction() -> TestAction? {
//        return self.initialAction
//    }
//    
//    func provideInitialMutation() -> TestMutation? {
//        return self.initialMutation
//    }
//    
//    func mutate(action: TestAction, currentState: TestState) -> Observable<Event> {
//        switch action {
//        case .initialAction:
//            return Observable.just(TestMutation.initialAction)
//        case .changedQuery(let query):
//            return Observable.just(TestMutation.changeQuery(query))
//        case .changedQueryWithProcessing(let query):
//            return Observable.just(TestProcessingEvent.loading as Event)
//                .concat(Observable.just(TestMutation.changeQuery(query)))
//        case .produceStepAction: return Observable.empty()
//        case .produceStepMutation: return Observable.just(TestMutation.produceStepMutation)
//        case .mutatingProcessingEvent: return Observable.just(TestProcessingEvent.mutate)
//        }
//    }
//    
//    func reduce(state: TestState, mutation: TestMutation) -> TestState {
//        var newState = state
//        switch mutation {
//        case .initialAction:
//            newState.didReceiveInitialAction = true
//        case .initialMutation:
//            newState.didReceiveInitialMutation = true
//        case .changeQuery(let query):
//            newState.query = query
//        case .produceStepMutation: break
//        }
//        return newState
//    }
//    
//    func transform(state: Observable<PresenterSpy.StateType>) -> Observable<PresenterSpy.StateType> {
//            if let forcedState = self.forcedState {
//                return state.map { _ in return forcedState }
//            } else {
//                return state
//            }
//    }
//
//    func transform(events: Observable<Event>) -> Observable<Event> {
//        let forcedMutation = self.forcedMutation
//        return events.map({ event -> Event in
//            if let forcedMutation = forcedMutation, let _ = event as? MutationType {
//                return forcedMutation
//            } else {
//                return event
//            }
//        })
//    }
//    
//    func transform(actions: Observable<TestAction>) -> Observable<TestAction> {
//        if let forcedAction = self.forcedAction {
//            return actions.map { _ in return forcedAction }
//        } else {
//            return actions
//        }
//    }
//}
//
//class InteractorTests: XCTestCase {
//    
//    var presenter: PresenterSpy!
//    var sut: InteractorSut!
//    let actions = PublishRelay<Action>()
//    
//    var disposeBag = DisposeBag()
//    
//    override func setUp() {
//        super.setUp()
//        let p = PresenterSpy()
//        let i = InteractorSut(presenter: p)
//        self.presenter = p
//        self.sut = i
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//        disposeBag = DisposeBag()
//    }
//    
//    func testBindWasCalledOnPresenter() {
//        sut.bind(actions: actions.asObservable())
//        XCTAssert(presenter.bindWasCalled)
//    }
//    
//    func testInitialActionIsEmitted() {
//        sut.initialAction = TestAction.initialAction
//        let exp = self.expectation(description: "Test initial action is emitted")
//
//        sut.state.subscribe(onNext: { (state) in
//            if state.didReceiveInitialAction {
//                exp.fulfill()
//            }
//        }).disposed(by: disposeBag)
//        
//        sut.bind(actions: actions.asObservable())
//        
//        wait(for: [exp], timeout: 3)
//    }
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
//    
//}
