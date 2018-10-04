# GitHubAnalysis

## Prerequisites & Dependencies
You need Swift 4.1+ and Swift Tools 4.0+.

Download Xcode, then install command line tools.

You will also need a GitHub personal access token. Generate one at https://github.com/settings/tokens. This can be specified as an argument when executing `github-analysis`, but it is most convenient to set the `GITHUB_ANALYSIS_TOKEN` environment variable.

### Package Dependencies
These dependencies will be downloaded and linked against automatically by the Swift Package Manager.

1. Alamofire

## Building
1. `swift package resolve`
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
You can choose to only analyse events occuring after a certain date.

`github-analysis owner repo --later-than=2018-09-15`

### Filter Users
You can specify a list of users to analyze and all other users that have contributed to the given repositories will be ignored.

`github-analysis owner repo --users=user1,user2,user3`
