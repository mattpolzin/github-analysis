//
//  GitHubRepository.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/1/18.
//

typealias RepositoryName = String

struct GitHubRepository: Codable {
    let id: Int
    let name: RepositoryName
}
