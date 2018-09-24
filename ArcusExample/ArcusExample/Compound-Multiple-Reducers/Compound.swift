//
//  Compound.swift
//  ArcusExample
//
//  Created by Hadrien Mazelier on 19/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import Arcus

enum Compound {
    
    enum Actions {
        case changeQuery(String?)
    }
    
    enum Mutations {
        case loadGithubUsers([GithubStore.User])
        case loadIkeaTranslation(String)
    }
    
    struct State: Equatable {
        var githubUsers: [GithubStore.User] = []
        var ikeaTranslation: String = ""
    }
    
}

extension Compound.Actions: Arcus.Action {}
extension Compound.Mutations: Arcus.Mutation {}
extension Compound.State: Arcus.State {}
