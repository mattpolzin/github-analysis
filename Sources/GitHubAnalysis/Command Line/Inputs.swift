//
//  Inputs.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/23/18.
//

import Foundation

protocol InputUsage {
	static var usage: UsageRule.Type { get }
}

struct VoidInput<Rule: UsageRule>: InputUsage {
	static var usage: UsageRule.Type { return Rule.self }
}

struct Input<Input, Rule: UsageRule>: InputUsage {
	let value: Input
	static var usage: UsageRule.Type { return Rule.self }
}

struct InputCategory {
	let name: String
	let note: String?
}

protocol InputDescriptions {
	static var environmentInputs: [InputUsage.Type] { get }
	static var argumentInputs: [InputUsage.Type] { get }
	static var flagInputs: [InputUsage.Type] { get }
}

protocol InputCategoryDescriptions: InputDescriptions, Usage {
	
	static var notes: UsageCategory? { get }
	
	static var environmentInputUsage: InputCategory { get }
	
	static var argumentInputUsage: InputCategory { get }
	
	static var flagInputUsage: InputCategory { get }
}

extension InputCategoryDescriptions {
	static var categories: [UsageCategory] {
		return [
			notes,
			UsageCategory(name: environmentInputUsage.name,
						  note: environmentInputUsage.note,
						  rules: environmentInputs.map { $0.usage }),
			UsageCategory(name: argumentInputUsage.name,
						  note: argumentInputUsage.note,
						  rules: argumentInputs.map { $0.usage }),
			UsageCategory(name: flagInputUsage.name,
						  note: flagInputUsage.note,
						  rules: flagInputs.map { $0.usage })
			].compactMap { $0 }
	}
}
