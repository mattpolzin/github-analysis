//
//  Arithmetic.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/4/18.
//

public protocol Addable {
	static func +(lhs: Self, rhs: Self) -> Self
}

public protocol Arithmetic: Addable {
	static func -(lhs: Self, rhs: Self) -> Self
	static func /(lhs: Self, rhs: Self) -> Self
}

extension Int: Arithmetic {}
extension Float: Arithmetic {}
extension Double: Arithmetic {}
extension String: Addable {}
extension Array: Addable {}
