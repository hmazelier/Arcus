//
//  Events.swift
//  Flow
//
//  Created by Hadrien Mazelier on 12/07/2018.
//  Copyright © 2018 nanoMe. All rights reserved.
//

import Foundation

public protocol Action {}

public protocol State {}
public protocol ViewModel {}

public enum Events {
    final class RetryRequest: Action {
        fileprivate init() {}
    }
    
    final class None: Action {
        fileprivate init() {}
    }
    
    @nonobjc public static let retry: Action = RetryRequest()
    @nonobjc public static let none: Action = None()
}

public protocol Event { }
public protocol Mutation: Event { }
public protocol ProcessingEvent: Event { }

public protocol Step: Event {}

public enum Steps {
    public final class Close: Step {
        fileprivate init() {}
    }
    @nonobjc public static let close: Step = Close()
}
