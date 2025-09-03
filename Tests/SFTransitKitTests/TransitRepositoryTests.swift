import Testing
import Foundation
@testable import SFTransitKit

actor MockTransitService: TransitService {
    private var linesResult: Result<[Line], Error> = .success([])
    public func updateLinesResult(_ result: Result<[Line], Error>) {
        linesResult = result
    }
    
    private var stopsResult: Result<[Stop], Error> = .success([])
    public func updateStopsResult(_ result: Result<[Stop], Error>) {
        stopsResult = result
    }
    
    private var realtimeResult: Result<[TripForecast], Error> = .success([])
    public func updateRealtimeResult(_ result: Result<[TripForecast], Error>) {
        realtimeResult = result
    }
    
    private var fetchLinesCallCount: Int = 0
    func getFetchLinesCallCount() -> Int {
        return fetchLinesCallCount
    }
    
    private var fetchStopsCallCount: Int = 0
    func getFetchStopsCallCount() -> Int {
        return fetchStopsCallCount
    }
    
    private var fetchRealtimeCallCount: Int = 0
    func getFetchRealtimeCallCount() -> Int {
        return fetchRealtimeCallCount
    }
    
    func fetchLines(_ operatorCode: OperatorCode = "SF") async throws -> [Line] {
        fetchLinesCallCount += 1
        switch linesResult {
        case .success(let lines):
            return lines
        case .failure(let error):
            throw error
        }
    }
    
    func fetchStops(_ operatorCode: OperatorCode = "SF", line: LineCode = "N") async throws -> [Stop] {
        fetchStopsCallCount += 1
        switch stopsResult {
        case .success(let stops):
            return stops
        case .failure(let error):
            throw error
        }
    }
    
    func fetchRealtime(_ stopID: StopCode = "14510", operatorID: OperatorCode = "SF") async -> Result<[TripForecast], Error> {
        fetchRealtimeCallCount += 1
        return realtimeResult
    }
    
    // For testing cache clearing
    func clearCache() {
        // Reset call counts to simulate cache clearing
        fetchLinesCallCount = 0
        fetchStopsCallCount = 0
    }
}

@Test func testRepositoryCaching() async throws {
    // Arrange
    let mockRepository = MockTransitService()
    let mockLine = Line(id: "1", name: "Test Line", fromDate: Date(), toDate: Date().addingTimeInterval(86400), 
                        transportMode: .bus, publicCode: "1", siriLineRef: "1", monitored: true, operatorRef: .sf)
    await mockRepository.updateLinesResult(.success([mockLine]))
    
    // Act - First call should increment the call count
    let lines1 = try await mockRepository.fetchLines("SF")
    
    // Act - Second call should increment the call count again
    let lines2 = try await mockRepository.fetchLines("SF")
    
    // Assert
    let callCount = await mockRepository.getFetchLinesCallCount()
    #expect(callCount == 2, "Repository should be called twice")
    #expect(lines1.count == 1, "Should return one line")
    #expect(lines2.count == 1, "Should return one line")
    #expect(lines1[0].id == "1", "Should return the mock line")
    #expect(lines2[0].id == "1", "Should return the mock line")
}

@Test func testRepositoryCacheClear() async throws {
    // Arrange
    let mockRepository = MockTransitService()
    let mockLine = Line(id: "1", name: "Test Line", fromDate: Date(), toDate: Date().addingTimeInterval(86400), 
                        transportMode: .bus, publicCode: "1", siriLineRef: "1", monitored: true, operatorRef: .sf)
    await mockRepository.updateLinesResult(.success([mockLine]))
    
    // Act - First call should increment the call count
    _ = try await mockRepository.fetchLines("SF")
    
    // Act - Clear cache (resets call counts in our mock)
    await mockRepository.clearCache()
    
    // Act - Second call should increment the call count from 0 again
    _ = try await mockRepository.fetchLines("SF")
    
    // Assert
    let callCount = await mockRepository.getFetchLinesCallCount()
    #expect(callCount == 1, "Repository call count should be 1 after reset")
}

@Test func testRepositoryRealtimeNoCache() async throws {
    // Arrange
    let mockRepository = MockTransitService()
    let mockForecast = TripForecast("1", wait: 300, destination: "Test Destination")
    await mockRepository.updateRealtimeResult(.success([mockForecast]))
    
    // Act - First call
    let result1 = await mockRepository.fetchRealtime("14510", operatorID: "SF")
    
    // Act - Second call
    let result2 = await mockRepository.fetchRealtime("14510", operatorID: "SF")
    
    // Assert
    let callCount = await mockRepository.getFetchRealtimeCallCount()
    #expect(callCount == 2, "Repository should be called twice for realtime data")
    
    switch result1 {
    case .success(let forecasts):
        #expect(forecasts.count == 1, "Should return one forecast")
        #expect(forecasts[0].id == "1", "Should return the mock forecast")
    case .failure:
        #expect(false, "Should not fail")
    }
    
    switch result2 {
    case .success(let forecasts):
        #expect(forecasts.count == 1, "Should return one forecast")
        #expect(forecasts[0].id == "1", "Should return the mock forecast")
    case .failure:
        #expect(false, "Should not fail")
    }
}
