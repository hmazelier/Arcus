//
//  GithubUserExploreCoordinator.swift
//  ArcusExample
//
//  Created by Hadrien Mazelier on 24/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import Arcus
import Swinject

public protocol GithubUserExploreCoordinatorProtocol: Coordinator {}

enum GHUserExploreStep: Step {
    case showUserDetails(GithubStore.User)
}

final class GithubUserExploreCoordinator: GithubUserExploreCoordinatorProtocol {

    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    var root: UIViewController? {
        return nvc
    }
    
    private let nvc = UINavigationController()
    
    var parent: Coordinator?
    
    var children: [Coordinator] = []
    
    func handle(step: Step, from presentable: Presentable?) {
        switch step {
            case is Steps.Close:
                nvc.popViewController(animated: true)
            default: return
        }
    }
    
    func closeChild(coordinator: Coordinator, with step: Step?) {
        
    }
    
}
