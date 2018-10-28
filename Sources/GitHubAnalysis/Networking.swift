//
//  Networking.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 10/27/18.
//

import Foundation
import Result

private var _requestsInFlight: Int = 0

/// Network namespace
enum Network {
	static func request(_ request: URLRequest, completion: @escaping (NetworkResult<Data>) -> Void) {
		_requestsInFlight += 1
		URLSession.shared.dataTask(with: request) { (maybeData, maybeResponse, error) in
			DispatchQueue.main.async {
				defer {
					_requestsInFlight -= 1
				}
				
				guard error == nil,
					let response = maybeResponse else {
						assert(maybeResponse != nil, "Documentation states response will be non-nil regardless of whether the request errored out or succeeded")
						completion(.failure(Error(error: error)))
						return
				}
				
				guard let data = maybeData else {
					completion(.failure(Error(response: response)))
					return
				}
				
				completion(.success(Response(data: data,
											 urlResponse: response)))
			}
		}.resume()
	}
	
	static var requestsInFlight: Int {
		return _requestsInFlight
	}
	
	struct Response<T> {
		let data: T
		let urlResponse: URLResponse
	}
	
	enum Error: Swift.Error, Equatable {
		case client(Client)
		case server(Server)
		case session(description: String, code: Int)
		case unknown
		
		init(rawValue: Int) {
			switch rawValue {
			case 400..<500:
				self = Client(rawValue: rawValue).map { .client($0) } ?? .unknown
			case 500..<600:
				self = Server(rawValue: rawValue).map { .server($0) } ?? .unknown
			default:
				self = .unknown
			}
		}
		
		init(error: Swift.Error?) {
			switch error {
			case let err as NSError:
				self = .session(description: err.localizedDescription, code: err.code)
			default:
				self = .unknown
			}
		}
		
		init(response: URLResponse) {
			switch response {
			case let httpResponse as HTTPURLResponse:
				self = Error(rawValue: httpResponse.statusCode)
			default:
				self = .unknown
			}
		}
		
		enum Client: Int, Equatable {
			case unauthorized = 401
			case forbidden = 403
			case missing = 404
			case notAllowed = 405
			case timeout = 408
		}
		
		enum Server: Int, Equatable {
			case internalError = 500
			case notImplemented = 501
		}
	}
}

typealias NetworkResult<T> = Result<Network.Response<T>, Network.Error>
