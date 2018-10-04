//
//  GitHubUser.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/1/18.
//

typealias Username = String

struct GitHubUser: Codable, Equatable {
    let login: Username
    let id: Int
}
