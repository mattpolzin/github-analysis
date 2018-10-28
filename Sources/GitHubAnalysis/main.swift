//
//  main.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 4/5/18.
//  Copyright © 2018 Mathew Polzin. All rights reserved.
//

import Foundation
import GitHubAnalysisCore

// MARK: Read Input
let inputs: GitHubAnalysisInputs
switch GitHubAnalysisInputs.from(scriptInputs: ScriptInputs()) {
case .failure(.needHelp):
	print(GitHubAnalysisInputs.description)
	exit(0)
case .failure(.missingRequirement(description: let description)):
	print(description)
	exit(1)
case .success(let goodInputs):
	inputs = goodInputs
}

// MARK: Create Filters
let filters = GitHubAnalysisFilters(from: inputs)

// prepare cache file variables
let currentDirectory = FileManager.default.currentDirectoryPath
let defaultCacheFileLocation = URL(fileURLWithPath: currentDirectory).appendingPathComponent("github_analysis_cache").appendingPathExtension("json")

let cache = GitHubAnalysisCache(from: inputs, default: defaultCacheFileLocation)

if cache == nil {
    print("")
    print("The cache file at \(inputs[\.cacheFileLocation] ?? defaultCacheFileLocation) is either not readable or not writable. Analysis will continue without caching.")
    print("")
}

// MARK: Events and Stats Globals
var allEvents = Set<GitHubEvent>()
var allStats = Set<RepoContributor>()

// MARK: Runloop variables
let runLoop = RunLoop.current
let distantFuture = Date.distantFuture

// MARK: Functions
func readCache() {
	guard let readResult = cache?.read() else { return }
	
	switch readResult {
	case .failure(.fileError):
		print("Unexpected error opening cache file for reading. Continuing.")
	case .failure(.jsonError):
		print("")
		print("error trying to read cache data")
		print("")
	case .failure(.noData):
		print("No cache data found. Continuing.")
	case .success(let newEvents):
		let countBeforeCache = allEvents.count
		allEvents = allEvents.union(newEvents)
		
		print("\(allEvents.count - countBeforeCache) events loaded from cache.")
	}
}

func writeCache() {
	// we don't cache the allStats set. Stats appear
	// to always be fetched for all time from GitHub anyway
	// so we don't gain anything by caching them.
	guard let writeResult = cache?.write(events: allEvents) else { return }
	
	guard case .success = writeResult else {
		print("")
		print("error trying to write cache data")
		print("")
		return
	}
	
	print("\(allEvents.count) events written to the cache.")
}

func requestDataFromGitHub() {
	for repository in inputs[\.repositories] {
		// get new events
		let eventsRequest = GitHubRequest.events(with: inputs[\.personalAccessToken],
												 from: repository,
												 ownedBy: inputs[\.repositoryOwner])
			.urlRequest
		
		Network.request(eventsRequest, completion: handle(events:))
		
		// get all stats for each repo
		let statsRequest = GitHubRequest.stats(with: inputs[\.personalAccessToken],
											   for: repository,
											   ownedBy: inputs[\.repositoryOwner])
			.urlRequest
		
		Network.request(statsRequest) { handle(stats: $0, withRetryOn: repository) }
	}
}

func handle(events result: NetworkResult<Data>) {
    let nextLink: URL?

	guard case let .success(response) = result,
		let httpResponse = response.urlResponse as? HTTPURLResponse else {
			print("Failed to retrieve events from GitHub.")
			return
	}
	
	let headers = httpResponse.allHeaderFields
	
    if let header = headers["Link"] as? String {
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

    if inputs[\.printJSON] {
        print(String(data: response.data, encoding: .utf8)!)
    }

    let decoder = JSONDecoder()
    do {
        let newEvents = try decoder.decode([GitHubEvent].self, from: response.data)

        allEvents = allEvents.union(newEvents)

        guard let next = nextLink else {
            return
        }

		let request = GitHubRequest(accessToken: inputs[\.personalAccessToken],
									url: next).urlRequest
		
		Network.request(request, completion: handle(events:))

    } catch {
        print("error trying to convert events data to JSON")
    }
}

func handle(stats result: NetworkResult<Data>, withRetryOn repository: String) {
    if case let .success(response) = result,
		let httpResponse = response.urlResponse as? HTTPURLResponse,
		httpResponse.statusCode == 202 {
#if false
        // The following retry is crashing the compiler and I am out of patience for fixing it at the moment.
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            Alamofire.request(
                GitHubRequest.stats(with: inputs.personalAccessToken,
                                    for: repository,
                                    ownedBy: inputs.repositoryOwner)
                    .urlRequest
                ).responseData(completionHandler: { handle(stats: $0, repository: repository) })
        }
#else
        print("GitHub needs to process stats for \(repository). Run script again in a few minutes.")
#endif
        return
    }

    handle(stats: result, repository: repository)
}

