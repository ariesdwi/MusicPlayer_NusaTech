//
//  CoreTests.swift
//  CoreTests
//
//  Created by Aries Prasetyo on 27/03/25.
//

import XCTest
import Combine
import Alamofire
@testable import Core

final class APIClientTests: XCTestCase {
    var apiClient: APIClient!
    var session: Session!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = Session(configuration: configuration)
        apiClient = APIClient(session: session)
    }

    override func tearDown() {
        apiClient = nil
        session = nil
        cancellables.removeAll()
        MockURLProtocol.responseData = nil
        MockURLProtocol.response = nil
        MockURLProtocol.error = nil
        super.tearDown()
    }

    func test_fetchSongs_success() {
        let expectedJSON = """
        {
            "resultCount": 1,
            "results": [
                {
                    "trackId": 12345,
                    "trackName": "Test Song",
                    "artistName": "Test Artist",
                    "previewUrl": "https://example.com/preview.mp3",
                    "artworkUrl100": "https://example.com/artwork.jpg"
                }
            ]
        }
        """.data(using: .utf8)!

        let url = URL(string: "https://example.com/songs")!
        MockURLProtocol.responseData = expectedJSON
        MockURLProtocol.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)

        let urlRequest = URLRequest(url: url)
        let expectation = self.expectation(description: "Fetch songs success")

        apiClient.request(urlRequest, responseType: SongResponseDTO.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success but received failure: \(error)")
                }
            }, receiveValue: { songResponse in
                XCTAssertEqual(songResponse.resultCount, 1)
                XCTAssertEqual(songResponse.results.first?.trackId, 12345)
                XCTAssertEqual(songResponse.results.first?.trackName, "Test Song")
                XCTAssertEqual(songResponse.results.first?.artistName, "Test Artist")
                XCTAssertEqual(songResponse.results.first?.previewUrl, "https://example.com/preview.mp3")
                XCTAssertEqual(songResponse.results.first?.artworkUrl100, "https://example.com/artwork.jpg")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func test_fetchSongs_failure() {
        let url = URL(string: "https://example.com/songs")!
        MockURLProtocol.error = NetworkError.invalidRequest // ✅ This should now be handled correctly

        let urlRequest = URLRequest(url: url)
        let expectation = self.expectation(description: "Fetch songs failure")

        apiClient.request(urlRequest, responseType: SongResponseDTO.self)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error, NetworkError.invalidRequest) // ✅ Should now pass
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure but received success")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }



}
