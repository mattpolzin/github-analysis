//
//  PullRequestPayload.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 4/5/18.
//  Copyright © 2018 Mathew Polzin. All rights reserved.
//

import Foundation

struct PullRequestPayload: Payload {
    let action: Action
    let number: Int
    let pullRequest: GitHubPullRequest
    let merged: Bool?

    enum CodingKeys: String, CodingKey {
        case action
        case number
        case pullRequest = "pull_request"
        case merged
    }

    enum Action: String, Codable, CodingKey {
        case opened
        case closed
        case created
        case assigned
        case unassigned
        case review_requested
        case review_request_removed
        case labeled
        case unlabeled
        case edited
        case reopened
        case published
    }

    var userLogin: String? {
        return pullRequest.user.login
    }

    var repositoryNames: [String] {
        return [pullRequest.head.repo.name, pullRequest.base.repo.name]
    }
}