func handle(stats result: NetworkResult<Data>, repository: String) {

    guard case let .success(response) = result else {
        print("Failed to get valid stats response from GitHub")
        return
    }

    if inputs[\.printJSON] {
        print(String(data: response.data, encoding: .utf8)!)
    }

    let decoder = JSONDecoder()
    do {
        let newStats = try decoder.decode([GitHubContributor].self, from: response.data)

        // order is important here. We want new stats to override old stats for the same user,
        // so allStats is unioned TO newStats rather than the other way around.
        allStats = Set(newStats.map{ RepoContributor(repository: repository, contributor: $0) }).union(allStats)

    } catch {
        print("error trying to convert stats data to JSON")
    }
}

func applyFilters() {
    // weed out all the events for repositories not being analyzed.
	// not necessary for stats because stats are grabbed fresh from API for each repo.
	// we need this step for events because the cache can contain events for repos not
	// being analyzed this time.
    allEvents = allEvents.filter { $0.data.repositoryNames.map(filters.repositories).contains(true) }

    print("\(allEvents.count) events across repositories: \(inputs[\.repositories].joined(separator: ", "))")
    print("\(allStats.count) (user, repository) pairings.")

    if let earliestDate = inputs[\.earliestDate] {

        // weed out all events earlier than earliest date
		allEvents = allEvents.filter { filters.earliestDate($0.createdAt) }

        print("    \(allEvents.count) events were newer than \(earliestDate)")

        // weed out all (user, repository) pairings earlier than earliest date
        allStats = Set(allStats.map { contributor in
            RepoContributor(repository: contributor.repository,
                            contributor: GitHubContributor(author: contributor.contributor.author,
                                                           allTimeTotalCommits: contributor.contributor.allTimeTotalCommits,
                                                           weeklyStats: contributor.contributor.weeklyStats.filter( { filters.earliestDate($0.weekStart) })))
        })
    }
	
	if let latestDate = inputs[\.latestDate] {
		
		// weed out all events later than latest date
		allEvents = allEvents.filter { filters.latestDate($0.createdAt) }
		
		print("    \(allEvents.count) events were older than \(latestDate)")
		
		// weed out all (user, repository) pairings later than latest date
		allStats = Set(allStats.map { contributor in
			RepoContributor(repository: contributor.repository,
							contributor: GitHubContributor(author: contributor.contributor.author,
														   allTimeTotalCommits: contributor.contributor.allTimeTotalCommits,
														   weeklyStats: contributor.contributor.weeklyStats.filter { filters.latestDate($0.weekStart) }))
		})
	}

    if let users = inputs[\.users]?.joined(separator: ", ") {
        // weed out all events for users not in the filter
        allEvents = allEvents.filter { $0.data.userLogin.map(filters.users) ?? true }

        print("    \(allEvents.count) events aftering filtering to: \(users)")

        // weed out all the contributions for users not in the filter
        allStats = allStats.filter { filters.users($0.contributor.author.login) }

        print("     \(allStats.count) (user, repository) pairings after filtering out users.")
    }
}

func startAnalysis() {
    print("")
    let timeSortedEvents = allEvents.sorted { $0.createdAt < $1.createdAt }
    timeSortedEvents.first.map { print("Earliest event: \($0.createdAt)") }
    timeSortedEvents.last.map { print("Latest event: \($0.createdAt)") }
    print("")
    let orgStats = aggregateStats(from: (events: Array(allEvents), gitStats: Array(allStats)), ownedBy: inputs[\.repositoryOwner])

    print("")

	let table = StatTable(orgStat: orgStats,
						  laterThan: inputs[\.earliestDate],
						  insertLimitFootnote: !inputs[\.skipFootnotes])
	
	func fillIfBlank(idx: Int, in array: [String]) -> String {
		return array.count > idx ? array[idx] : " "
	}
	
	for column in table.columnStack {
		for idx in 0..<max(column.0.count, column.1.count) {
			print("\(fillIfBlank(idx: idx, in: column.0)): \(fillIfBlank(idx: idx, in: column.1))")
		}
		print("")
	}

    if inputs[\.outputCSV] {
        print("")
        print("Writing CSV file to github_analysis.csv...")
        let csvUrl = URL(fileURLWithPath: currentDirectory).appendingPathComponent("github_analysis").appendingPathExtension("csv")
        do {
            try table.csvString.data(using: .utf8)?.write(to: csvUrl)
        } catch {
            print("Failed to write CSV File at: \(csvUrl.absoluteString)")
        }
		print("Done writing CSV file.")
    }
}

// MARK: Kickoff

readCache()

requestDataFromGitHub()

// wait for requests to finish
while Network.requestsInFlight > 0 &&
    runLoop.run(mode: RunLoop.Mode.default, before: distantFuture) {
//		print("Requests in flight: \(Network.requestsInFlight)")
}

writeCache()

if !inputs[\.skipAnalysis] {
	applyFilters()

	startAnalysis()
}
