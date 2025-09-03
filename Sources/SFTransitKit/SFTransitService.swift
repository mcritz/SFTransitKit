import Foundation

/// Implementation of TransitService using the API
public actor SFTransitService: TransitService {
    private let api: API
    private var lineCache: [OperatorCode: ([Line], Date)] = [:]
    private var stopCache: [StopCacheKey: ([Stop], Date)] = [:]
    private let cacheDuration: TimeInterval = 60 * 60 // 1 hour

    struct StopCacheKey: Hashable {
        let operatorCode: OperatorCode
        let lineCode: LineCode
    }
    
    public init(api: API) {
        self.api = api
    }
    
    public init(apiKey: APIKey) {
        let api = API(apiKey: apiKey)
        self.init(api: api)
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
    func clearCache() {
        lineCache.removeAll()
        stopCache.removeAll()
    }
}
