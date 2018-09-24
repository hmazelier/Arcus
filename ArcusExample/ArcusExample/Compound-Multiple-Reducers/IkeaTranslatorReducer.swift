//
//  IkeaTranslatorReducer.swift
//  ArcusExample
//
//  Created by Hadrien Mazelier on 19/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import Arcus
import RxSwift
import RxCocoa

public enum IkeaTranslator {
    
    enum Actions: Arcus.Action {
        case changeQuery(String?)
    }
    
    enum Mutations: Arcus.Mutation {
        case changeTranslation(String)
    }
    
    struct State: Arcus.State {
        var translated = ""
    }
}

protocol IkeaTranslatorReducerProtocol {
    var state: BehaviorSubject<IkeaTranslator.State> { get }
    var actions: PublishRelay<Action> { get }
}

final class IkeaTranslatorReducer: Reducer, IkeaTranslatorReducerProtocol {
    private static let lettersMapping: [String: String] = [
        "a": "akv",
        "e": "elk",
        "i": "ijk",
        "o": "olp",
        "u": "uja",
        "y": "ysk",
    ]
    func provideInitialState() -> IkeaTranslator.State {
        return IkeaTranslator.State()
    }
    
    func produceEvent(from action: IkeaTranslator.Actions) -> Observable<Arcus.Event> {
        switch action {
        case .changeQuery(let query):
            let translated = (query ?? "").lowercased().map { char -> String in
                let char = String(char)
                return IkeaTranslatorReducer.lettersMapping[char] ?? char
            }.joined()
            
            return Observable.just(IkeaTranslator.Mutations.changeTranslation(translated))
        }
    }
    
    func reduce(state: IkeaTranslator.State, mutation: IkeaTranslator.Mutations) -> IkeaTranslator.State {
        var state = state
        
        switch mutation {
        case .changeTranslation(let translation):
            state.translated = translation
        }
        
        return state
    }
}
