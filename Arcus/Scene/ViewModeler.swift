//
//  ViewModeler.swift
//  hFlow
//
//  Created by Hadrien Mazelier on 06/09/2018.
//  Copyright © 2018 HadrienMazelier. All rights reserved.
//

import Foundation

public protocol ViewModeler: ViewOutput {
    
    associatedtype PresenterType: Presenter
    
    var presenter: PresenterType { get }
}
