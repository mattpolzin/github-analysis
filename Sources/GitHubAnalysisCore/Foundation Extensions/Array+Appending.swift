//
//  File.swift
//  GitHubAnalysisCore
//
//  Created by Mathew Polzin on 11/2/18.
//

import Foundation

public extension Array {
	public func appending(_ newElement: Element) -> Array {
		return self + [newElement]
	}
	
	public func prepending(_ newElement: Element) -> Array {
		return [newElement] + self
	}
}
