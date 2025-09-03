//
//  Stops.swift
//  MiniMuni
//
//  Created by Critz, Michael on 2025-01-14.
//

import Foundation

// MARK: - Stops
struct Stops: Codable {
    let contents: Contents

    enum CodingKeys: String, CodingKey {
        case contents = "Contents"
    }
}

// MARK: - Contents
struct Contents: Codable {
    let responseTimestamp: Date
    let dataObjects: DataObjects

    enum CodingKeys: String, CodingKey {
        case responseTimestamp = "ResponseTimestamp"
        case dataObjects
    }
}

// MARK: - DataObjects
struct DataObjects: Codable {
    let id: String
    let scheduledStopPoint: [ScheduledStopPoint]

    enum CodingKeys: String, CodingKey {
        case id
        case scheduledStopPoint = "ScheduledStopPoint"
    }
}

// MARK: - ScheduledStopPoint
struct ScheduledStopPoint: Codable {
    let id: String
    let name: String
    let location: Location
    let url: String

    enum CodingKeys: String, CodingKey {
        case id
        case name = "Name"
        case location = "Location"
        case url = "Url"
    }
}

// MARK: - Location
struct Location: Codable {
    let longitude, latitude: String

    enum CodingKeys: String, CodingKey {
        case longitude = "Longitude"
        case latitude = "Latitude"
    }
}
