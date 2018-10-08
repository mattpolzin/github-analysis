//
//  GitHubContributor.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/2/18.
//

import Foundation

public struct GitHubContributor: Codable, Equatable {
    public let author: GitHubUser
    public let allTimeTotalCommits: Int
    public let weeklyStats: [Stats]

    private enum CodingKeys: String, CodingKey {
        case author
        case allTimeTotalCommits = "total"
        case weeklyStats = "weeks"
    }

    public struct Stats: Equatable {
        public let weekStart: Date
        public let locAdded: Int
        public let locDeleted: Int
        public let commits: Int
    }
	
	public init(author: GitHubUser, allTimeTotalCommits: Int, weeklyStats: [Stats]) {
		self.author = author
		self.allTimeTotalCommits = allTimeTotalCommits
		self.weeklyStats = weeklyStats
	}
}

extension GitHubContributor: Hashable {
    public var hashValue: Int {
        return author.id.hashValue
    }
}

/// This is just a GitHubContributor that knows which Repo it is from
public struct RepoContributor: Equatable, Hashable {
    public let repository: String
    public let contributor: GitHubContributor
	
	public init(repository: String, contributor: GitHubContributor) {
		self.repository = repository
		self.contributor = contributor
	}
}

extension GitHubContributor.Stats: Codable {
    private enum CodingKeys: String, CodingKey {
        case weekStart = "w"
        case locAdded = "a"
        case locDeleted = "d"
        case commits = "c"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        weekStart = try Date.init(timeIntervalSince1970: values.decode(TimeInterval.self, forKey: .weekStart))

        locAdded = try values.decode(Int.self, forKey: .locAdded)
        locDeleted = try values.decode(Int.self, forKey: .locDeleted)
        commits = try values.decode(Int.self, forKey: .commits)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(String(weekStart.timeIntervalSince1970), forKey: .weekStart)
        try container.encode(locAdded, forKey: .locAdded)
        try container.encode(locDeleted, forKey: .locDeleted)
        try container.encode(commits, forKey: .commits)
    }
}
