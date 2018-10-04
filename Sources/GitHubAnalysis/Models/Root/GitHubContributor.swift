//
//  GitHubContributor.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/2/18.
//

import Foundation

struct GitHubContributor: Codable, Equatable {
    let author: GitHubUser
    let totalCommits: Int
    let weeklyStats: [Stats]

    enum CodingKeys: String, CodingKey {
        case author
        case totalCommits = "total"
        case weeklyStats = "weeks"
    }

    struct Stats: Equatable {
        let weekStart: Date
        let locAdded: Int
        let locDeleted: Int
        let commits: Int
    }
}

extension GitHubContributor: Hashable {
    var hashValue: Int {
        return author.id.hashValue
    }
}

/// This is just a GitHubContributor that knows which Repo it is from
struct RepoContributor: Equatable, Hashable {
    let repository: String
    let contributor: GitHubContributor
}

extension GitHubContributor.Stats: Codable {
    enum CodingKeys: String, CodingKey {
        case weekStart = "w"
        case locAdded = "a"
        case locDeleted = "d"
        case commits = "c"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        weekStart = try Date.init(timeIntervalSince1970: values.decode(TimeInterval.self, forKey: .weekStart))

        locAdded = try values.decode(Int.self, forKey: .locAdded)
        locDeleted = try values.decode(Int.self, forKey: .locDeleted)
        commits = try values.decode(Int.self, forKey: .commits)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(String(weekStart.timeIntervalSince1970), forKey: .weekStart)
        try container.encode(locAdded, forKey: .locAdded)
        try container.encode(locDeleted, forKey: .locDeleted)
        try container.encode(commits, forKey: .commits)
    }
}
