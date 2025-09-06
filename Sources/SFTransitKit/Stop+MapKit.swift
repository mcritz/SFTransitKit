//
//  Stop+MapKit.swift
//  MiniMuni
//
//  Created by Critz, Michael on 2025-09-05.
//

#if canImport(MapKit)
import MapKit

extension Stop {
    public func mapLocation() -> CLLocationCoordinate2D? {
        guard let lat = Double(location.latitude),
              let lon = Double(location.longitude) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
#endif
