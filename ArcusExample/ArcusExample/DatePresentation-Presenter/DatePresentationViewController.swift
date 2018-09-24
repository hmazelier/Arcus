//
//  DatePresentationViewController.swift
//  ArcusExample
//
//  Created by Hadrien Mazelier on 21/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import UIKit
import Swinject
import SnapKit
import RxCocoa
import RxSwift

class DatePresentationViewController: UIViewController {
    
    private let resolver: Resolver
    
    lazy var output: DatePresentationReducerProtocol = { resolver.resolve(DatePresentationReducerProtocol.self)! }()
    
    private let dateLabel = UILabel()
    private let datePicker = UIDatePicker()
    
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
        watchViewModel()
        output.start()
    }
    
    
    private func createHierarchy() {
        view.addSubview(dateLabel)
        view.addSubview(datePicker)
    }
    
    private func createLayout() {
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(8)
        }
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.top).inset(20)
            make.left.right.bottom.equalToSuperview().inset(8)
        }
    }
    
    private func configureViews() {
        view.backgroundColor = .white
        
        datePicker.datePickerMode = .date
        
        dateLabel.textColor = .black
        dateLabel.font = UIFont(name: "AvenirNext-Bold", size: 20)
        dateLabel.textAlignment = .center
        dateLabel.numberOfLines = 0
                
    }
    
    private func connectActions() {
        datePicker.rx.date
            .map(DatePresentation.Actions.changeDate)
            .bind(to: self.output.actions)
            .disposed(by: disposeBag)
    }
    
    private func watchViewModel() {
        output.viewModel.date
            .bind(to: self.dateLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
