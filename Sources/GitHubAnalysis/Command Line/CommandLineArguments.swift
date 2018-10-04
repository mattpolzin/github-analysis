//
//  CommandLineArguments.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 9/29/18.
//  Copyright © 2018 Mathew Polzin. All rights reserved.
//

struct ArgumentValue {
    let value: String?

    var isTruthy: Bool {
        guard let val = value?.lowercased() else { return false }
        return val == "true"
            || val == "t"
            || val == "1"
            || val == "" // empty string is truthy for argument value because flags are often set simply by specifying the flag without a value (default is truthy for command args that are flags).
    }
}

protocol Arguments {
    /// Positional arguments are specified without dashes preceeding them and
    /// without any additional context following them. The order of these
    /// arguments matters because it is the only thing dictating what each
    /// argument means.
    var positionalArguments: [String] { get }

    /// Parameterized arguments begin with a dash and then the argument name.
    /// They are optionally followed by an equals sign and then a value offering
    /// additional context to the argument. Using a space rather than an equals
    /// sign is NOT currently a supported syntax.
    var parameterizedArguments: [String: ArgumentValue] { get }
}

struct CommandLineArguments {
    private let positionals: [String]
    private let parameterized: [String: ArgumentValue]

    init(argv: [String]) {
        let parameterizedPairs = argv
            .filter { $0.first == "-" }
            .map { $0.dropFirst() }
            .map { $0.split(separator: "=").map(String.init) }

        parameterized = parameterizedPairs.reduce(into: [String: ArgumentValue]()) { (res, next) in
            res[next[0]] = ArgumentValue(value: next.count == 2 ? next[1] : "")
        }

        positionals = argv
            .dropFirst() // the first argument is the script name
            .filter { $0.first != "-" }
    }
}

extension CommandLineArguments: Arguments {
    var positionalArguments: [String] {
        return positionals
    }

    var parameterizedArguments: [String : ArgumentValue] {
        return parameterized
    }
}
