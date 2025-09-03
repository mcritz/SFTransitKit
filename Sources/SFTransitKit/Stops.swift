//
//  Stops.swift
//  MiniMuni
//
//  Created by Critz, Michael on 2025-01-14.
//

import Foundation

// MARK: - Stops
public struct Stops: Codable, Sendable {
    public let contents: Contents

    enum CodingKeys: String, CodingKey {
        case contents = "Contents"
    }
}

// MARK: - Contents
public struct Contents: Codable, Sendable {
    public let responseTimestamp: Date
    public let dataObjects: DataObjects

    enum CodingKeys: String, CodingKey {
        case responseTimestamp = "ResponseTimestamp"
        case dataObjects
    }
}

// MARK: - DataObjects
public struct DataObjects: Codable, Sendable {
    public let id: String
    public let scheduledStopPoint: [ScheduledStopPoint]

    enum CodingKeys: String, CodingKey {
        case id
        case scheduledStopPoint = "ScheduledStopPoint"
    }
}

// MARK: - ScheduledStopPoint
public struct ScheduledStopPoint: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let location: Location
    public let url: String

    enum CodingKeys: String, CodingKey {
        case id
        case name = "Name"
        case location = "Location"
        case url = "Url"
    }
}

// MARK: - Location
public struct Location: Codable, Sendable {
    public let longitude, latitude: String

    enum CodingKeys: String, CodingKey {
        case longitude = "Longitude"
        case latitude = "Latitude"
    }
}
