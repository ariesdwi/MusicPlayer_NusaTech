//
//  UntitleEndpointsTestsd.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 27/03/25.
//

import XCTest
@testable import Core

final class EndpointsTests: XCTestCase {
    func test_searchSongs_endpoint_with_valid_parameters() {
        // Given
        let searchTerm = "Imagine Dragons"
        let entityType = EntityType.song
        let page = 1
        let limit = 10
        
        // When
        let endpoint = MusicAPI.searchSongs(searchTerm: searchTerm, type: entityType, page: page, limit: limit)
        let urlRequest = endpoint.urlRequest
        
        // Then
        XCTAssertNotNil(urlRequest, "URLRequest should not be nil")
        
        // Check URL components
        let expectedURLString = "https://itunes.apple.com/search?term=Imagine%20Dragons&entity=song&limit=10&offset=10"
        XCTAssertEqual(urlRequest?.url?.absoluteString, expectedURLString, "Generated URL is incorrect")
        
        // Check HTTP method
        XCTAssertEqual(urlRequest?.httpMethod, "GET", "HTTP method should be GET")
    }

    func test_searchSongs_endpoint_without_pagination() {
        // Given
        let searchTerm = "Adele"
        let entityType = EntityType.song
        
        // When
        let endpoint = MusicAPI.searchSongs(searchTerm: searchTerm, type: entityType, page: nil, limit: nil)
        let urlRequest = endpoint.urlRequest
        
        // Then
        XCTAssertNotNil(urlRequest, "URLRequest should not be nil")
        
        // Check URL components
        let expectedURLString = "https://itunes.apple.com/search?term=Adele&entity=song"
        XCTAssertEqual(urlRequest?.url?.absoluteString, expectedURLString, "Generated URL without pagination is incorrect")
        
        // Check HTTP method
        XCTAssertEqual(urlRequest?.httpMethod, "GET", "HTTP method should be GET")
    }
}
