//
//  NetworkClient.swift
//  SFTransitKit
//
//  Created on 2025-09-03.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol NetworkClient: Sendable {
    func fetchData(from url: URL) async throws -> Data
}

/// Production implementation of ``NetworkClient``
public struct URLSessionNetworkClient: NetworkClient {
    public init() { }
    
    public func fetchData(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
