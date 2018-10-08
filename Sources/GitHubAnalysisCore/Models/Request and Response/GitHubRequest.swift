//
//  GitHubRequest.swift
//  Alamofire
//
//  Created by Mathew Polzin on 9/29/18.
//

import Foundation

public struct GitHubRequest {
    public let urlRequest: URLRequest

    public typealias AccessToken = String

    public init(accessToken: AccessToken, url: URL) {
        var request = URLRequest(url: url)
        request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")

        urlRequest = request
    }

    public static func events(with accessToken: AccessToken, from repository: String, ownedBy owner: String) -> GitHubRequest {
        return GitHubRequest(accessToken: accessToken, url: URL(string: "https://api.github.com/repos/\(owner)/\(repository)/events")!)
    }

    public static func stats(with accessToken: AccessToken, for repository: String, ownedBy owner: String) -> GitHubRequest {
        return GitHubRequest(accessToken: accessToken, url: URL(string: "https://api.github.com/repos/\(owner)/\(repository)/stats/contributors")!)
    }
}
