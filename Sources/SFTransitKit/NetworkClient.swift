//
//  NetworkClient.swift
//  SFTransitKit
//
//  Created on 2025-09-03.
//

import Foundation

protocol NetworkClient: Sendable {
    func fetchData(from url: URL) async throws -> Data
}

/// Production implementation of ```NetworkClient```
struct URLSessionNetworkClient: NetworkClient {
    func fetchData(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
