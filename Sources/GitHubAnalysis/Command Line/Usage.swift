//
//  Usage.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 9/30/18.
//

import Foundation

protocol UsageRule: CustomStringConvertible {}

struct UsageCategory<Rule: UsageRule> {
    let name: String
    let note: String?
    let rules: [Rule]
}

typealias NoteRule = String

struct EnvironmentRule {
    let name: String
    let usage: String

    /// Value Format describes how the value must be specified.
    /// For example, a date Value Format might be "YYYY-MM-DD"
    let valueFormat: String
}

struct FlagRule {
    let name: String
    let usage: String
}

struct ArgumentRule {
    let name: String
    let usage: String

    /// Value Format describes how the value must be specified.
    /// For example, a date Value Format might be "YYYY-MM-DD"
    let valueFormat: String

    /// An argument can either be fixed or floating. Fixed
    /// arguments are specified by just including their values in
    /// the correct position. Floating arguments are specified
    /// by prepending a dash to the name followed by equals followed
    /// by the value.
    let positioning: Positioning

    enum Positioning: Equatable {
        case fixed
        case floating
    }
}

protocol Usage: CustomStringConvertible {

    var scriptName: String { get }

    var notes: UsageCategory<NoteRule>? { get }

    var environment: UsageCategory<EnvironmentRule> { get }

    var flags: UsageCategory<FlagRule> { get }

    var arguments: UsageCategory<ArgumentRule> { get }
}

extension Usage {
    var description: String {

        let fixedArgumentNames = arguments.rules.filter { $0.positioning == .fixed }.map { $0.name }

        return "\n" +
            "USAGE: \(scriptName) [OPTIONS] " + fixedArgumentNames.joined(separator: " ") +
            "\n\n" +
            [notes.map(String.init(describing:)),
             String(describing: environment),
             String(describing: flags),
             String(describing: arguments)]
                .compactMap{ $0 }
                .joined(separator: "\n\n")
            + "\n\n"
    }
}

extension NoteRule: UsageRule {}

extension EnvironmentRule: UsageRule {
    var description: String {
        return "\(name)=\(valueFormat)\n\(usage)"
    }
}

extension FlagRule: UsageRule {
    var description: String {
        return "-\(name)\n\(usage)"
    }
}

extension ArgumentRule: UsageRule {
    var description: String {
        let ret: String

        switch positioning {
        case .floating:
            ret = "-\(name)=\(valueFormat)\n\(usage)"
        case .fixed:
            ret = "\(name)  format: \"\(valueFormat)\"\n\(usage)"
        }

        return ret
    }
}

extension UsageCategory: CustomStringConvertible {
    var description: String {
        let header = "--------\n\(name)\n--------"
        let notes = note.map { "\n\n\($0)" } ?? ""
        let contents = rules.reduce("", { "\($0)\n\n\($1)" })
        return "\(header)\(notes)\(contents)"
    }
}
