//
//  NotTrackedPayload.swift
//  GitHubAnalysis
//
//  Created by Mathew Polzin on 9/29/18.
//

import Foundation

struct NotTrackedPayload: Payload {
    var userLogin: String? {
        return nil
    }

    var repositoryNames: [String] {
        return []
    }
}
