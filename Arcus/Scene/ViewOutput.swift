//
//  ViewOutput.swift
//  Arcus
//
//  Created by Hadrien Mazelier on 06/09/2018.
//  Copyright © 2018 HadrienMazelier. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol ViewOutput {
    associatedtype ViewModelType: ViewModel
    var viewModel: ViewModelType { get }
}
