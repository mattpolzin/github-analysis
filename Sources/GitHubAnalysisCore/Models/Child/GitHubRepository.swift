//
//  GitHubRepository.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/1/18.
//

public typealias RepositoryName = String

public struct GitHubRepository: Codable {
    public let id: Int
    public let name: RepositoryName
}
