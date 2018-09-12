//
//  Stepper.swift
//  hFlow
//
//  Created by Hadrien Mazelier on 06/09/2018.
//  Copyright © 2018 HadrienMazelier. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public protocol StepProducer: HasDisposeBag {
    var steps: Observable<Step> { get }
}

private var stepKey = "stepKey"
public extension StepProducer {
    public var step: PublishRelay<Step> {
        return self.associatedObject(forKey: &stepKey, default: PublishRelay())
    }
    
    public var steps: Observable<Step> {
        return self.step.asObservable()
    }
}
