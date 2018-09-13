//
//  CoordinatorTests.swift
//  ArcusTests
//
//  Created by Hadrien Mazelier on 31/07/2018.
//  Copyright © 2018 HadrienMazelier. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
@testable import Arcus

private enum Steposs: Step {
    case one
    case two
    case three
    case four
    case transformed
}

private class StepProducerMan: StepProducer {
    let step = PublishRelay<Step>()
    var steps: Observable<Step> {
        return step.asObservable()
    }
}

private class SUT: Coordinator {
    var root: UIViewController? {
        return nil
    }
    
    var parent: Coordinator?
    
    var children: [Coordinator] = []
    
    private var transformSteps = false
    
    //Called in setup
    func testInjectChildren(_ children: [Coordinator]) {
        children.forEach(self.addChild(_:))
    }
    
    // called from test
    func testInjectStepsAndViewController(_ vc: UIViewController, producer: StepProducer) {
        self.willDisplay(presentable: vc, producer: producer)
    }
    
    // called from test
    func testEmitPropagateToParents(step: Step) {
        self.emit(coordinatorEvent: .propagateToParents(step, from: self))
    }
    
    // called from test
    func testEmitPropagateToChildren(step: Step) {
        self.emit(coordinatorEvent: .propagateToChildren(step, from: self))
    }
    
    // called from test
    func testTransformSteps(vc: UIViewController, producer: StepProducer) {
        transformSteps = true
        self.willDisplay(presentable: vc, producer: producer)
    }
    
    // called from test
    func testEmitClose() {
        self.emit(coordinatorEvent: .close(with: nil))
    }
    
    var lastStepCallback: (Step?) -> () = { _ in }
    var lastViewController: UIViewController?
    
    func handle(step: Step, from viewController: UIViewController?) {
        lastViewController = viewController
        lastStepCallback(step)
    }
    
    func closeChild(coordinator: Coordinator, with step: Step?) {
        
    }
    
    func transform(steps: Observable<Step>) -> Observable<Step> {
        if transformSteps {
            return steps.map { _ in return Steposs.transformed }
        } else {
            return steps
        }
    }
}

private class SpyCoordinator: Coordinator {
    
    var root: UIViewController? {
        return nil
    }
    
    var parent: Coordinator?
    
    var children: [Coordinator] = []
    
    var lastStep: Step?
    var lastCoordinator: Coordinator?
    var lastViewController: UIViewController?
    
    var lastCoordinatorToClose: Coordinator?
    
    //Called in setup
    func testInjectSUT(_ sut: SUT) {
        self.addChild(sut)
    }
    
    func handle(step: Step, from viewController: UIViewController?) {
        lastStep = step
        lastViewController = viewController
    }
    
    func handle(step: Step, from coordinator: Coordinator) {
        self.lastStep = step
        self.lastCoordinator = coordinator
    }
    
    func closeChild(coordinator: Coordinator, with step: Step?) {
        lastCoordinatorToClose = coordinator
    }
    
}


class CoordinatorTests: XCTestCase {
    
    fileprivate var parentSpy: SpyCoordinator!
    fileprivate var child1spy: SpyCoordinator!
    fileprivate var child2spy: SpyCoordinator!
    fileprivate  var sut: SUT!
    
    var disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        let parent = SpyCoordinator()
        let sut = SUT()
        let child1 = SpyCoordinator()
        let child2 = SpyCoordinator()
        
        self.sut = sut
        self.parentSpy = parent
        self.child1spy = child1
        self.child2spy = child2
        
        parent.testInjectSUT(sut)
        sut.testInjectChildren([child1, child2])
    }
    
    override func tearDown() {
        super.tearDown()
        disposeBag = DisposeBag()
    }
    
    //To test :
    // - handle step from vc is called when step emitted
    // - handle step from coordinator called when propagateToParents is emitted
    // - handle step from coordinator called when propagateToChildren is emitted
    // - transform steps works
    // - parent.closeChild called when close(:) event is emitted
    
    func testStepFromVCIsCalledWhenStepEmitted() {
        let stepProducer = StepProducerMan()
        let vc = UIViewController()
        
        sut.testInjectStepsAndViewController(vc, producer: stepProducer)
        let exp = self.expectation(description: "Test last step is correct")
        sut.lastStepCallback = { [unowned self] step in
            guard let step = step else {
                XCTFail("Step shouldn't be nil")
                return
            }
            switch step {
            case Steposs.one:
                if self.sut.lastViewController === vc {
                    exp.fulfill()
                } else {
                    XCTFail("LastViewController should be vc")
                }
            default:
                XCTFail("Step should be Steposs.one")
            }
        }
        stepProducer.step.accept(Steposs.one)
        
        self.wait(for: [exp], timeout: 4)
    }
    
    func testPropagateToParent() {
        sut.testEmitPropagateToParents(step: Steposs.two)
        guard let step = parentSpy.lastStep else {
            XCTFail("Step shouldnt be nil")
            return
        }
        switch step {
        case Steposs.two:
            XCTAssert(parentSpy.lastCoordinator === sut)
        default:
            XCTFail("Step should be Steposs.two")
        }
    }
    
    func testPropagateToChildren() {
        sut.testEmitPropagateToChildren(step: Steposs.three)
        guard let step1 = child1spy.lastStep, let step2 = child2spy.lastStep else {
            XCTFail("Steps shouldnt be nil")
            return
        }
        switch (step1, step2) {
        case (Steposs.three, Steposs.three):
            XCTAssert(child1spy.lastCoordinator === sut)
            XCTAssert(child2spy.lastCoordinator === sut)
        default:
            XCTFail("Step should be Steposs.two")
        }
    }
    
    func testTransformSteps() {
        let stepProducer = StepProducerMan()
        let vc = UIViewController()
        sut.testTransformSteps(vc: vc, producer: stepProducer)
        let exp = self.expectation(description: "Test last step is correct")
        sut.lastStepCallback = { step in
            guard let step = step else {
                XCTFail("Step shouldn't be nil")
                return
            }
            switch step {
            case Steposs.transformed:
                exp.fulfill()
            default:
                XCTFail("Step should be Steposs.one")
            }
        }
        stepProducer.step.accept(Steposs.four)
        
        self.wait(for: [exp], timeout: 4)
    }
    
    func testEmitClose() {
        XCTAssert(parentSpy.lastCoordinatorToClose == nil)
        sut.testEmitClose()
        XCTAssert(parentSpy.lastCoordinatorToClose === sut)
        
    }
    
}
