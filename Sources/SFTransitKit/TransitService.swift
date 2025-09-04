//
//  TransitService.swift
//  SFTransitKit
//
//  Created on 2025-09-03.
//

import Foundation

/// Protocol defining the transit data repository operations
public protocol TransitService: Sendable {
    /// Fetches lines for a specific operator
    func fetchLines(_ operatorCode: OperatorCode) async throws -> [Line]
    
    /// Fetches stops for a specific line and operator
    func fetchStops(_ operatorCode: OperatorCode, line: LineCode) async throws -> [Stop]
    
    /// Fetches real-time forecasts for a specific stop
    func fetchRealtime(_ stopID: StopCode, operatorID: OperatorCode) async -> Result<[TripForecast], Error>
}
