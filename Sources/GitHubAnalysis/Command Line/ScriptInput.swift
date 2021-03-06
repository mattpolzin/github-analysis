//
//  ScriptInput.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 9/29/18.
//  Copyright © 2018 Mathew Polzin. All rights reserved.
//

import Foundation
import GitHubAnalysisCore
import Result

extension CommandLineArguments {
    init() {
        self.init(argv: CommandLine.arguments)
    }
}

struct ScriptInputs {
    let commandLineArguments = CommandLineArguments()

    /// Retrieve a named (i.e. floating) argument value.
    func variable(named name: String) -> String? {

        let envVar = ProcessInfo.processInfo.environment[name]
        let cmdVar = commandLineArguments.parameterizedArguments[name]

        return cmdVar?.value ?? envVar
    }

    /// Retrieve an array argument value with the given name.
    func array(named name: String) -> [String]? {
        return variable(named: name)?.split(separator: ",").map(String.init)
    }
	
	/// Retrieve a date argument value with the given name.
	func date(named name: String) -> InputResult<Date> {
		return InputResult(variable(named: name), failWith: .missing)
			.flatMap { variable in
				.init(GitHubAnalysisFormatter.datetime.date(from: variable) ?? GitHubAnalysisFormatter.date.date(from: variable),
					  failWith: .malformed(variable))
		}
	}

    /// Retrieve an unnamed (i.e. fixed) argument value. These values are
    /// only distinguishable by the order in which they are specified.
    func variable(at position: Int) -> String? {
        guard commandLineArguments.positionalArguments.count > position else {
            return nil
        }

        return commandLineArguments.positionalArguments[position]
    }

    /// Retrieve an array argument value at the given position.
    func array(at position: Int) -> [String]? {
        return variable(at: position)?.split(separator: ",").map(String.init)
    }

    func isFlagSet(named name: String) -> Bool {
        let envVarExists = ProcessInfo.processInfo.environment[name] != nil
        // cmd var exists unless it is unset or set with a false value
        let cmdVarExists = commandLineArguments.parameterizedArguments[name].map { $0.isTruthy } ?? false

        return envVarExists || cmdVarExists
    }
	
	enum InputError: Error {
		case missing
		case malformed(String)
	}
	
	typealias InputResult<T> = Result<T, InputError>
}
