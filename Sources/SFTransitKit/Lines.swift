//
//  Lines.swift
//  MiniMuni
//
//  Created by Critz, Michael on 2025-01-14.
//

import Foundation

public typealias LineID = String
public typealias OperatorRef = String

// MARK: - Line
public struct Line: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let id: LineID
    public let name: String
    public let fromDate, toDate: Date
    public let transportMode: TransportMode
    public let publicCode, siriLineRef: String
    public let monitored: Bool
    public let operatorRef: OperatorRef

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case fromDate = "FromDate"
        case toDate = "ToDate"
        case transportMode = "TransportMode"
        case publicCode = "PublicCode"
        case siriLineRef = "SiriLineRef"
        case monitored = "Monitored"
        case operatorRef = "OperatorRef"
    }
}

public enum TransportMode: String, Codable, Sendable {
    case bus = "bus"
    case cableway = "cableway"
    case ferry = "ferry"
    case metro = "metro"
    case rail = "rail"
}

public typealias Lines = [Line]
