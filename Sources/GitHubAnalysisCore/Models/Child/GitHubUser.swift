//
//  GitHubUser.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/1/18.
//

public typealias Username = String

public struct GitHubUser: Codable, Equatable {
    public let login: Username
    public let id: Int
}
