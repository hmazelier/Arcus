//
//  CompoundViewController.swift
//  ArcusExample
//
//  Created by Hadrien Mazelier on 19/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import UIKit
import Swinject
import SnapKit
import RxCocoa
import RxSwift
import Arcus

class CompoundViewController: UIViewController {
    
    private let resolver: Resolver
    
    lazy var output: CompoundReducerProtocol = { resolver.resolve(CompoundReducerProtocol.self)! }()
    
    private let textField = UITextField()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    private let ikeaLabel = UILabel()
    
    private var rows: [GithubStore.User] = [] // Please use datasource, this is just for example
    
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
        watchProcessingEvents()
        rx
            .methodInvoked(#selector(viewDidAppear(_:)))
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.textField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        output.start()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    private func createHierarchy() {
        view.addSubview(textField)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(ikeaLabel)
    }
    
    private func createLayout() {
        textField.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(100)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
        ikeaLabel.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.height.equalTo(200)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    private func configureViews() {
        textField.font = UIFont(name: "AvenirNext-Medium", size: 30)
        textField.textAlignment = .center
        textField.placeholder = "Search for a user on Github"
        textField.textColor = .white
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.tintColor = .white
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        
        activityIndicator.hidesWhenStopped = true
        
        ikeaLabel.font = UIFont(name: "AvenirNext-Medium", size: 30)
        ikeaLabel.textAlignment = .center
        ikeaLabel.textColor = .white
    }
    
    private func connectActions() {
        textField.rx.text
            .distinctUntilChanged()
            .throttle(0.6, scheduler: MainScheduler.asyncInstance) // be kind with github
            .map(Compound.Actions.changeQuery)
            .bind(to: output.actions)
            .disposed(by: disposeBag)
    }
    
    private func watchState() {
        let state = output.state
            .distinctUntilChanged()
            .share(replay: 1)
        
        state
            .map { $0.githubUsers }
            .subscribe(onNext: { [weak self] users in
                self?.rows = users
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        state
            .map { $0.ikeaTranslation }
            // Any presentation work should be done in a specialized class, only for example. See Viewmodeler
            .map({ str -> NSAttributedString in
                let attributed = NSMutableAttributedString(string: "Ikea translation : ",
                                                           attributes: [
                                                            NSAttributedStringKey.font : UIFont(name: "AvenirNext-Medium", size: 12)!,
                                                            NSAttributedStringKey.foregroundColor : UIColor.lightGray
                ])
                let translation = NSAttributedString(string: str, attributes: [
                    NSAttributedStringKey.font : UIFont(name: "AvenirNext-Medium", size: 30)!,
                    NSAttributedStringKey.foregroundColor : UIColor.white
                ])
                attributed.append(translation)
                return attributed
            })
            .bind(to: self.ikeaLabel.rx.attributedText)
            .disposed(by: disposeBag)
    }
    
    private func watchProcessingEvents() {
        output.processingEvents
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] event in
                self?.handleProcessingEvent(event)
            }).disposed(by: disposeBag)
    }
    
    private func handleProcessingEvent(_ event: ProcessingEvent) {
        switch event {
        case GithubSearch.ProcessingEvent.searching(let isSearching):
            tableView.alpha = isSearching ? 0.7 : 1
            if isSearching {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        case GithubSearch.ProcessingEvent.failure:
            let alert = UIAlertController(title: "Error", message: "Something went wrong. Try again !", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK!", style: .default, handler: nil))
            //===> This presentation should be delegated to the coordinator, of course ! Just for the example
            self.present(alert, animated: true, completion: nil)
        default: return
        }
    }
}

extension CompoundViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil) // of course, dequeue the fucking cell...
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = rows[indexPath.row].login
        return cell
    }
}
