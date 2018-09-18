//
//  AppDelegate.swift
//  Example
//
//  Created by Hadrien Mazelier on 18/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import UIKit
import Swinject
import SwinjectAutoregistration

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private let resolver: Resolver = {
        let container = Container()
        container.register(Resolver.self, factory: { _ -> Resolver in
            return container
        })
        container.autoregister(BasicCounterViewController.self, initializer: BasicCounterViewController.init)
        container.autoregister(BasicCounterReducerProtocol.self, initializer: BasicCounterReducer.init)
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        showBasicCounter()
        
        window.makeKeyAndVisible()
        return true
    }

    private func showBasicCounter() {
        let vc = resolver.resolve(BasicCounterViewController.self)
        window?.rootViewController = vc
    }
}

