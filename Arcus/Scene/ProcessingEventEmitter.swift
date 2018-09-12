//
//  ProcessingEventEmitter.swift
//  hFlow
//
//  Created by Hadrien Mazelier on 06/09/2018.
//  Copyright © 2018 HadrienMazelier. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

private var processingEventKey = "processingEventKey"

public protocol ProcessingEventEmitter {
    associatedtype ProcessingEventType: ProcessingEvent
    var processingEvents: PublishRelay<ProcessingEventType> { get }
}

public protocol AutoProcessingEventEmitter: ProcessingEventEmitter, AssociatedObjectStore { }

extension AutoProcessingEventEmitter {
    public var processingEvents: PublishRelay<ProcessingEventType> {
        return self.associatedObject(forKey: &processingEventKey, default: .init())
    }
}
