//
//  main.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 4/5/18.
//  Copyright © 2018 Mathew Polzin. All rights reserved.
//

import Foundation
import Dispatch
import Alamofire

// MARK: Usage

struct GitHubAnalysisUsage: Usage {

    let scriptName = "github-analysis"

    let notes: UsageCategory<NoteRule>? = UsageCategory(name: "NOTES",
                                                        note: nil,
                                                        rules: [
                                                            "IMPORTANT:\nThe GitHub events API that powers much of this script's analysis is limited to returning 300 events or 90 days into the past, whichever comes first. This limit is per-repository.\n\nThis script caches events for later use so that over time you can build up a bigger picture than the limitation would allow for. That being said, it is important to look at the \"Limiting lower bound\" offered up at the command line and in the CSV. This lower bound is the earliest date for which an event was found in the repository with the least history available. In other words, take the earliest event date for each repository and pick the latest of those dates.\n\nMy recommendation is to not perform analysis back farther in time than the \"Limiting lower bound\" (using -\(kEarliestDateArg))"
        ])

    let environment = UsageCategory(name: "ENVIRONMENT VARIABLES",
                                    note: "These variables can also be specified as arguments by prepending their name with a dash: \"-VARNAME=VALUE\"",
                               rules: [
                                EnvironmentRule(name: kGithubAccessTokenVar,
                                                usage: "Generate a personal access token for GitHub and then set this environment variable to allow the script to download data for repositories for which you have access.",
                                                valueFormat: "1234567890abcdef")
        ])

    let flags = UsageCategory(name: "FLAGS",
                         note: nil,
                         rules: [
                            FlagRule(name: kPrintJSONFlag,
                                     usage: "Print the JSON response from GitHub before printing analysis results. This is mostly just useful for troubleshooting."),
                            FlagRule(name: kOutputCSVFlag,
                                     usage: "Generate a github_analysis.csv file in the current working directory"),
                            FlagRule(name: kHelpFlag,
                                     usage: "Print the usage.")
        ])

    let arguments = UsageCategory(name: "ARGUMENTS",
                                  note: nil,
                                  rules: [
                                    ArgumentRule(name: kOrganizationArg,
                                                 usage: "The organization or owner of the repository. This must match the slug that you find as a component of the web address for your repositories.",
                                                 valueFormat: "username",
                                                 positioning: .fixed),
                                    ArgumentRule(name: kRepositoriesArg,
                                                 usage: "Each repository listed will be analyzed.",
                                                 valueFormat: "repo1,repo2,repo3...",
                                                 positioning: .fixed),
                                    ArgumentRule(name: kEarliestDateArg,
                                                 usage: "Specify a datetime or a date that should be used as the cutoff before which GitHub data will not be analyzed.",
                                                 valueFormat: "{YYYY-MM-DDTHH:MM:SSZ | YYYY-MM-DD}",
                                                 positioning: .floating),
                                    ArgumentRule(name: kUsersArg,
                                                 usage: "Filter down to the given list of users for analysis. If not specified, all users will be analyzed.",
                                                 valueFormat: "user1,user2,user3...",
                                                 positioning: .floating)
        ])
}

let usage = GitHubAnalysisUsage()

// MARK: Setup

let inputs = Inputs()

guard !inputs.isFlagSet(named: kHelpFlag) else {
    print(String(describing: usage))
    exit(0)
}

guard let personalAccessToken = inputs.variable(named: kGithubAccessTokenVar) else {
    print("Missing GitHub Access Token. Please set \(kGithubAccessTokenVar) environment variable or specify on command line with -\(kGithubAccessTokenVar)={key}")
    exit(1)
}

guard let repositoryOwner = inputs.variable(at: kOrganizationArgPos) else {
    print("Missing required argument: \(kOrganizationArg). See --help for details.")
    exit(1)
}

guard let repositories = inputs.array(at: kRepositoriesArgPos) else {
    print("Missing required argument: \(kRepositoriesArg). See --help for details.")
    exit(1)
}

let usersFilter = { username in
    return inputs.array(named: kUsersArg)?.contains(username) ?? true
}

// prepare cache file
let currentDirectory = FileManager.default.currentDirectoryPath
let defaultCacheFileLocation = URL(fileURLWithPath: currentDirectory).appendingPathComponent("github_analysis_cache").appendingPathExtension("json")
let cacheFileLocation = inputs.variable(named: kCacheFileArg).map(URL.init(fileURLWithPath:))

func cacheFile(atURL url: URL) -> URL? {
    if !FileManager.default.fileExists(atPath: url.path) {
        do {
            try Data().write(to: url)
        } catch {
            return nil
        }
    }

    guard FileManager.default.isReadableFile(atPath: url.path) && FileManager.default.isWritableFile(atPath: url.path) else {
        return nil
    }

    return url
}

