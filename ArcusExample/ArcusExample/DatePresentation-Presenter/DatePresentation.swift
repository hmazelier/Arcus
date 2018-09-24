//
//  DatePresentation.swift
//  ArcusExample
//
//  Created by Hadrien Mazelier on 21/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import Arcus
import RxSwift
import RxCocoa

enum DatePresentation {
    
    enum Actions {
        case changeDate(Date)
    }
    
    enum Mutations {
        case changeDate(Date)
    }
    
    struct State {
        var date = Date()
    }
    
    struct ViewModel {
        let date = PublishRelay<String>()
    }
    
}

extension DatePresentation.Actions: Arcus.Action {}
extension DatePresentation.Mutations: Arcus.Mutation {}
extension DatePresentation.State: Arcus.State {}
extension DatePresentation.ViewModel: Arcus.ViewModel {}
