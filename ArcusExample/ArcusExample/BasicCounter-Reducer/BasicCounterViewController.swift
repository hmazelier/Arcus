//
//  BasicCounterViewController.swift
//  Example
//
//  Created by Hadrien Mazelier on 18/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import UIKit
import Swinject
import SnapKit
import RxCocoa
import RxSwift

class BasicCounterViewController: UIViewController {
    
    private let resolver: Resolver
    
    lazy var output: BasicCounterReducerProtocol = { resolver.resolve(BasicCounterReducerProtocol.self)! }()
    
    private let incrementButton = UIButton()
    private let counterLaber = UILabel()
    private let decrementButton = UIButton()
    
    init(resolver: Resolver) {
        self.resolver = resolver
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createHierarchy()
        createLayout()
        configureViews()
        connectActions()
        watchState()
        output.start()
    }
    
    
    private func createHierarchy() {
        view.addSubview(incrementButton)
        view.addSubview(counterLaber)
        view.addSubview(decrementButton)
    }
    
    private func createLayout() {
        counterLaber.snp.makeConstraints { $0.center.equalToSuperview() }
        incrementButton.snp.makeConstraints { make in
            make.bottom.equalTo(counterLaber.snp.top).inset(-20)
            make.centerX.equalToSuperview()
        }
        decrementButton.snp.makeConstraints { make in
            make.top.equalTo(counterLaber.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    private func configureViews() {
        incrementButton.setTitle("INCREMENT (+)", for: .normal)
        counterLaber.textColor = .white
        decrementButton.setTitle("DECREMENT (-)", for: .normal)
    }
    
    private func connectActions() {
        Observable.of(incrementButton.rx.tap.map { BasicCounter.Actions.increment },
                      decrementButton.rx.tap.map { BasicCounter.Actions.decrement })
            .merge()
            .bind(to: output.actions)
            .disposed(by: disposeBag)
    }
    
    private func watchState() {
        output.state
            .map { "\($0.count)" }
            .bind(to: self.counterLaber.rx.text)
            .disposed(by: disposeBag)
    }
}

