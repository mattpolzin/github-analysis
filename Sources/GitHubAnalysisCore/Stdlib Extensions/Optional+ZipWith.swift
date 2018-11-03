//
//  Optional+ZipWith.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/28/18.
//

public func zip<W, T>(_ a: W?, _ b: W?, with fn: (W, W) -> T) -> Optional<T> {
	return a.flatMap { aPrime in
		return b.map { bPrime in
			return fn(aPrime, bPrime)
		}
	}
}
