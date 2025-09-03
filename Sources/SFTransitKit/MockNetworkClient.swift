#if DEBUG
import Foundation

/// Mock implementation of NetworkClient for testing
actor MockNetworkClient: Sendable, NetworkClient {
    
    var responseData = [URL: Data]()
    func updateResponseData(_ responseData: [URL: Data]) {
        self.responseData = responseData
    }
    
    var error: Error?
    func updateError(_ error: Error?) {
        self.error = error
    }
    
    func fetchData(from url: URL) async throws -> Data {
        if let error = error {
            throw error
        }
        
        // Return predefined data for the URL if available
        guard let data = responseData[url] else {
            throw NSError(domain: "MockNetworkClient", code: 404, 
                         userInfo: [NSLocalizedDescriptionKey: "No mock data for URL: \(url)"])
        }
        
        return data
    }
    
    /// Helper method to load fixture data
    func loadFixture(named filename: String, bundle: Bundle = .main) throws -> Data {
        // Try to find the fixture in the provided bundle
        if let url = bundle.url(forResource: filename, withExtension: nil, subdirectory: "fixtures") {
            return try Data(contentsOf: url)
        }
        
        // If not found in the main bundle, try to find it in the test bundle
        let testBundlePath = bundle.bundlePath + "/../../../Tests/SFTransitKitTests/fixtures/" + filename
        let testBundleURL = URL(fileURLWithPath: testBundlePath)
        
        if FileManager.default.fileExists(atPath: testBundleURL.path) {
            return try Data(contentsOf: testBundleURL)
        }
        
        throw NSError(domain: "MockNetworkClient", code: 404,
                     userInfo: [NSLocalizedDescriptionKey: "Fixture not found: \(filename)"])
    }
}

#endif
