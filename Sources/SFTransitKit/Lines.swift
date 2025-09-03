//
//  Lines.swift
//  MiniMuni
//
//  Created by Critz, Michael on 2025-01-14.
//

import Foundation

typealias LineID = String

// MARK: - Line
struct Line: Codable {
    let id: LineID
    let name: String
    let fromDate, toDate: Date
    let transportMode: TransportMode
    let publicCode, siriLineRef: String
    let monitored: Bool
    let operatorRef: OperatorRef

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

enum OperatorRef: String, Codable {
    case sf = "SF"
}

enum TransportMode: String, Codable {
    case bus = "bus"
    case cableway = "cableway"
    case metro = "metro"
}

typealias Lines = [Line]
