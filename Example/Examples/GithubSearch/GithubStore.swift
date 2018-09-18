//
//  GithubStore.swift
//  Example
//
//  Created by Hadrien Mazelier on 18/09/2018.
//  Copyright © 2018 hadrienmazelier. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol GithubStoreProtocol {
    func searchUsers(_ query: String?) -> Observable<[GithubStore.User]>
}

private enum Routes: String {
    case searchUsers = "https://api.github.com/search/users"
}

final class GithubStore: GithubStoreProtocol {
    struct User: Decodable, Equatable {
        let id: Int
        let login: String
        let url: URL
    }
    private struct GithubResponse<T: Decodable>: Decodable {
        let items: [T]
    }
    
    func searchUsers(_ query: String?) -> Observable<[GithubStore.User]> {
        guard let query = query, query.isEmpty == false else { return .just([]) }
        let queryItem = URLQueryItem(name: "q", value: query)
        var urlComponent = URLComponents(string: Routes.searchUsers.rawValue)!
        urlComponent.queryItems = [queryItem]
        let request = URLRequest(url: urlComponent.url!)
        return URLSession.shared.rx.data(request: request).map({ data -> GithubResponse<GithubStore.User> in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GithubResponse<GithubStore.User>.self, from: data)
        })
        .map { $0.items }
    }
}

