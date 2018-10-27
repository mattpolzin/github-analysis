//
//  Usage.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 9/30/18.
//

import Foundation

protocol UsageRule {
	static var description: String { get }
}

struct UsageCategory {
    let name: String
    let note: String?
    let rules: [UsageRule.Type]
}

typealias NoteRule = UsageRule

protocol EnvironmentRule: UsageRule {
	static var name: String { get }
	static var usage: String { get }

    /// Value Format describes how the value must be specified.
    /// For example, a date Value Format might be "YYYY-MM-DD"
	static var valueFormat: String { get }
}

protocol FlagRule: UsageRule {
	static var name: String { get }
	static var usage: String { get }
}

enum ArgumentRulePositioning: Equatable {
	case fixed
	case floating
}

protocol ArgumentRule: UsageRule {
	static var name: String { get }
	static var usage: String { get }

    /// Value Format describes how the value must be specified.
    /// For example, a date Value Format might be "YYYY-MM-DD"
	static var valueFormat: String { get }

    /// An argument can either be fixed or floating. Fixed
    /// arguments are specified by just including their values in
    /// the correct position. Floating arguments are specified
    /// by prepending a dash to the name followed by equals followed
    /// by the value.
	static var positioning: ArgumentRulePositioning { get }
}

protocol Usage {

    static var scriptName: String { get }

	static var categories: [UsageCategory] { get }
}

extension Usage {
    static var description: String {

		let fixedArgumentNames = Self
			.categories
			.flatMap { category in
				category
					.rules
					.compactMap { $0 as? ArgumentRule.Type }
					.filter { $0.positioning == .fixed }
					.map { $0.name }
		}

        return "\n" +
            "USAGE: \(Self.scriptName) [OPTIONS] " + fixedArgumentNames.joined(separator: " ") +
            "\n\n" +
			Self.categories.map { $0.description }
                .compactMap{ $0 }
                .joined(separator: "\n\n")
            + "\n\n"
    }
}

extension EnvironmentRule {
    static var description: String {
        return "\(Self.name)=\(Self.valueFormat)\n\(Self.usage)"
    }
}

extension FlagRule {
    static var description: String {
        return "-\(name)\n\(usage)"
    }
}

extension ArgumentRule {
    static var description: String {
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
        let contents = rules.reduce("", { "\($0)\n\n\($1.description)" })
        return "\(header)\(notes)\(contents)"
    }
}
