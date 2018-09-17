//
//  ProcessingEventEmitter.swift
//  Arcus
//
//  Created by Hadrien Mazelier on 06/09/2018.
//  Copyright © 2018 HadrienMazelier. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

private var processingEventKey = "processingEventKey"

public protocol ProcessingEventEmitter: AssociatedObjectStore {
    var processingEvents: PublishRelay<ProcessingEvent> { get }
}

extension ProcessingEventEmitter {
    public var processingEvents: PublishRelay<ProcessingEvent> {
        return self.associatedObject(forKey: &processingEventKey, default: .init())
    }
}
