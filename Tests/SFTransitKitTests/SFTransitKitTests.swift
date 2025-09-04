import Testing
import Foundation
@testable import SFTransitKit

@Test func testFetchLinesWithMockData() async throws {
    let mockClient = MockNetworkClient()
    
    let fixtureURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("fixtures")
        .appendingPathComponent("lines.json")
    
    let fixtureData = try Data(contentsOf: fixtureURL)
    
    // Create the API with the mock client
    let api = TransitSFAPI(apiKey: "test-api-key", networkClient: mockClient)
    
    // Set up the mock to return our fixture data for the expected URL
    let expectedURL = TransitSFAPI.Endpoint.lines(operatorCode: "SF").url("test-api-key")
    await mockClient.updateResponseData([expectedURL: fixtureData])
    
    // Act
    let lines = try await api.fetchLines()
    
    // Assert
    #expect(lines.count > 0, "Should have at least one line")
    #expect(lines[0].id.isEmpty == false, "Line should have a non-empty ID")
}

@Test func testFetchStopsWithMockData() async throws {
    // Arrange
    let mockClient = MockNetworkClient()
    
    // Load the fixture data
    let fixtureURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("fixtures")
        .appendingPathComponent("stops.json")
    
    let fixtureData = try Data(contentsOf: fixtureURL)
    
    // Create the API with the mock client
    let api = TransitSFAPI(apiKey: "test-api-key", networkClient: mockClient)
    
    // Set up the mock to return our fixture data for the expected URL
    let expectedURL = TransitSFAPI.Endpoint.stops(operatorCode: "SF", lineCode: "N").url("test-api-key")
    await mockClient.updateResponseData([expectedURL : fixtureData])
    
    // Act
    let stops = try await api.fetchStops()
    
    // Assert
    #expect(stops.count > 0, "Should have at least one stop")
    #expect(stops[0].id.isEmpty == false, "Stop should have a non-empty ID")
}

@Test func testFetchRealtimeWithMockData() async throws {
    // Arrange
    let mockClient = MockNetworkClient()
    
    // Load the fixture data
    let fixtureURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("fixtures")
        .appendingPathComponent("stop-monitoring.json")
    
    let fixtureData = try Data(contentsOf: fixtureURL)
    
    // Create the API with the mock client
    let api = TransitSFAPI(apiKey: "test-api-key", networkClient: mockClient)
    
    // Set up the mock to return our fixture data for the expected URL
    let stopID = "14510"
    let operatorID = "SF"
    let expectedURL = TransitSFAPI.Endpoint.realtime(operatorCode: operatorID, stopCode: stopID).url("test-api-key")
    await mockClient.updateResponseData([expectedURL : fixtureData])
    
    // Act
    let result = await api.refreshRealtime(stopID, operatorID: operatorID)
    
    // Assert
    switch result {
    case .success(let forecasts):
        #expect(forecasts.count > 0, "Should have at least one forecast")
    case .failure(let error):
        throw error // Fail the test if we get an error
    }
}

@Test func testNetworkErrorHandling() async throws {
    // Arrange
    let mockClient = MockNetworkClient()
    let api = TransitSFAPI(apiKey: "test-api-key", networkClient: mockClient)
    
    // Set up the mock to return an error
    let testError = NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Test network error"])
    await mockClient.updateError(testError)
    
    // Act & Assert
    do {
        _ = try await api.fetchLines()
        #expect(Bool(false), "Should have thrown an error")
    } catch {
        #expect(error.localizedDescription == testError.localizedDescription, "Should throw the expected error")
    }
}

@Test func testEndpoints() {
    let operatorCode = "TEST"
    let lineCode = "LINE_TEST"
    let stopCode = "STOP_TEST"
    let apiKey = "TEST_API_KEY"
    
    let operatorsEndpoint = TransitSFAPI.Endpoint.operators
    let operatorsResultURL = operatorsEndpoint.url(apiKey)
    #expect(operatorsResultURL.absoluteString == "https://api.511.org/transit/operators?api_key=\(apiKey)")
    #expect(operatorsResultURL.path() == "/transit/operators")
    
    let linesEndpoint = TransitSFAPI.Endpoint.lines(operatorCode: operatorCode)
    let linesResultURL = linesEndpoint.url(apiKey)
    #expect(linesResultURL.absoluteString == "https://api.511.org/transit/lines?operator_id=\(operatorCode)&api_key=\(apiKey)")
    #expect(linesResultURL.path() == "/transit/lines")
    
    let stopsEndpoint = TransitSFAPI.Endpoint.stops(operatorCode: operatorCode, lineCode: lineCode)
    let stopsResultURL = stopsEndpoint.url(apiKey)
    #expect(stopsResultURL.absoluteString == "https://api.511.org/transit/stops?operator_id=\(operatorCode)&line_id=\(lineCode)&api_key=\(apiKey)")
    #expect(stopsResultURL.path() == "/transit/stops")
    
    let realTimeEndpoint = TransitSFAPI.Endpoint.realtime(operatorCode: operatorCode, stopCode: stopCode)
    let realTimeResultURL = realTimeEndpoint.url(apiKey)
    #expect(realTimeResultURL.absoluteString == "https://api.511.org/transit/stopmonitoring?agency=\(operatorCode)&stopCode=\(stopCode)&api_key=\(apiKey)")
    #expect(realTimeResultURL.path() == "/transit/stopmonitoring")
}
