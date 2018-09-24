//
//  DatePresentationPresenter.swift
//  ArcusExample
//
//  Created by Hadrien Mazelier on 21/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Arcus

protocol DatePresentationPresenterProtocol {
    func bind(state: Observable<DatePresentation.State>, toViewModel viewModel: DatePresentation.ViewModel)
}

final class DatePresentationPresenter: DatePresentationPresenterProtocol {
    
    private var disposeBag = DisposeBag()
    
    func bind(state: Observable<DatePresentation.State>, toViewModel viewModel: DatePresentation.ViewModel) {
        
        let datePresenter = DateFormatter()
        datePresenter.dateStyle = .full
        state
            .map { $0.date }
            .distinctUntilChanged()
            .map { datePresenter.string(from: $0)}
            .bind(to: viewModel.date)
            .disposed(by: disposeBag)
    }
}
