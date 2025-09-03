//
//  TripForecast.swift
//  MiniMuni
//
//  Created by Critz, Michael on 2025-01-13.
//

import Foundation

typealias Capacity = String
typealias TripForecastId = String

struct TripForecast: Identifiable, Sendable {
    let id: TripForecastId
    let waitTime: TimeInterval
    var waitTimeWhole: Int {
        Int(waitTime / 60)
    }
    let capacity: String?
    let destination: String?

    internal init(
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
    var wait: String {
        Duration(secondsComponent: Int64(waitTime), attosecondsComponent: 0).formatted(
            .units(width: .wide, maximumUnitCount: 1))
    }

    var description: String {
        if let destination {
            return destination + " " + wait
        }
        return wait
    }

    var waitFormatted: String {
        Duration(secondsComponent: Int64(waitTime), attosecondsComponent: 0).formatted(
            .units(width: .condensedAbbreviated, maximumUnitCount: 1))
    }
}

extension TripForecast: Equatable {}
