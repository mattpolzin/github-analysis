//
//  GitHubPullRequest.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/1/18.
//

struct GitHubPullRequest: Codable {
    let user: GitHubUser
    let head: Branch
    let base: Branch

    struct Branch: Codable {
        let repo: GitHubRepository
    }
}
