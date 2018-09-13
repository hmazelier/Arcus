//
//  Observable+surround.swift
//  Flow
//
//  Created by Hadrien Mazelier on 25/06/2018.
//  Copyright © 2018 nanoMe. All rights reserved.
//

import Foundation
import RxSwift

public extension Observable {
    public func concatJust(_ element: Element) -> Observable<Element> {
        return self.concat(Observable.just(element))
    }
}

public extension Observable {
    public func tryMap<T>(to type: T.Type) -> Observable<T> {
        return flatMap({ e -> Observable<T> in
            if let e = e as? T {
                return .just(e)
            } else {
                return .empty()
            }
        })
    }
}
