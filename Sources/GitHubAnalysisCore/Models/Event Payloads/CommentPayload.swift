//
//  CommentPayload.swift
//  Alamofire
//
//  Created by Mathew Polzin on 9/29/18.
//

import Foundation

struct CommentPayload: Payload {
    let action: Action
    let comment: Comment
    let pullRequest: GitHubPullRequest

    enum CodingKeys: String, CodingKey {
        case action
        case comment
        case pullRequest = "pull_request"
    }

    enum Action: String, Codable, CodingKey {
        case created
        case edited
        case deleted
    }

    struct Comment: Codable {
        let user: GitHubUser
    }

    var userLogin: String? {
        return comment.user.login
    }

    var repositoryNames: [String] {
        return [pullRequest.head.repo.name, pullRequest.base.repo.name]
    }
}
