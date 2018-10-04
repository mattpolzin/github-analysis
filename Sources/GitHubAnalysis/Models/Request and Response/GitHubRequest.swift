//
//  GitHubRequest.swift
//  Alamofire
//
//  Created by Mathew Polzin on 9/29/18.
//

import Foundation

struct GitHubRequest {
    let urlRequest: URLRequest

    typealias AccessToken = String

    init(accessToken: AccessToken, url: URL) {
        var request = URLRequest(url: url)
        request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")

        urlRequest = request
    }

    static func events(with accessToken: AccessToken, from repository: String, ownedBy owner: String) -> GitHubRequest {
        return GitHubRequest(accessToken: accessToken, url: URL(string: "https://api.github.com/repos/\(owner)/\(repository)/events")!)
    }

    static func stats(with accessToken: AccessToken, for repository: String, ownedBy owner: String) -> GitHubRequest {
        return GitHubRequest(accessToken: accessToken, url: URL(string: "https://api.github.com/repos/\(owner)/\(repository)/stats/contributors")!)
    }
}
