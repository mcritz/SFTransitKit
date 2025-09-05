import Foundation

/// Base implementation of TransitService using the ``API`` with basic caching
public actor SFTransitService: TransitService {
    private let api: TransitSFAPI
    private var lineCache: [OperatorCode: ([Line], Date)] = [:]
    private var stopCache: [StopCacheKey: ([Stop], Date)] = [:]
    private let cacheDuration: TimeInterval

    private struct StopCacheKey: Hashable {
        let operatorCode: OperatorCode
        let lineCode: LineCode
    }
    
    /// 
    /// - Parameters:
    ///   - api: ``TransitSFAPI`` that handles your networking
    ///   - cacheDuration: how long some network requests should be cached. 1 day by default.
    /// This does not effect the realtime fetches
    public init(api: TransitSFAPI, cacheDuration: TimeInterval = 8_640 ) {
        self.api = api
        self.cacheDuration = cacheDuration
    }
    
    public init(apiKey: APIKey, cacheDuration: TimeInterval = 8_640) {
        let api = TransitSFAPI(apiKey: apiKey)
        self.init(api: api, cacheDuration: cacheDuration)
    }
    
    public func fetchLines(_ operatorCode: OperatorCode = "SF") async throws -> [Line] {
        // Check cache first
        if let (cachedLines, timestamp) = lineCache[operatorCode], 
           Date().timeIntervalSince(timestamp) < cacheDuration {
            return cachedLines
        }
        
        // Fetch from API if not in cache or cache expired
        let lines = try await api.fetchLines(operatorCode)
        
        // Update cache
        lineCache[operatorCode] = (lines, Date())
        
        return lines
    }
    
    public func fetchStops(_ operatorCode: OperatorCode = "SF", line: LineCode = "N") async throws -> [Stop] {
        // Check cache first
        let cacheKey = StopCacheKey(operatorCode: operatorCode, lineCode: line)
        if let (cachedStops, timestamp) = stopCache[cacheKey], 
           Date().timeIntervalSince(timestamp) < cacheDuration {
            return cachedStops
        }
        
        // Fetch from API if not in cache or cache expired
        let stops = try await api.fetchStops(operatorCode, line: line)
        
        // Update cache
        stopCache[cacheKey] = (stops, Date())
        
        return stops
    }
    
    public func fetchRealtime(_ stopID: StopCode = "14510", operatorID: OperatorCode = "SF") async -> Result<[TripForecast], Error> {
        // Real-time data should not be cached, so we always fetch from the API
        return await api.refreshRealtime(stopID, operatorID: operatorID)
    }
    
    /// Clears all caches
    public func clearCache() {
        lineCache.removeAll()
        stopCache.removeAll()
    }
}
