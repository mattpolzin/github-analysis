//
//  Inputs.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/23/18.
//

import Foundation

protocol InputUsage {
	associatedtype Rule: UsageRule
	
	var usage: Rule { get }
}

private class _AnyInputUsageBase<Rule: UsageRule>: InputUsage {
	init() {
		guard type(of: self) != _AnyInputUsageBase.self else {
			fatalError("_AnyInputBase cannot be instantiated. It is abstract.")
		}
	}
	
	var usage: Rule {
		fatalError("_AnyInputBase cannot be used directly. It is abstract.")
	}
}

private class _AnyInputUsageBox<Rule: InputUsage>: _AnyInputUsageBase<Rule.Rule> {
	let concrete: Rule
	
	init(_ boxed: Rule) {
		self.concrete = boxed
	}
	
	override var usage: Rule.Rule {
		return concrete.usage
	}
}

class AnyInputUsage<Rule: UsageRule>: InputUsage {
	private let box: _AnyInputUsageBase<Rule>
	
	init<IRule: InputUsage>(_ concrete: IRule) where IRule.Rule == Rule {
		box = _AnyInputUsageBox(concrete)
	}
	
	var usage: Rule {
		return box.usage
	}
}

struct VoidInput<Rule: UsageRule>: InputUsage {
	let usage: Rule
}

struct Input<Input, Rule: UsageRule>: InputUsage {
	let value: Input
	let usage: Rule
}

struct InputCategory {
	let name: String
	let note: String?
}

protocol InputDescriptions {
	var environmentInputs: [AnyInputUsage<EnvironmentRule>] { get }
	var argumentInputs: [AnyInputUsage<ArgumentRule>] { get }
	var flagInputs: [AnyInputUsage<FlagRule>] { get }
}

protocol InputCategoryDescriptions: InputDescriptions, Usage {
	var scriptName: String { get }
	
	var notes: UsageCategory<NoteRule>? { get }
	
	var environmentInputUsage: InputCategory { get }
	
	var argumentInputUsage: InputCategory { get }
	
	var flagInputUsage: InputCategory { get }
}

extension InputCategoryDescriptions {
	var environment: UsageCategory<EnvironmentRule> {
		return UsageCategory(name: environmentInputUsage.name,
							 note: environmentInputUsage.note,
							 rules: environmentInputs.map { $0.usage })
	}
	
	var arguments: UsageCategory<ArgumentRule> {
		return UsageCategory(name: argumentInputUsage.name,
							 note: argumentInputUsage.note,
							 rules: argumentInputs.map { $0.usage })
	}
	
	var flags: UsageCategory<FlagRule> {
		return UsageCategory(name: flagInputUsage.name,
							 note: flagInputUsage.note,
							 rules: flagInputs.map { $0.usage })
	}
}
