//
//  GitHubAnalysisCache.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/6/18.
//

import Foundation
import GitHubAnalysisCore
import Result

struct GitHubAnalysisCache {
	let fileUrl: URL
	
	init?(from inputs: GitHubAnalysisInputs, default defaultCacheFileLocation: URL) {
		let cacheFileUrl = inputs
			.cacheFileLocation
			.map { GitHubAnalysisCache.validCacheURL(forURL: $0) } ?? GitHubAnalysisCache.validCacheURL(forURL: defaultCacheFileLocation)
		
		guard let fileUrl = cacheFileUrl else {
			return nil
		}
		
		self.fileUrl = fileUrl
	}
	
	func read() -> Result<[GitHubEvent], CacheError> {
		
		let cacheFileHandle: FileHandle
		
		do {
			cacheFileHandle = try FileHandle.init(forReadingFrom: fileUrl)
		} catch {
			return .failure(.fileError)
		}
		
		defer {
			cacheFileHandle.closeFile()
		}
		
		let cacheData = cacheFileHandle.readDataToEndOfFile()
		guard cacheData.count > 0 else {
			return .failure(.noData)
		}
		
		let decoder = JSONDecoder()
		
		return Result(try? decoder.decode([GitHubEvent].self, from: cacheData), failWith: .jsonError)
	}
	
	func write<S: Sequence & Encodable>(events: S) -> Result<Void, CacheError> where S.Element == GitHubEvent {
		
		let encoder = JSONEncoder()
		
		return Result(try? encoder.encode(events), failWith: .jsonError).flatMap { jsonData in
			return Result(try? jsonData.write(to: fileUrl), failWith: .fileError)
		}
	}
	
	enum CacheError: Error {
		case fileError
		case jsonError
		case noData
	}
}

extension GitHubAnalysisCache {
	/// Returns the given URL if it is a valid cache location or nil if the
	/// given URL cannot be used as a cache.
	private static func validCacheURL(forURL url: URL) -> URL? {
		if !FileManager.default.fileExists(atPath: url.path) {
			do {
				try Data().write(to: url)
			} catch {
				return nil
			}
		}
		
		guard FileManager.default.isReadableFile(atPath: url.path) && FileManager.default.isWritableFile(atPath: url.path) else {
			return nil
		}
		
		return url
	}
}
