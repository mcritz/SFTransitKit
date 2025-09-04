# SFTransitKit

A Swift package for accessing San Francisco transit data from the 511.org API.

## Overview

SFTransitKit provides a simple and efficient way to access transit data for San Francisco, including:

- Transit lines (routes)
- Stops for each line
- Real-time arrival forecasts

The library handles API communication, data parsing, and provides a caching layer for improved performance.

## Requirements

- Swift 6.2+
- macOS 13+, iOS 16+, watchOS 9+, or visionOS 1+
- An API key from [511.org/open-data/transit](https://511.org/open-data/transit)

## Installation

### Swift Package Manager

Add SFTransitKit to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SFTransitKit.git", from: "1.0.0")
]
```

## API Usage

### Initialization

First, initialize the API with your 511.org API key:

```swift
import SFTransitKit

// Initialize with your API key
let api = API(apiKey: "your-511-api-key")

// For better organization and caching, use TransitService
let repository = SFTransitService(api: api)
```

### Fetching Transit Lines

```swift
// Fetch all lines for SF Muni (default operator)
do {
    let lines = try await repository.fetchLines()
    for line in lines {
        print("Line: \(line.name) (\(line.id))")
    }
} catch {
    print("Error fetching lines: \(error)")
}

// Fetch lines for a different operator
let acTransitLines = try await repository.fetchLines("AC")
```

### Fetching Stops for a Line

```swift
// Fetch stops for the N-Judah line (default)
do {
    let stops = try await repository.fetchStops()
    for stop in stops {
        print("Stop: \(stop.name) at \(stop.location.latitude), \(stop.location.longitude)")
    }
} catch {
    print("Error fetching stops: \(error)")
}

// Fetch stops for a specific line and operator
let jLineStops = try await repository.fetchStops("SF", line: "J")
```

### Getting Real-time Arrival Forecasts

```swift
// Get real-time forecasts for a specific stop
let stopID = "14510" // Example stop ID
let result = await repository.fetchRealtime(stopID)

switch result {
case .success(let forecasts):
    for forecast in forecasts {
        print("\(forecast.destination ?? "Unknown destination"): arriving in \(forecast.waitFormatted)")
    }
case .failure(let error):
    print("Error fetching real-time data: \(error)")
}
```

### Clearing the Cache

The repository maintains a cache of lines and stops to reduce API calls. You can clear this cache when needed:

```swift
// Clear the cache if you're using SFTransitService
if let repositoryImpl = repository as? SFTransitService {
    repositoryImpl.clearCache()
}
```

## Testing

SFTransitKit is designed with testability in mind and includes several components to facilitate testing.

### Using the Mock Network Client

For testing without making actual API calls, use the `MockNetworkClient`:

```swift
#if DEBUG
import XCTest
@testable import SFTransitKit

func testYourFeature() async throws {
    // Create a mock network client
    let mockClient = MockNetworkClient()
    
    // Create test data
    let testData = """
    {
        "your": "test data here"
    }
    """.data(using: .utf8)!
    
    // Configure the mock to return your test data
    let api = API(apiKey: "test-api-key", networkClient: mockClient)
    let url = API.Endpoint.lines(operatorCode: "SF").url("test-api-key")
    await mockClient.updateResponseData([url: testData])
    
    // Test your code that uses the API
    // ...
}
#endif
```

### Using Fixture Data

The package includes a helper method to load fixture data for tests:

```swift
#if DEBUG
// Load fixture data
let mockClient = MockNetworkClient()
let fixtureData = try mockClient.loadFixture(named: "lines.json", bundle: .module)

// Use the fixture data in your tests
await mockClient.updateResponseData([url: fixtureData])
#endif
```

### Using the Mock Transit Repository

For higher-level testing, you can use the `MockTransitService`:

```swift
#if DEBUG
// Create a mock repository
let mockRepository = MockTransitService()

// Configure the mock repository
let mockLine = Line(id: "1", name: "Test Line", fromDate: Date(), toDate: Date().addingTimeInterval(86400), 
                    transportMode: .bus, publicCode: "1", siriLineRef: "1", monitored: true, operatorRef: "SF")
await mockRepository.updateLinesResult(.success([mockLine]))

// Test code that uses the repository
let lines = try await mockRepository.fetchLines()
XCTAssertEqual(lines.count, 1)
XCTAssertEqual(lines[0].id, "1")
#endif
```

## Error Handling

SFTransitKit uses Swift's error handling mechanisms. Network and parsing errors are propagated to the caller:

```swift
do {
    let lines = try await repository.fetchLines()
    // Process lines
} catch {
    if let urlError = error as? URLError {
        // Handle network errors
        switch urlError.code {
        case .notConnectedToInternet:
            // Handle no internet connection
            break
        default:
            // Handle other URL errors
            break
        }
    } else {
        // Handle other errors (like parsing errors)
    }
}
```

For real-time data, the API returns a `Result` type:

```swift
let result = await repository.fetchRealtime(stopID)
switch result {
case .success(let forecasts):
    // Process forecasts
case .failure(let error):
    // Handle error
}
```