let cacheFileURL = cacheFileLocation.map { cacheFile(atURL: $0) } ?? cacheFile(atURL: defaultCacheFileLocation)

if cacheFileURL == nil {
    print("")
    print("The cache file at \(cacheFileLocation ?? defaultCacheFileLocation) is either not readable or not writable. Analysis will continue without caching.")
    print("")
}

// MARK: Date Formatters
let gitDatetimeFormatter = DateFormatter()
gitDatetimeFormatter.locale = Locale.init(identifier: "en_US_POSIX")
gitDatetimeFormatter.timeZone = TimeZone.init(identifier: "UTC")!
gitDatetimeFormatter.dateFormat = "yyyy-MM-dd'T'HH-mm-ss'Z'"

let gitDateFormatter = DateFormatter()
gitDateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
gitDateFormatter.dateFormat = "yyyy-MM-dd"


// MARK: Events and Stats Globals
var earliestDateFilter: Date?
var allEvents = Set<GitHubEvent>()
var allStats = Set<RepoContributor>()

// MARK: Runloop

var analysisRequestsInFlight = 0
let runLoop = RunLoop.current
let distantFuture = Date.distantFuture

// MARK: Functions
func readCache() {
    guard let url = cacheFileURL else { return }

    let cacheFileHandle: FileHandle

    do {
        cacheFileHandle = try FileHandle.init(forReadingFrom: url)
    } catch {
        print("Unexpected error opening cache file for reading. Continuing.")
        return
    }

    defer {
        cacheFileHandle.closeFile()
    }

    let cacheData = cacheFileHandle.readDataToEndOfFile()
    guard cacheData.count > 0 else {
        print("No cache data found. Continuing.")
        return
    }

    let decoder = JSONDecoder()
    do {
        let newEvents = try decoder.decode([GitHubEvent].self, from: cacheData)

        let countBeforeCache = allEvents.count
        allEvents = allEvents.union(newEvents)

        print("\(allEvents.count - countBeforeCache) events loaded from cache.")
    } catch {
        print("")
        print("error trying to read cache data")
        print("")
    }
}

func writeCache() {
    guard let url = cacheFileURL else { return }
    let encoder = JSONEncoder()

    do {
        // we don't cache the allStats set. Stats appear
        // to always be fetched for all time from GitHub anyway
        // so we don't gain anything by caching them.
        try encoder.encode(allEvents).write(to: url)
    } catch {
        print("")
        print("error trying to write cache data")
        print("")
    }
}

func handle(events response: DataResponse<Data>) {
    let nextLink: URL?

    if let headers = response.response?.allHeaderFields,
        let header = headers["Link"] as? String {
            do {
                let linkHeaders = try LinkHeaders(headerValue: header)

                nextLink = linkHeaders.links.first { $0.name == "next" }?.url
            } catch {
                print("GitHub returned invalid link URLs in headers")
                nextLink = nil
            }
    } else {
        nextLink = nil
    }

    guard let responseData = response.data else {
        print("Failed to get valid events response from GitHub")
        analysisRequestsInFlight -= 1
        return
    }

    if inputs.isFlagSet(named: kPrintJSONFlag) {
        print(String(data: responseData, encoding: .utf8)!)
    }

    let decoder = JSONDecoder()
    do {
        let newEvents = try decoder.decode([GitHubEvent].self, from: responseData)

        allEvents = allEvents.union(newEvents)

        guard let next = nextLink else {
            analysisRequestsInFlight -= 1
            return
        }

        Alamofire.request(
            GitHubRequest(accessToken: personalAccessToken,
                          url: next)
            .urlRequest
        ).responseData(completionHandler: handle(events:))

    } catch {
        print("error trying to convert events data to JSON")
        analysisRequestsInFlight -= 1
    }
}

func handle(stats response: DataResponse<Data>, withRetryOn repository: String) {
    if response.response?.statusCode == 202 {
#if false
        // The following retry is crashing the compiler and I am out of patience for fixing it at the moment.
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            Alamofire.request(
                GitHubRequest.stats(with: personalAccessToken,
                                    for: repository,
                                    ownedBy: repositoryOwner)
                    .urlRequest
                ).responseData(completionHandler: { handle(stats: $0, repository: repository) })
        }
#else
        analysisRequestsInFlight -= 1
        print("GitHub needs to process stats for \(repository). Run script again in a few minutes.")
#endif
        return
    }

    handle(stats: response, repository: repository)
}

