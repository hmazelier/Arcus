//
//  Coordinator.swift
//  Flow
//
//  Created by Hadrien Mazelier on 12/07/2018.
//  Copyright © 2018 nanoMe. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public enum CoordinatorEvent {
    case close(with: Step?)
    case propagateToParents(Step, from: Coordinator)
    case propagateToChildren(Step, from: Coordinator)
}

public protocol Coordinator: HasDisposeBag {
    var root: UIViewController? { get }
    var parent: Coordinator? { get set }
    var children: [Coordinator] { get set }
    func handle(step: Step, from presentable: Presentable?)
    func handle(step: Step, from coordinator: Coordinator)
    func transform(steps: Observable<Step>) -> Observable<Step> //optional
    func closeChild(coordinator: Coordinator, with step: Step?)
    func setup()
    func startWithStep(_ step: Step)
}

// !!!!! Use addChild(:_) to add a child coordinator, otherwise it wont be held in memory
// !!!!! To communicate with parent and children coordinators, use self.emit(CoordinatorEvent) :)
// !!!!! Only close coordinator calling self.emit(coordinatorEvent: .close(?))
// !!!!! Don't forget to call self.removeChild(:_) when closing coordinator
// !!!!! To connect a scene to a coordinator, use self.willDisplay(presentable:_ ,producer:_)

public protocol Presentable: HasDisposeBag {
    func asViewController() -> UIViewController
}

extension UIViewController: Presentable {
    public func asViewController() -> UIViewController { return self }
}

public extension Coordinator {
    public func setup() { }
    public func transform(steps: Observable<Step>) -> Observable<Step> { return steps }
    
    public func emit(coordinatorEvent: CoordinatorEvent) {
        switch coordinatorEvent {
        case .close(let step):
            self.parent?.closeChild(coordinator: self, with: step)
        case .propagateToChildren:
            self.children.forEach { $0.handle(coordinatorEvent: coordinatorEvent, from: self) }
        case .propagateToParents:
            self.parent?.handle(coordinatorEvent: coordinatorEvent, from: self)
        }
    }
    
    public func handle(coordinatorEvent: CoordinatorEvent, from: Coordinator) {
        switch coordinatorEvent {
        case .close(let step):
            self.closeChild(coordinator: from, with: step)
        case .propagateToChildren(let step, let coordinator):
            self.handle(step: step, from: coordinator)
            self.children.forEach { $0.handle(coordinatorEvent: coordinatorEvent, from: self) }
        case .propagateToParents(let step, let coordinator):
            self.handle(step: step, from: coordinator)
            self.parent?.handle(coordinatorEvent: coordinatorEvent, from: self)
        }
    }
    
    public func handle(step: Step, from coordinator: Coordinator) { }
    
    public func addChild(_ child: Coordinator) {
        self.children.append(child)
        child.didMoveToParent(self)
        child.setup()
    }
    public func didMoveToParent(_ parent: Coordinator) {
        self.parent = parent
    }
    public func removeChild(_ child: Coordinator) {
        self.children = self.children.filter { $0 !== child }
    }
    
    public func willDisplay(presentable: Presentable, producer: StepProducer) {
        let viewController = presentable.asViewController()
        
        self.transform(steps: producer.steps)
            .catchError { _ in return Observable.empty() }
            .subscribe(onNext: { [weak self, weak viewController] step in
               self?.handle(step: step, from: viewController)
            })
            .disposed(by: presentable.disposeBag)
    }
    
    public func startWithStep(_ step: Step) {
        self.handle(step: step, from: nil)
    }
}
