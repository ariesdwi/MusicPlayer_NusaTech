//
//  SearchSongsUseCaseTests.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 27/03/25.
//

import XCTest
import Combine
import Core
import Domain

final class SearchSongsUseCaseTests: XCTestCase {
    private var useCase: SearchSongsUseCase!
    private var mockNetworkService: MockNetworkService!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        useCase = SearchSongsUseCase(networkService: mockNetworkService)
    }

    override func tearDown() {
        useCase = nil
        mockNetworkService = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func test_execute_success() {
        // Given: A valid API response
        let expectedSong = Song(
            id: "12345",
            title: "Test Song",
            artist: "Test Artist",
            previewURL: "https://example.com/preview.mp3",
            artworkURL: "https://example.com/artwork.jpg"
        )

        let mockResponse = SongResponseDTO(
            resultCount: 1,
            results: [
                SongDTO(
                    trackId: 12345,
                    trackName: "Test Song",
                    artistName: "Test Artist",
                    previewUrl: "https://example.com/preview.mp3",  // Ensure this is NOT nil
                    artworkUrl100: "https://example.com/artwork.jpg" // Ensure this is NOT nil
                )
            ]
        )

        mockNetworkService.mockResponse = mockResponse

        let expectation = self.expectation(description: "SearchSongsUseCase success")

        // When: Executing the use case
        useCase.execute(query: "Test Query")
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success but received failure: \(error)")
                }
            }, receiveValue: { songs in
                // Then: Validate the response mapping
                XCTAssertEqual(songs.count, 1)
                XCTAssertEqual(songs.first, expectedSong)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func test_execute_failure_invalidRequest() {
        // Given: Network service returning an invalid request error
        mockNetworkService.mockError = .invalidRequest

        let expectation = self.expectation(description: "SearchSongsUseCase failure - invalid request")

        // When: Executing the use case
        useCase.execute(query: "Test Query")
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // Then: Validate that the error is passed correctly
                    XCTAssertEqual(error, .invalidRequest)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure but received success")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func test_execute_failure_unknownError() {
        // Given: Network service returning an unknown error
        mockNetworkService.mockError = .unknown(NSError(domain: "TestError", code: 999, userInfo: nil))

        let expectation = self.expectation(description: "SearchSongsUseCase failure - unknown error")

        // When: Executing the use case
        useCase.execute(query: "Test Query")
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // Then: Validate that an unknown error is correctly handled
                    if case .unknown(_) = error {
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected unknown error but received \(error)")
                    }
                }
            }, receiveValue: { _ in
                XCTFail("Expected failure but received success")
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }
}

