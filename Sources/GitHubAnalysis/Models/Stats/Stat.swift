//
//  Stat.swift
//  Alamofire
//
//  Created by Mathew Polzin on 10/4/18.
//

public protocol Stat: CustomStringConvertible {
	/// A limitless Stat can be retrieved for any time window requested.
	/// Some Stats are not limitless beacuse some APIs only provide
	/// responses for a limited number of days into the past (with no
	/// ability to adjust the window of time). These APIs are more akin
	/// to firehoses, whether or not they technically are.
	static var limitless: Bool { get }
}

public extension Stat {
	var limitless: Bool { return Self.limitless }
}

public protocol Bound {}
public enum Limited: Bound {}
public enum Limitless: Bound {}

public struct BasicStat<B: Bound, Wrapped: CustomStringConvertible>: Stat {
	public static var limitless: Bool {
		return B.self == Limitless.self
	}
	
	public let value: Wrapped
	
	public var description: String {
		return String(describing: value)
	}
}

public typealias LimitedStat<Type: CustomStringConvertible> = BasicStat<Limited, Type>
public typealias LimitlessStat<Type: CustomStringConvertible> = BasicStat<Limitless, Type>

extension BasicStat: BasicStatMonad {
	public func map<T: CustomStringConvertible>(_ transform: (Wrapped) -> T) -> BasicStat<B, T> {
		return BasicStat<B, T>(value: transform(value))
	}
	
	public func flatMap<T: CustomStringConvertible>(_ transform: (Wrapped) -> BasicStat<B, T>) -> BasicStat<B, T> {
		return transform(value)
	}
	
	public func boundMap<NewB: Bound, T: CustomStringConvertible>(_ transform: (Wrapped) -> BasicStat<NewB, T>) -> BasicStat<NewB, T> {
		return transform(value)
	}
}

public func zip<B: Bound, T: CustomStringConvertible, U: CustomStringConvertible, V: CustomStringConvertible>(_ a: BasicStat<B, T>, _ b: BasicStat<B, U>, with transform: (T, U) -> V) -> BasicStat<B, V> {
	return a.flatMap { aValue in b.map { bValue in transform(aValue, bValue) }}
}

extension BasicStat: Addable where Wrapped: Addable {
	public static func +(lhs: BasicStat, rhs: BasicStat) -> BasicStat {
		return zip(lhs, rhs, with: +)
	}
	
	public static func +(lhs: BasicStat, rhs: Wrapped) -> BasicStat {
		return lhs.map { $0 + rhs }
	}
}

extension BasicStat: Arithmetic where Wrapped: Arithmetic {
	public static func -(lhs: BasicStat, rhs: BasicStat) -> BasicStat {
		return zip(lhs, rhs, with: -)
	}
	
	public static func -(lhs: BasicStat, rhs: Wrapped) -> BasicStat {
		return lhs.map { $0 - rhs }
	}
	
	public static func /(lhs: BasicStat, rhs: BasicStat) -> BasicStat {
		return zip(lhs, rhs, with: /)
	}
	
	public static func /(lhs: BasicStat, rhs: Wrapped) -> BasicStat {
		return lhs.map { $0 / rhs }
	}
}

extension BasicStat where Wrapped: RandomAccessCollection {
	var count: Int {
		return value.count
	}
}

extension Array {
	func reduce<B: Bound, T: CustomStringConvertible, U: CustomStringConvertible>(_ initialResult: BasicStat<B, T>,
																				  _ nextPartialResult: (T, U) -> T) -> BasicStat<B, T> where Element == BasicStat<B, U> {
		return reduce(initialResult) { res, next in zip(res, next, with: nextPartialResult) }
	}
}

extension BasicStat: ExpressibleByUnicodeScalarLiteral where Wrapped: ExpressibleByUnicodeScalarLiteral {
	public typealias UnicodeScalarLiteralType = Wrapped.UnicodeScalarLiteralType
	
	public init(unicodeScalarLiteral value: Wrapped.UnicodeScalarLiteralType) {
		self.init(value: Wrapped(unicodeScalarLiteral: value))
	}
}

extension BasicStat: ExpressibleByExtendedGraphemeClusterLiteral where Wrapped: ExpressibleByExtendedGraphemeClusterLiteral {
	public typealias ExtendedGraphemeClusterLiteralType = Wrapped.ExtendedGraphemeClusterLiteralType
	
	public init(extendedGraphemeClusterLiteral value: Wrapped.ExtendedGraphemeClusterLiteralType) {
		self.init(value: Wrapped(extendedGraphemeClusterLiteral: value))
	}
}

extension BasicStat: ExpressibleByStringLiteral where Wrapped: ExpressibleByStringLiteral {
	public typealias StringLiteralType = Wrapped.StringLiteralType
	
	public init(stringLiteral value: Wrapped.StringLiteralType) {
		self.init(value: Wrapped(stringLiteral: value))
	}
}

extension BasicStat: ExpressibleByIntegerLiteral where Wrapped: ExpressibleByIntegerLiteral {
	public typealias IntegerLiteralType = Wrapped.IntegerLiteralType

	public init(integerLiteral value: Wrapped.IntegerLiteralType) {
		self.init(value: Wrapped(integerLiteral: value))
	}
}

extension BasicStat: ExpressibleByFloatLiteral where Wrapped: ExpressibleByFloatLiteral {
	public typealias FloatLiteralType = Wrapped.FloatLiteralType
	
	public init(floatLiteral value: Wrapped.FloatLiteralType) {
		self.init(value: Wrapped(floatLiteral: value))
	}
}

extension BasicStat: ExpressibleByArrayLiteral where Wrapped: RangeReplaceableCollection {
	public typealias ArrayLiteralElement = Wrapped.Element
	
	public init(arrayLiteral elements: ArrayLiteralElement...) {
		self.init(value: Wrapped(elements))
	}
}

public protocol BasicStatMonad {
	associatedtype Wrapped: CustomStringConvertible
	associatedtype B: Bound
	
	func map<T: CustomStringConvertible>(_ transform: (Wrapped) -> T) -> BasicStat<B, T>
	
	func flatMap<T: CustomStringConvertible>(_ transform: (Wrapped) -> BasicStat<B, T>) -> BasicStat<B, T>
}
