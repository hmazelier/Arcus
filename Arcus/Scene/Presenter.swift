//
//  Presenter.swift
//  RxFlowScene
//
//  Created by Hadrien Mazelier on 20/04/2018.
//  Copyright © 2018 Hadrien Mazelier. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol Presenter: HasDisposeBag {
    associatedtype StateType: State
    associatedtype ViewModelType: ViewModel
    var disposeBag: DisposeBag { get set }
    func bind(state: Observable<StateType>, toViewModel viewModel: ViewModelType)
} 
