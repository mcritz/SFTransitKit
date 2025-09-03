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
    let api = API(apiKey: "test-api-key", networkClient: mockClient)
    
    // Set up the mock to return our fixture data for the expected URL
    let expectedURL = API.Endpoint.lines(operatorCode: "SF").url("test-api-key")
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
    let api = API(apiKey: "test-api-key", networkClient: mockClient)
    
    // Set up the mock to return our fixture data for the expected URL
    let expectedURL = API.Endpoint.stops(operatorCode: "SF", lineCode: "N").url("test-api-key")
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
    let api = API(apiKey: "test-api-key", networkClient: mockClient)
    
    // Set up the mock to return our fixture data for the expected URL
    let stopID = "14510"
    let operatorID = "SF"
    let expectedURL = API.Endpoint.realtime(operatorCode: operatorID, stopCode: stopID).url("test-api-key")
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
    let api = API(apiKey: "test-api-key", networkClient: mockClient)
    
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
