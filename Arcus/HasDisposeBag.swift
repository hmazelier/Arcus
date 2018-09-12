//
//  HasDisposeBag.swift
//  Flow
//
//  Created by Hadrien Mazelier on 12/07/2018.
//  Copyright © 2018 nanoMe. All rights reserved.
//

import Foundation
import RxSwift

public protocol HasDisposeBag: AssociatedObjectStore { }
private var disposeBagKey = "disposeBag"
public extension HasDisposeBag {
    public var disposeBag: DisposeBag {
        get {
            return self.associatedObject(forKey: &disposeBagKey, default: DisposeBag())
        }
        set {
            self.setAssociatedObject(newValue, forKey: &disposeBagKey)
        }
    }
}
