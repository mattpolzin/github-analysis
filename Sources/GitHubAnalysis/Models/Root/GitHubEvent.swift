//
//  GitHubEvent.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 4/5/18.
//  Copyright © 2018 Mathew Polzin. All rights reserved.
//

import Foundation

enum EventType: String, CodingKey, Encodable {
    case pullRequest = "PullRequestEvent"
    case pullRequestComment = "PullRequestReviewCommentEvent"
    case pullRequestReview = "PullRequestReviewEvent"
    case notTracked

    var payloadType: Payload.Type {
        switch self {
        case .pullRequest:
            return PullRequestPayload.self
        case .pullRequestComment:
            return CommentPayload.self
        case .pullRequestReview:
            return ReviewPayload.self
        case .notTracked:
            return NotTrackedPayload.self
        }
    }

    // following not needed with Swift 4.2, just conform to CaseIterable
    static var allCases: [EventType] {
        return [.pullRequest, .pullRequestComment, .pullRequestReview, .notTracked]
    }
}

protocol Payload: Codable {
    /// Not all payloads are associated with users, but many of them are and it can be really convenient to access the
    /// user at the root rather than digging for it in different places.
    var userLogin: String? { get }

    /// The vast majority of payloads are associated with a repository.
    var repositoryNames: [String] { get }
}

struct GitHubEvent {
    let id: String
    let type: EventType
    let data: Payload
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case data = "payload"
        case createdAt = "created_at"
    }

    func payload<T: Payload>(as: T.Type) -> T? {
        return data as? T
    }

    func timestampedPayload<T: Payload>(as: T.Type) -> (time: Date, data: T)? {
        return (data as? T).map { (time: createdAt, data: $0) }
    }
}

extension GitHubEvent: Hashable {
    static func == (lhs: GitHubEvent, rhs: GitHubEvent) -> Bool {
        return lhs.id == rhs.id
    }

    var hashValue: Int {
        return id.hashValue
    }
}

extension GitHubEvent: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(String.self, forKey: .id)
        let pr: Payload? = (try? values.decode(PullRequestPayload.self, forKey: .data))
        let comm: Payload? = (try? values.decode(CommentPayload.self, forKey: .data))
        let rev: Payload? = (try? values.decode(ReviewPayload.self, forKey: .data))
        type = try values.decode(EventType.self, forKey: .type)

        if type != .notTracked {
            data = pr ?? comm ?? rev ?? NotTrackedPayload()
        } else {
            data = NotTrackedPayload()
        }

        guard let date = try GitHubAnalysisFormatter.datetime.date(from: values.decode(String.self, forKey: .createdAt)) else {
            throw DecodingError.typeMismatch(Date.self, .init(codingPath: [CodingKeys.createdAt], debugDescription: "The Created At Date (created_at) was not in the expected Date format."))
        }
        createdAt = date

        assert(type.payloadType == Swift.type(of: data), "\(type) ------- \(Swift.type(of: data))")
    }
}

extension GitHubEvent: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)

        switch data {
        case let pr as PullRequestPayload:
            try container.encode(pr, forKey: .data)
        case let comm as CommentPayload:
            try container.encode(comm, forKey: .data)
        case let rev as ReviewPayload:
            try container.encode(rev, forKey: .data)
        case is NotTrackedPayload:
            break
        default:
            assertionFailure("Missing an encode path for payloads on GitHubEvent")
            break
        }

        try container.encode(type, forKey: .type)
        try container.encode(GitHubAnalysisFormatter.datetime.string(from: createdAt), forKey: .createdAt)
    }
}

extension EventType: Decodable {
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)

        guard let type = EventType(rawValue: value) else {
            self = .notTracked
            return
        }

        self = type
    }
}
