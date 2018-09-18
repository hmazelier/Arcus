//
//  GithubSearch.swift
//  Example
//
//  Created by Hadrien Mazelier on 18/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import Arcus

enum GithubSearch {
    
    enum Actions {
        case changeQuery(String?)
    }
    
    enum Mutations {
        case loadResults([GithubStore.User])
    }
    
    enum ProcessingEvent {
        case searching(Bool)
        case failure
    }
    
    struct State: Equatable {
        var users: [GithubStore.User] = []
    }
    
}

extension GithubSearch.Actions: Arcus.Action {}
extension GithubSearch.Mutations: Arcus.Mutation {}
extension GithubSearch.ProcessingEvent: Arcus.ProcessingEvent {}
extension GithubSearch.State: Arcus.State {}
