//
//  Observable+surround.swift
//  Flow
//
//  Created by Hadrien Mazelier on 25/06/2018.
//  Copyright © 2018 nanoMe. All rights reserved.
//

import Foundation
import RxSwift

public extension Observable where Element: Event {
    public func surround<T: ProcessingEvent>(before: T, after: T) -> Observable<Event> where T: Equatable  {
        return self.map { $0 }
    }
}
