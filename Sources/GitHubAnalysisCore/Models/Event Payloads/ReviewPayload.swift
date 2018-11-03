//
//  ReviewPayload.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 9/30/18.
//

struct ReviewPayload: Payload {
    let action: Action
    let review: Review
    let pullRequest: GitHubPullRequest

    enum CodingKeys: String, CodingKey {
        case action
        case review
        case pullRequest = "pull_request"
    }

    enum Action: String, Codable, CodingKey {
        case submitted
        case edited
        case dismissed
    }

    struct Review: Codable {
        let user: GitHubUser
    }

    var userLogin: String? {
        return review.user.login
    }

    var repositoryNames: [String] {
        return [pullRequest.head.repo.name, pullRequest.base.repo.name]
    }
}