func handle(stats response: DataResponse<Data>, repository: String) {
    defer {
        analysisRequestsInFlight -= 1
    }

    guard let responseData = response.data else {
        print("Failed to get valid stats response from GitHub")
        return
    }

    if inputs.isFlagSet(named: kPrintJSONFlag) {
        print(String(data: responseData, encoding: .utf8)!)
    }

    let decoder = JSONDecoder()
    do {
        let newStats = try decoder.decode([GitHubContributor].self, from: responseData)

        // order is important here. We want new stats to override old stats for the same user,
        // so allStats is unioned TO newStats rather than the other way around.
        allStats = Set(newStats.map{ RepoContributor(repository: repository, contributor: $0) }).union(allStats)

    } catch {
        print("error trying to convert stats data to JSON")
    }
}

func applyFilters() {
    // weed out all the events for repositories not being analyzed
    allEvents = allEvents.filter { $0.data.repositoryNames.map(repositories.contains).contains(true) }

    print("\(allEvents.count) events across repositories: \(repositories.joined(separator: ", "))")
    print("\(allStats.count) contributions.")

    if let earliestDateString = inputs.variable(named: kEarliestDateArg) {
        guard let earliestDate = gitDatetimeFormatter.date(from: earliestDateString) ?? gitDateFormatter.date(from: earliestDateString) else {
            fatalError("Please specify your datetimes in the UTC timezone in the format: YYYY-MM-DDTHH:MM:SSZ -- OR -- use dates of the format: YYYY-MM-DD")
        }
		
		earliestDateFilter = earliestDate

        // weed out all events earlier than earliest date
        allEvents = allEvents.filter { $0.createdAt >= earliestDate }

        print("    \(allEvents.count) events were newer than \(earliestDate)")

        // weed out all contributions earlier than earliest date
        allStats = Set(allStats.map { contributor in
            RepoContributor(repository: contributor.repository,
                            contributor: GitHubContributor(author: contributor.contributor.author,
                                                           totalCommits: contributor.contributor.totalCommits,
                                                           weeklyStats: contributor.contributor.weeklyStats.filter { $0.weekStart > earliestDate }))
        })
    }

    if let users = inputs.array(named: kUsersArg)?.joined(separator: ", ") {
        // weed out all events for users not in the filter
        allEvents = allEvents.filter { $0.data.userLogin.map(usersFilter) ?? true }

        print("    \(allEvents.count) events aftering filtering to: \(users)")

        // weed out all the contributions for users not in the filter
        allStats = allStats.filter { usersFilter($0.contributor.author.login) }

        print("     \(allStats.count) contributions after filtering out users.")
    }
}

func startAnalysis() {
    print("")
    let timeSortedEvents = allEvents.sorted { $0.createdAt < $1.createdAt }
    timeSortedEvents.first.map { print("Earliest event: \($0.createdAt)") }
    timeSortedEvents.last.map { print("Latest event: \($0.createdAt)") }
    print("")
    let orgStats = aggregateStats(from: (events: Array(allEvents), gitStats: Array(allStats)), ownedBy: repositoryOwner)

    print("")

	let table = StatTable(orgStat: orgStats, earliestDateFilter: earliestDateFilter)
	
	func fillIfBlank(idx: Int, in array: [String]) -> String {
		return array.count > idx ? array[idx] : " "
	}
	
	for column in table.columnStack {
		for idx in 0..<max(column.0.count, column.1.count) {
			print("\(fillIfBlank(idx: idx, in: column.0)): \(fillIfBlank(idx: idx, in: column.1))")
		}
		print("")
	}

    if inputs.isFlagSet(named: kOutputCSVFlag) {
        print("")
        print("Writing CSV file to github_analysis.csv...")
        let csvUrl = URL(fileURLWithPath: currentDirectory).appendingPathComponent("github_analysis").appendingPathExtension("csv")
        do {
            try table.csvString.data(using: .utf8)?.write(to: csvUrl)
        } catch {
            print("Failed to write CSV File at: \(csvUrl.absoluteString)")
        }
    }
}

// MARK: Kickoff

// read cache
readCache()

for repository in repositories {
    // get new events
    analysisRequestsInFlight += 1
    Alamofire.request(
        GitHubRequest.events(with: personalAccessToken,
                             from: repository,
                             ownedBy: repositoryOwner)
        .urlRequest
    ).responseData(completionHandler: handle(events:))

    // get all contributors
    analysisRequestsInFlight += 1
    Alamofire.request(
        GitHubRequest.stats(with: personalAccessToken,
                            for: repository,
                            ownedBy: repositoryOwner)
            .urlRequest
    ).responseData{ handle(stats: $0, withRetryOn: repository) }
}

// wait for requests to finish
while analysisRequestsInFlight > 0 &&
    runLoop.run(mode: .defaultRunLoopMode, before: distantFuture) {}

// write cache
writeCache()

// apply filters
applyFilters()

// analyze data
startAnalysis()
