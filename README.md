# GitHubAnalysis

[![Build Status](https://app.bitrise.io/app/63709d66684c9cf8/status.svg?token=UlFvp2pSDajsPtGI7rVroA)](https://app.bitrise.io/app/63709d66684c9cf8)

## Prerequisites & Dependencies
You need Swift 4.2+ and Swift Tools 4.2+.

Download Xcode, then install command line tools.

You will also need a GitHub personal access token. Generate one at https://github.com/settings/tokens. This can be specified as an argument when executing `github-analysis`, but it is most convenient to set the `GITHUB_ANALYSIS_TOKEN` environment variable.

At the moment you can only build GitHubAnalysis for platforms that Alamofire will build for, but in the future I will be removing that dependency so that the script can be run on Linux platforms as well.

### Package Dependencies
These dependencies will be downloaded and linked against automatically by the Swift Package Manager.

1. Result
2. SwiftCheck (only used by test targets)

## Building
1. `swift package update`
2. `swift build`

## Running
The `--help` option prints out help at the command line.

The script will create a cache file if it can in the current working directory. This cache file is not required, but if you maintain the cache file over time, the script will have more GitHub history to analyze than it is allowed to grab with the GitHub events API.

### Simplest Usage
The simplest usage is to run the script against one owner (i.e. a GitHub user or organization) and one or more repositories. This will run analysis on as many events as possible as far back in time as the GitHub events API will go (note it is limited to 90 days or 300 events per repository, whichever comes first).

Note that the owner slug must match the one in the webaddress for your repositories (do not use an email address).

`github-analysis owner repo1,repo2`

This will print stats out to the terminal.

### CSV File
You can generate a CSV file in addition to outputting stats to the terminal. The CSV file contains slightly more information and it can be a much more convenient format for looking at or manipulating the data.

`github-analysis owner repo1,repo2,repo3 --csv`

### Set Date Limit
You can choose to only analyze events occuring after a certain date (and/or before a certain date with `--earlier-than`).

`github-analysis owner repo --later-than=2018-09-15`

### Filter Users
You can specify a list of users to analyze and all other users that have contributed to the given repositories will be ignored.

`github-analysis owner repo --users=user1,user2,user3`

### Hide warning and caveat footnotes
By default, values will get annotated if there is a warning or a caveat to be aware of for the value. You can disable these footnotes to get cleaner output (perhaps to import into a spreadsheet and analyze further).

`github-analysis owner repo --skip-footnotes`

## Contributing
Please fork the repository and make any additions that suit your needs. I welcome Pull Requests back into this repository; I'm never too busy to maintain a pet project but I might get too busy to make valuable additions myself.

### General Notes
1. Do not add any Xcode project or environment files to the repository. The Xcode project should remain entirely buildable using Swift Package Manager (see Dev Env section below).
2. After adding new tests, run `swift test --generate-linuxmain` and commit the changes that script makes to the repository. This keeps unit testing on Linux in sync with unit testing on OS X.

### Dev Env
Just a note for anyone unfamiliar with the Swift Package Manager:

You can still do your development in Xcode, and I prefer to do so. Make sure that any Groups you create correlate to folders in the repository and the rest should be cake.
run `swift package generate-xcodeproj` to get a project set up on your machine.
