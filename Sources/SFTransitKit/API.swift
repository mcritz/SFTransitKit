//
//  API.swift
//  MiniMuni
//
//  Created by Critz, Michael on 2025-01-13.
//
import Foundation

// Get an API key here: `https://511.org/open-data/transit`
public typealias APIKey = String

public typealias Stop = ScheduledStopPoint
public typealias StopCode = String
public typealias OperatorCode = String
public typealias LineCode = String

public actor API {
    private let decoder: JSONDecoder
    private let apiKey: APIKey
    private let networkClient: NetworkClient
    
    public init(apiKey: APIKey, networkClient: NetworkClient = URLSessionNetworkClient()) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
        self.apiKey = apiKey
        self.networkClient = networkClient
    }
    
    public enum Endpoint {
        private static let baseURL: URL = URL(string: "http://api.511.org/transit/")!
        
        case operators
        case lines(operatorCode: OperatorCode)
        case stops(operatorCode: OperatorCode, lineCode: LineCode)
        case realtime(operatorCode: OperatorCode, stopCode: StopCode)
        
        func url(_ apiKey: APIKey) -> URL {
            switch self {
            case .operators:
                let path = "Operators?api_key=\(apiKey)"
                return Self.baseURL.appendingPathComponent(path)
            case .lines(operatorCode: let agency):
                let path = "lines"
                return Self.baseURL.appendingPathComponent(path)
                    .appending(queryItems: [
                        .init(name: "operator_id", value: agency),
                        .init(name: "api_key", value: apiKey)
                    ])
            case .stops(operatorCode: let agency, let lineCode):
                let path = "stops"
                return Self.baseURL.appendingPathComponent(path)
                    .appending(queryItems: [
                        .init(name: "api_key", value: apiKey),
                        .init(name: "operator_id", value: agency),
                        .init(name: "line_id", value: lineCode),
                    ])
                
            // http://api.511.org/transit/StopMonitoring?api_key=SOME-UUID&agency=SF&stopCode=14510
            case .realtime(operatorCode: let agency, stopCode: let stopCode):
                let path = "StopMonitoring"
                return Self.baseURL.appendingPathComponent(path)
                    .appending(queryItems: [
                        .init(name: "api_key", value: apiKey),
                        .init(name: "agency", value: agency),
                        .init(name: "stopCode", value: stopCode),
                    ])
            }
        }
    }
}

// MARK: - Lines
extension API {
    public func fetchLines(_ agency: OperatorCode = "SF") async throws -> [Line] {
        let url = Endpoint.lines(operatorCode: agency).url(apiKey)
        let data = try await networkClient.fetchData(from: url)
        let lines = try decoder.decode([Line].self, from: data)
        return lines
    }
}

// MARK: - Stops
extension API {
    public func fetchStops(_ agency: OperatorCode = "SF", line: LineCode = "N") async throws -> [Stop] {
        let url = Endpoint.stops(operatorCode: agency, lineCode: line).url(apiKey)
        let data = try await networkClient.fetchData(from: url)
        let stops = try decoder.decode(Stops.self, from: data).contents.dataObjects.scheduledStopPoint
        return stops
    }
}

// MARK: - Stop Forecasts
extension API {
    private func fetchRealtime(_ stopID: StopCode = "14510", operatorID: OperatorCode = "SF") async throws -> [TripForecast] {
        let url = Endpoint.realtime(operatorCode: operatorID, stopCode: stopID).url(apiKey)
        let data = try await networkClient.fetchData(from: url)
        let stopMonitor = try decoder.decode(StopMonitor.self, from: data)
        let serviceDelivery = stopMonitor.serviceDelivery
        let forecasts = serviceDelivery.stopMonitoringDelivery.monitoredStopVisit.compactMap { monitoredStopVisit -> TripForecast? in
            guard let vehicleID = monitoredStopVisit.monitoredVehicleJourney.vehicleRef else {
                return nil
            }
            let arrivalTime = monitoredStopVisit.monitoredVehicleJourney.monitoredCall.expectedArrivalTime
            let destination = monitoredStopVisit.monitoredVehicleJourney.monitoredCall.destinationDisplay
            if let capacity = monitoredStopVisit.monitoredVehicleJourney.occupancy {
                return TripForecast(vehicleID, wait: Date.now.distance(to: arrivalTime), destination: destination, capacity: capacity)
            }
            return TripForecast(vehicleID, wait: Date.now.distance(to: arrivalTime), destination: destination)
        }
        return forecasts
    }
    
    @discardableResult
    public func refreshRealtime(_ stopID: StopCode = "14510", operatorID: OperatorCode = "SF") async -> Result<[TripForecast], Error> {
        do {
            let trips = try await fetchRealtime(stopID, operatorID: operatorID)
            return .success(trips)
        } catch {
            return .failure(error)
        }
    }
}
