//
//  TripForecast.swift
//  MiniMuni
//
//  Created by Critz, Michael on 2025-01-13.
//

import Foundation

public typealias Capacity = String
public typealias TripForecastId = String

public struct TripForecast: Identifiable, Sendable {
    public let id: TripForecastId
    public let waitTime: TimeInterval
    public var waitTimeWhole: Int {
        Int(waitTime / 60)
    }
    public let capacity: String?
    public let destination: String?

    public init(
        _ id: TripForecastId, wait: TimeInterval, destination: String? = nil,
        capacity: Capacity = "Unknown"
    ) {
        self.id = id
        self.waitTime = wait
        self.destination = destination
        self.capacity = capacity
    }
}

extension TripForecast: CustomStringConvertible {
    public var wait: String {
        Duration(secondsComponent: Int64(waitTime), attosecondsComponent: 0).formatted(
            .units(width: .wide, maximumUnitCount: 1))
    }

    public var description: String {
        if let destination {
            return destination + " " + wait
        }
        return wait
    }

    public var waitFormatted: String {
        Duration(secondsComponent: Int64(waitTime), attosecondsComponent: 0).formatted(
            .units(width: .condensedAbbreviated, maximumUnitCount: 1))
    }
}

extension TripForecast: Equatable {}
