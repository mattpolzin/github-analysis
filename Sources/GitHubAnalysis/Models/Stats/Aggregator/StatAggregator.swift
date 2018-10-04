//
//  StatAggregator.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/3/18.
//

import Foundation

func aggregateStats(from gitData: (events: [GitHubEvent], gitStats: [RepoContributor]), ownedBy orgName: String) -> OrgStat {
    var userStatsByUser = [RepositoryUserKey: UserStat]()

    let (events, gitStats) = gitData

    // most efficient way to track open dates to calcuate open lengths is just to
    // store them per user as they come up
    var prOpenDatesByPRNumber = [RepositoryPRKey: Date]()

    for event in events {
        switch event.data {
        case let prPayload as PullRequestPayload:
            let username = prPayload.pullRequest.user.login
            let prKey = RepositoryPRKey(repo: prPayload.pullRequest.base.repo.name, prNumber: prPayload.number)
            let userKey = RepositoryUserKey(repo: prKey.repo, username: username)

            userStatsByUser[userKey, default: UserStat()].update(earliestEvent: event.createdAt)

            switch prPayload.action {
            case .opened:
                userStatsByUser[userKey, default: UserStat()] += .opened
                prOpenDatesByPRNumber[prKey] = event.createdAt
            case .closed:
                userStatsByUser[userKey, default: UserStat()] += .closed(at: event.createdAt, with: prOpenDatesByPRNumber[prKey])
            default:
                // we do not currently aggregate on all available PR actions
                break
            }

        case let commentPayload as CommentPayload:
            let username = commentPayload.comment.user.login
            let repository = commentPayload.pullRequest.base.repo.name
            let userKey = RepositoryUserKey(repo: repository, username: username)

            userStatsByUser[userKey, default: UserStat()].update(earliestEvent: event.createdAt)

            guard commentPayload.action == .created else {
                break
            }

            userStatsByUser[userKey, default: UserStat()] += .commented

        default:
            // we do not aggregate all payload types
            break
        }
    }

    for stat in gitStats {
        let userKey = RepositoryUserKey(repo: stat.repository, username: stat.contributor.author.login)
        for week in stat.contributor.weeklyStats {
            userStatsByUser[userKey, default: UserStat()] += UserStat.CodeStat(linesAdded: week.locAdded,
                                                                               linesDeleted: week.locDeleted,
                                                                               commits: week.commits)
        }
    }

    // take stats keyed by repo and user and turn into arrays of user stats keyed by repo
    var usersByRepo = [RepositoryName: [Username: UserStat]]()
    for kv in userStatsByUser {
        usersByRepo[kv.key.repo, default: [:]][kv.key.username, default: UserStat()] = kv.value
    }

    let repoStats = usersByRepo.map { kv in (kv.key, RepoStat(repoName: kv.key, userStats: kv.value)) }

    return OrgStat(orgName: orgName, repoStats: Dictionary(repoStats, uniquingKeysWith: { v, _ in v }))
}

private struct RepositoryPRKey: Equatable, Hashable {
    let repo: RepositoryName
    let prNumber: Int
}

private struct RepositoryUserKey: Equatable, Hashable {
    let repo: RepositoryName
    let username: Username
}
