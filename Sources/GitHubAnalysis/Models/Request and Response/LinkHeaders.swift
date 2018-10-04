//
//  LinkHeaders.swift
//  Alamofire
//
//  Created by Mathew Polzin on 9/29/18.
//

import Foundation

struct LinkHeaders {
    let links: [Link]

    init(headerValue: String) throws {
        // split on comma, then semicolon because links are separated by comma and link components are separated by semicolon
        let linkStrings = headerValue.split(separator: ",").map { $0.split(separator: ";") }

        links = try linkStrings.map { linkComponentString in
            let linkString = String(linkComponentString[0]
                .trimmingCharacters(in: .whitespaces)
                .dropFirst()
                .dropLast())

            let tmp = linkComponentString[1]
            let linkName = tmp.suffix(from: tmp.index(tmp.startIndex, offsetBy: 6))
                .dropLast()

            guard let link = URL(string: linkString).map({ Link(url: $0, name: String(linkName)) }) else {
                throw Error.badURL
            }

            return link
        }
    }

    struct Link {
        let url: URL
        let name: String
    }

    enum Error: Swift.Error {
        case badURL
    }
}
