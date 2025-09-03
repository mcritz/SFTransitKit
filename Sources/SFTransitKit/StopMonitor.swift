//
//  StopMonitor.swift
//  MiniMuni
//
//  Created by Critz, Michael on 11/4/24.
//

import Foundation

// MARK: - StopMonitor
struct StopMonitor: Codable, Sendable {
    let serviceDelivery: ServiceDelivery

    enum CodingKeys: String, CodingKey {
        case serviceDelivery = "ServiceDelivery"
    }
}

// MARK: - ServiceDelivery
struct ServiceDelivery: Codable, Sendable {
    let responseTimestamp: Date?
    let producerRef: String
    let status: Bool
    let stopMonitoringDelivery: StopMonitoringDelivery

    enum CodingKeys: String, CodingKey {
        case responseTimestamp = "ResponseTimestamp"
        case producerRef = "ProducerRef"
        case status = "Status"
        case stopMonitoringDelivery = "StopMonitoringDelivery"
    }
}

// MARK: - StopMonitoringDelivery
struct StopMonitoringDelivery: Codable, Sendable {
    let version: String
    let responseTimestamp: Date?
    let status: Bool
    let monitoredStopVisit: [MonitoredStopVisit]

    enum CodingKeys: String, CodingKey {
        case version
        case responseTimestamp = "ResponseTimestamp"
        case status = "Status"
        case monitoredStopVisit = "MonitoredStopVisit"
    }
}

// MARK: - MonitoredStopVisit
struct MonitoredStopVisit: Codable, Sendable {
    let recordedAtTime: Date?
    let monitoringRef: String
    let monitoredVehicleJourney: MonitoredVehicleJourney

    enum CodingKeys: String, CodingKey {
        case recordedAtTime = "RecordedAtTime"
        case monitoringRef = "MonitoringRef"
        case monitoredVehicleJourney = "MonitoredVehicleJourney"
    }
}

// MARK: - MonitoredVehicleJourney
struct MonitoredVehicleJourney: Codable, Sendable {
    let lineRef, directionRef: String
    let framedVehicleJourneyRef: FramedVehicleJourneyRef
    let publishedLineName, operatorRef, originRef, originName: String
    let destinationRef, destinationName: String
    let monitored: Bool
    let inCongestion: Bool?
    let vehicleLocation: VehicleLocation
    let bearing, occupancy, vehicleRef: String?
    let monitoredCall: MonitoredCall

    enum CodingKeys: String, CodingKey {
        case lineRef = "LineRef"
        case directionRef = "DirectionRef"
        case framedVehicleJourneyRef = "FramedVehicleJourneyRef"
        case publishedLineName = "PublishedLineName"
        case operatorRef = "OperatorRef"
        case originRef = "OriginRef"
        case originName = "OriginName"
        case destinationRef = "DestinationRef"
        case destinationName = "DestinationName"
        case monitored = "Monitored"
        case inCongestion = "InCongestion"
        case vehicleLocation = "VehicleLocation"
        case bearing = "Bearing"
        case occupancy = "Occupancy"
        case vehicleRef = "VehicleRef"
        case monitoredCall = "MonitoredCall"
    }
}

// MARK: - FramedVehicleJourneyRef
struct FramedVehicleJourneyRef: Codable, Sendable {
    let dataFrameRef, datedVehicleJourneyRef: String

    enum CodingKeys: String, CodingKey {
        case dataFrameRef = "DataFrameRef"
        case datedVehicleJourneyRef = "DatedVehicleJourneyRef"
    }
}

// MARK: - MonitoredCall
struct MonitoredCall: Codable, Sendable {
    let stopPointRef, stopPointName, vehicleLocationAtStop, vehicleAtStop: String
    let destinationDisplay: String
    let aimedArrivalTime, expectedArrivalTime, aimedDepartureTime: Date
    let expectedDepartureTime: Date?
    let distances: String

    enum CodingKeys: String, CodingKey {
        case stopPointRef = "StopPointRef"
        case stopPointName = "StopPointName"
        case vehicleLocationAtStop = "VehicleLocationAtStop"
        case vehicleAtStop = "VehicleAtStop"
        case destinationDisplay = "DestinationDisplay"
        case aimedArrivalTime = "AimedArrivalTime"
        case expectedArrivalTime = "ExpectedArrivalTime"
        case aimedDepartureTime = "AimedDepartureTime"
        case expectedDepartureTime = "ExpectedDepartureTime"
        case distances = "Distances"
    }
}

// MARK: - VehicleLocation
struct VehicleLocation: Codable, Sendable {
    let longitude, latitude: String

    enum CodingKeys: String, CodingKey {
        case longitude = "Longitude"
        case latitude = "Latitude"
    }
}
